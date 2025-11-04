import { prisma } from '../lib/db';
import { getTenantId, ensureTenantAccess } from '../utils/tenant';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';
import { InventoryTransactionType } from '@prisma/client';
import { inventoryService } from './inventory.service';
import { auditService } from './audit.service';
import { AuditAction } from '@prisma/client';
import { subscriptionService } from './subscription.service';
import { inventoryStockService } from './inventory-stock.service';
import { locationService } from './location.service';

export interface SaleItemData {
  productId: string;
  quantity: number;
  unitPrice: number;
}

export interface CreateSaleData {
  items: SaleItemData[];
  locationId?: string; // Optional, defaults to merchant's default location
  notes?: string;
  saleDate?: Date; // Optional sale date (defaults to now)
  customerName?: string; // Optional customer full name
  customerPhone?: string; // Optional customer phone number
}

export interface SalesFilters {
  startDate?: Date;
  endDate?: Date;
  minAmount?: number;
  maxAmount?: number;
  userId?: string;
  page?: number;
  limit?: number;
}

export class SalesService {
  /**
   * Create a sale with items and update inventory
   */
  async createSale(req: AuthRequest, data: CreateSaleData) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    if (!req.user?.userId) {
      throw new AppError('User ID is required', 400);
    }

    if (!data.items || data.items.length === 0) {
      throw new AppError('Sale must have at least one item', 400);
    }

    // Validate all products belong to the tenant and have sufficient stock
    const productIds = data.items.map((item) => item.productId);
    const products = await prisma.products.findMany({
      where: {
        id: { in: productIds },
        merchantId: tenantId,
        isActive: true,
      },
    });

    if (products.length !== productIds.length) {
      throw new AppError('One or more products not found or inactive', 404);
    }

    // Get location (default if not provided)
    let locationId = data.locationId;
    if (!locationId) {
      const defaultLocation = await locationService.getDefaultLocation(req);
      locationId = defaultLocation.id;
    }

    // Verify location belongs to merchant
    const location = await prisma.locations.findUnique({
      where: { id: locationId },
    });

    if (!location || location.merchantId !== tenantId) {
      throw new AppError('Location not found or access denied', 404);
    }

    // Check stock availability using computed stock
    for (const item of data.items) {
      const product = products.find((p) => p.id === item.productId);
      if (!product) continue;

      const currentStock = await inventoryStockService.getCurrentStock(item.productId, locationId);
      if (currentStock < item.quantity) {
        throw new AppError(
          `Insufficient stock for ${product.name}. Available: ${currentStock}, Requested: ${item.quantity}`,
          400
        );
      }
    }

    // Calculate total amount (revenue)
    const totalAmount = data.items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0
    );

    // Calculate cost of goods sold (COGS)
    const costOfGoodsSold = data.items.reduce((sum, item) => {
      const product = products.find((p) => p.id === item.productId);
      if (!product) return sum;
      return sum + item.quantity * Number(product.costPrice);
    }, 0);

    // Calculate net income (profit) and profit margin
    const netIncome = totalAmount - costOfGoodsSold;
    const profitMargin = totalAmount > 0 ? (netIncome / totalAmount) * 100 : 0;

    // Calculate platform transaction fee
    const platformFee = await subscriptionService.calculateTransactionFee(totalAmount, tenantId);

    // Create sale with items and update inventory in a transaction
    const result = await prisma.$transaction(async (tx) => {
      // Generate a cuid-like ID
      const generateId = () => {
        const timestamp = Date.now().toString(36);
        const randomStr = Math.random().toString(36).substring(2, 15);
        return `cl${timestamp}${randomStr}`;
      };

      // Create sale
      const sale = await tx.sales.create({
        data: {
          id: generateId(),
          merchantId: tenantId,
          userId: req.user!.userId,
          totalAmount,
          platformFee,
          saleDate: data.saleDate || new Date(), // Use provided sale date or current date
          customerName: data.customerName || null,
          customerPhone: data.customerPhone || null,
          notes: data.notes,
          updatedAt: new Date(),
          sale_items: {
            create: data.items.map((item) => {
              const product = products.find((p) => p.id === item.productId);
              return {
                id: generateId(),
                productId: item.productId,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                defaultPrice: product ? Number(product.price) : item.unitPrice, // Store default selling price at time of sale
                totalPrice: item.quantity * item.unitPrice,
              };
            }),
          },
        },
        include: {
          sale_items: {
            include: {
              products: {
                select: {
                  id: true,
                  name: true,
                  brand: true,
                  sku: true,
                },
              },
            },
          },
          users: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
        },
      });

      // Create inventory transactions for each item (stock is computed, no product update needed)
      for (const item of data.items) {
        // Create inventory transaction
        await tx.inventory_transactions.create({
          data: {
            id: generateId(),
            merchantId: tenantId,
            productId: item.productId,
            locationId,
            userId: req.user!.userId,
            type: InventoryTransactionType.SALE,
            quantity: -item.quantity, // Negative for sale
            referenceId: sale.id,
            referenceType: 'SALE',
            reason: `Sale #${sale.id}`,
          },
        });
      }

      return sale;
    });

    // Log audit entry for sale creation
    if (req.user?.userId) {
      await auditService.createLog({
        userId: req.user.userId,
        merchantId: tenantId,
        action: AuditAction.CREATE,
        entityType: 'Sale',
        entityId: result.id,
        changes: { after: result },
      });
    }

    // Add calculated net income and profit margin to the result
    return {
      ...result,
      netIncome,
      profitMargin,
      costOfGoodsSold,
    };
  }

  /**
   * Get sales with filters
   */
  async getSales(req: AuthRequest, filters: SalesFilters) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      merchantId: tenantId,
    };

    if (filters.startDate || filters.endDate) {
      where.saleDate = {}; // Use saleDate instead of createdAt for filtering
      if (filters.startDate) {
        where.saleDate.gte = filters.startDate;
      }
      if (filters.endDate) {
        where.saleDate.lte = filters.endDate;
      }
    }

    if (filters.minAmount !== undefined || filters.maxAmount !== undefined) {
      where.totalAmount = {};
      if (filters.minAmount !== undefined) {
        where.totalAmount.gte = filters.minAmount;
      }
      if (filters.maxAmount !== undefined) {
        where.totalAmount.lte = filters.maxAmount;
      }
    }

    if (filters.userId) {
      where.userId = filters.userId;
    }

    const [sales, total] = await Promise.all([
      prisma.sales.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          sale_items: {
            include: {
              products: {
                select: {
                  id: true,
                  name: true,
                  brand: true,
                  sku: true,
                  imageUrl: true,
                  costPrice: true,
                },
              },
            },
          },
          users: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
        },
      }),
      prisma.sales.count({ where }),
    ]);

    // Calculate net income and profit margin for each sale
    const salesWithProfit = sales.map((sale) => {
      const costOfGoodsSold = sale.sale_items.reduce((sum, item) => {
        return sum + item.quantity * Number(item.products.costPrice || 0);
      }, 0);
      const netIncome = Number(sale.totalAmount) - costOfGoodsSold;
      const profitMargin = Number(sale.totalAmount) > 0 ? (netIncome / Number(sale.totalAmount)) * 100 : 0;

      return {
        ...sale,
        netIncome,
        profitMargin,
        costOfGoodsSold,
      };
    });

    return {
      sales: salesWithProfit,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get sale by ID
   */
  async getSaleById(req: AuthRequest, saleId: string) {
    const sale = await prisma.sales.findUnique({
      where: { id: saleId },
      include: {
        sale_items: {
          include: {
            products: {
              select: {
                id: true,
                name: true,
                brand: true,
                size: true,
                sku: true,
                barcode: true,
                imageUrl: true,
                costPrice: true,
              },
            },
          },
        },
        users: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
        merchants: {
          select: {
            id: true,
            name: true,
            email: true,
            phone: true,
            address: true,
          },
        },
      },
    });

    if (!sale) {
      throw new AppError('Sale not found', 404);
    }

    if (!ensureTenantAccess(req, sale.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    // Calculate net income and profit margin for this sale
    const costOfGoodsSold = sale.sale_items.reduce((sum, item) => {
      return sum + item.quantity * Number(item.products.costPrice || 0);
    }, 0);
    const netIncome = Number(sale.totalAmount) - costOfGoodsSold;
    const profitMargin = Number(sale.totalAmount) > 0 ? (netIncome / Number(sale.totalAmount)) * 100 : 0;

    return {
      ...sale,
      netIncome,
      profitMargin,
      costOfGoodsSold,
    };
  }

  /**
   * Get sales analytics/summary
   */
  async getSalesAnalytics(req: AuthRequest, startDate?: Date, endDate?: Date) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    const where: any = {
      merchantId: tenantId,
    };

    if (startDate || endDate) {
      where.saleDate = {}; // Use saleDate instead of createdAt for analytics
      if (startDate) {
        where.saleDate.gte = startDate;
      }
      if (endDate) {
        where.saleDate.lte = endDate;
      }
    }

    const [totalSales, totalRevenue, sales] = await Promise.all([
      prisma.sales.count({ where }),
      prisma.sales.aggregate({
        where,
        _sum: {
          totalAmount: true,
        },
      }),
      prisma.sales.findMany({
        where,
        include: {
          sale_items: {
            include: {
              products: {
                select: {
                  name: true,
                  costPrice: true,
                },
              },
            },
          },
        },
      }),
    ]);

    // Calculate total net income and profit margin
    let totalCostOfGoodsSold = 0;
    sales.forEach((sale) => {
      sale.sale_items.forEach((item) => {
        totalCostOfGoodsSold += item.quantity * Number(item.products.costPrice || 0);
      });
    });

    const totalNetIncome = (totalRevenue._sum.totalAmount ? Number(totalRevenue._sum.totalAmount) : 0) - totalCostOfGoodsSold;
    const totalProfitMargin = totalRevenue._sum.totalAmount && Number(totalRevenue._sum.totalAmount) > 0
      ? (totalNetIncome / Number(totalRevenue._sum.totalAmount)) * 100
      : 0;

    // Calculate top selling products
    const productSales: Record<string, { name: string; quantity: number; revenue: number }> = {};

    sales.forEach((sale) => {
      sale.sale_items.forEach((item) => {
        const productId = item.productId;
        const productName = item.products.name;
        
        if (!productSales[productId]) {
          productSales[productId] = {
            name: productName,
            quantity: 0,
            revenue: 0,
          };
        }
        
        productSales[productId].quantity += item.quantity;
        productSales[productId].revenue += Number(item.totalPrice);
      });
    });

    const topProducts = Object.values(productSales)
      .sort((a, b) => b.quantity - a.quantity)
      .slice(0, 10);

    // Calculate daily sales (last 30 days if no date range)
    const dailySales = await this.getDailySales(tenantId, startDate, endDate);

    return {
      totalSales,
      totalRevenue: totalRevenue._sum.totalAmount || 0,
      totalNetIncome,
      totalProfitMargin,
      totalCostOfGoodsSold,
      averageSaleAmount: totalSales > 0 ? Number(totalRevenue._sum.totalAmount || 0) / totalSales : 0,
      topProducts,
      dailySales,
    };
  }

  /**
   * Get daily sales breakdown
   */
  private async getDailySales(merchantId: string, startDate?: Date, endDate?: Date) {
    const defaultStart = new Date();
    defaultStart.setDate(defaultStart.getDate() - 30);
    
    const start = startDate || defaultStart;
    const end = endDate || new Date();

    const sales = await prisma.sales.findMany({
      where: {
        merchantId,
        saleDate: {
          gte: start,
          lte: end,
        },
      },
      select: {
        saleDate: true,
        totalAmount: true,
      },
    });

    // Group by date
    const dailyMap: Record<string, { date: string; count: number; revenue: number }> = {};

    sales.forEach((sale) => {
      const date = sale.saleDate.toISOString().split('T')[0];
      if (!dailyMap[date]) {
        dailyMap[date] = {
          date,
          count: 0,
          revenue: 0,
        };
      }
      dailyMap[date].count += 1;
      dailyMap[date].revenue += Number(sale.totalAmount);
    });

    return Object.values(dailyMap).sort((a, b) => a.date.localeCompare(b.date));
  }
}

export const salesService = new SalesService();

