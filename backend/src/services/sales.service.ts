import { prisma } from '../lib/db';
import { getTenantId, ensureTenantAccess } from '../utils/tenant';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';
import { InventoryTransactionType, Prisma } from '@prisma/client';
import { inventoryService } from './inventory.service';
import { auditService } from './audit.service';
import { AuditAction } from '@prisma/client';
import { subscriptionService } from './subscription.service';
import { inventoryStockService } from './inventory-stock.service';
import { locationService } from './location.service';
import { expenseService } from './expense.service';

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

/** SQL fragment for `sales` rows scoped by merchant + optional saleDate range (analytics). */
function buildSalesAnalyticsWhereSql(
  merchantId: string,
  startDate?: Date,
  endDate?: Date
): Prisma.Sql {
  const parts: Prisma.Sql[] = [Prisma.sql`s."merchantId" = ${merchantId}`];
  if (startDate) parts.push(Prisma.sql`s."saleDate" >= ${startDate}`);
  if (endDate) parts.push(Prisma.sql`s."saleDate" <= ${endDate}`);
  return Prisma.join(parts, ' AND ');
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

    const uniqueProductIds = [...new Set(data.items.map((i) => i.productId))];
    const stockMap = await inventoryStockService.getCurrentStockForProducts(uniqueProductIds, locationId);

    for (const item of data.items) {
      const product = products.find((p) => p.id === item.productId);
      if (!product) continue;

      const currentStock = stockMap[item.productId] ?? 0;
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
                  size: true,
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

    const whereSql = buildSalesAnalyticsWhereSql(tenantId, startDate, endDate);

    const [totalSales, totalRevenue, cogsRows, topProductRows] = await Promise.all([
      prisma.sales.count({ where }),
      prisma.sales.aggregate({
        where,
        _sum: {
          totalAmount: true,
        },
      }),
      prisma.$queryRaw<Array<{ cogs: unknown }>>`
        SELECT COALESCE(SUM(si.quantity * p."costPrice"), 0) AS cogs
        FROM sale_items si
        INNER JOIN sales s ON s.id = si."saleId"
        INNER JOIN products p ON p.id = si."productId"
        WHERE ${whereSql}
      `,
      prisma.$queryRaw<
        Array<{
          productId: string;
          name: string;
          quantity: bigint;
          revenue: unknown;
        }>
      >`
        SELECT
          si."productId",
          p.name,
          SUM(si.quantity)::bigint AS quantity,
          SUM(si."totalPrice") AS revenue
        FROM sale_items si
        INNER JOIN sales s ON s.id = si."saleId"
        INNER JOIN products p ON p.id = si."productId"
        WHERE ${whereSql}
        GROUP BY si."productId", p.name
        ORDER BY SUM(si.quantity) DESC
        LIMIT 10
      `,
    ]);

    const totalCostOfGoodsSold = Number(cogsRows[0]?.cogs ?? 0);

    const totalRevenueAmount = totalRevenue._sum.totalAmount ? Number(totalRevenue._sum.totalAmount) : 0;
    const grossProfit = totalRevenueAmount - totalCostOfGoodsSold;

    const totalExpenses = await expenseService.getTotalExpenses(tenantId, startDate, endDate);

    const netProfit = grossProfit - totalExpenses;

    const profitMargin = totalRevenueAmount > 0
      ? (netProfit / totalRevenueAmount) * 100
      : 0;

    const topProducts = topProductRows.map((row) => ({
      name: row.name,
      quantity: Number(row.quantity),
      revenue: Number(row.revenue ?? 0),
    }));

    const dailySales = await this.getDailySales(tenantId, startDate, endDate);

    return {
      totalSales,
      totalRevenue: totalRevenueAmount,
      totalCostOfGoodsSold,
      grossProfit,
      totalExpenses,
      netProfit,
      profitMargin,
      averageSaleAmount: totalSales > 0 ? totalRevenueAmount / totalSales : 0,
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

    const dailyWhere = Prisma.join(
      [
        Prisma.sql`s."merchantId" = ${merchantId}`,
        Prisma.sql`s."saleDate" >= ${start}`,
        Prisma.sql`s."saleDate" <= ${end}`,
      ],
      ' AND '
    );

    const rows = await prisma.$queryRaw<Array<{ d: string; cnt: bigint; rev: unknown }>>`
      SELECT
        to_char(s."saleDate" AT TIME ZONE 'UTC', 'YYYY-MM-DD') AS d,
        COUNT(*)::bigint AS cnt,
        SUM(s."totalAmount") AS rev
      FROM sales s
      WHERE ${dailyWhere}
      GROUP BY to_char(s."saleDate" AT TIME ZONE 'UTC', 'YYYY-MM-DD')
      ORDER BY d ASC
    `;

    return rows.map((r) => ({
      date: r.d,
      count: Number(r.cnt),
      revenue: Number(r.rev ?? 0),
    }));
  }
}

export const salesService = new SalesService();

