import { prisma } from '../lib/db';
import { getTenantId, ensureTenantAccess } from '../utils/tenant';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';
import { InventoryTransactionType } from '@prisma/client';
import { notificationService } from './notification.service';
import { inventoryStockService } from './inventory-stock.service';
import { locationService } from './location.service';

export interface CreateInventoryTransactionData {
  productId: string;
  locationId?: string; // Optional, defaults to merchant's default location
  type: InventoryTransactionType;
  quantity: number; // Positive for increase, negative for decrease
  reason?: string;
  referenceId?: string;
  referenceType?: string;
}

export interface InventoryFilters {
  productId?: string;
  type?: InventoryTransactionType;
  startDate?: Date;
  endDate?: Date;
  page?: number;
  limit?: number;
}

export class InventoryService {
  /**
   * Create inventory transaction (adjustments, returns, etc.)
   * Note: For adding stock, use inventoryStockService.addStock()
   */
  async createTransaction(req: AuthRequest, data: CreateInventoryTransactionData) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    if (!req.user?.userId) {
      throw new AppError('User ID is required', 400);
    }

    // Get product and verify it belongs to the tenant
    const product = await prisma.products.findUnique({
      where: { id: data.productId },
    });

    if (!product) {
      throw new AppError('Product not found', 404);
    }

    if (!ensureTenantAccess(req, product.merchantId)) {
      throw new AppError('Access denied', 403);
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

    // Check current stock for validation (if decreasing stock)
    if (data.quantity < 0) {
      const currentStock = await inventoryStockService.getCurrentStock(data.productId, locationId);
      const newStock = currentStock + data.quantity; // quantity is negative

      if (newStock < 0) {
        throw new AppError(
          `Insufficient stock for this operation. Available: ${currentStock}, Requested: ${Math.abs(data.quantity)}`,
          400
        );
      }
    }

    // Generate a cuid-like ID
    const generateId = () => {
      const timestamp = Date.now().toString(36);
      const randomStr = Math.random().toString(36).substring(2, 15);
      return `cl${timestamp}${randomStr}`;
    };

    // Create transaction
    const transaction = await prisma.inventory_transactions.create({
      data: {
        id: generateId(),
        merchantId: tenantId,
        productId: data.productId,
        locationId,
        userId: req.user!.userId,
        type: data.type,
        quantity: data.quantity,
        reason: data.reason,
        referenceId: data.referenceId,
        referenceType: data.referenceType,
      },
      include: {
        products: true,
        locations: {
          select: {
            id: true,
            name: true,
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

    // Check if stock is now low and send notification if needed
    const currentStock = await inventoryStockService.getCurrentStock(data.productId, locationId);
    if (currentStock <= product.lowStockThreshold) {
      await this.checkAndSendLowStockAlert(product, currentStock, req);
    }

    return transaction;
  }

  /**
   * Get inventory transactions with filters
   */
  async getTransactions(req: AuthRequest, filters: InventoryFilters) {
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

    if (filters.productId) {
      where.productId = filters.productId;
    }

    if (filters.type) {
      where.type = filters.type;
    }

    if (filters.startDate || filters.endDate) {
      where.createdAt = {};
      if (filters.startDate) {
        where.createdAt.gte = filters.startDate;
      }
      if (filters.endDate) {
        where.createdAt.lte = filters.endDate;
      }
    }

    const [transactions, total] = await Promise.all([
      prisma.inventory_transactions.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          products: {
            select: {
              id: true,
              name: true,
              brand: true,
              sku: true,
            },
          },
          locations: {
            select: {
              id: true,
              name: true,
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
      prisma.inventory_transactions.count({ where }),
    ]);

    return {
      transactions,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get inventory transaction by ID
   */
  async getTransactionById(req: AuthRequest, transactionId: string) {
    const transaction = await prisma.inventory_transactions.findUnique({
      where: { id: transactionId },
      include: {
        products: true,
        locations: {
          select: {
            id: true,
            name: true,
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

    if (!transaction) {
      throw new AppError('Transaction not found', 404);
    }

    if (!ensureTenantAccess(req, transaction.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    return transaction;
  }

  /**
   * Get inventory summary for a merchant
   */
  async getInventorySummary(req: AuthRequest) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    const products = await prisma.products.findMany({
      where: {
        merchantId: tenantId,
        isActive: true,
      },
      select: {
        id: true,
        name: true,
        lowStockThreshold: true,
        price: true,
        costPrice: true, // Include costPrice for inventory valuation
      },
    });

    // Get default location for stock calculation
    const defaultLocation = await locationService.getDefaultLocation(req);
    
    // Calculate current stock for all products
    const productIds = products.map((p) => p.id);
    const stockMap = await inventoryStockService.getCurrentStockForProducts(
      productIds,
      defaultLocation.id
    );

    // Calculate totals and filter low/out of stock
    let totalStockValue = 0;
    let totalStockQuantity = 0;
    const lowStockProducts: any[] = [];
    const outOfStockProducts: any[] = [];

    for (const product of products) {
      const currentStock = stockMap[product.id] || 0;
      totalStockQuantity += currentStock;
      // Use costPrice for inventory valuation (what you paid for it), not selling price
      // Fallback to price if costPrice is not set
      const unitCost = Number(product.costPrice) || Number(product.price) || 0;
      totalStockValue += unitCost * currentStock;

      if (currentStock <= product.lowStockThreshold) {
        lowStockProducts.push({
          id: product.id,
          name: product.name,
          stockQuantity: currentStock,
          threshold: product.lowStockThreshold,
        });
      }

      if (currentStock === 0) {
        outOfStockProducts.push({
          id: product.id,
          name: product.name,
        });
      }
    }

    return {
      totalProducts: products.length,
      totalStockValue,
      totalStockQuantity,
      lowStockCount: lowStockProducts.length,
      outOfStockCount: outOfStockProducts.length,
      lowStockProducts,
      outOfStockProducts,
    };
  }

  /**
   * Check and send low stock alert if needed
   */
  private async checkAndSendLowStockAlert(
    product: any,
    currentStock: number,
    req: AuthRequest
  ) {
    if (!req.user?.merchantId) {
      return;
    }

    try {
      // Get merchant admin emails
      const merchantAdmins = await prisma.users.findMany({
        where: {
          merchantId: req.user.merchantId,
          role: 'MERCHANT_ADMIN',
          isActive: true,
        },
        select: {
          email: true,
          firstName: true,
        },
      });

      // Send low stock alert to each admin
      for (const admin of merchantAdmins) {
        await notificationService.sendLowStockAlert({
          email: admin.email,
          productName: product.name,
          currentStock,
          threshold: product.lowStockThreshold,
        });

        // Create notification record
        await notificationService.createNotification({
          userId: undefined,
          merchantId: req.user.merchantId,
          emailTo: admin.email,
          type: 'LOW_STOCK' as any,
          subject: `Low Stock Alert: ${product.name}`,
          content: `Product ${product.name} has ${currentStock} units remaining (threshold: ${product.lowStockThreshold})`,
        });
      }
    } catch (error) {
      console.error('Failed to send low stock alert:', error);
      // Don't throw - notification failure shouldn't break the transaction
    }
  }

  /**
   * Update product stock threshold
   */
  async updateStockThreshold(req: AuthRequest, productId: string, threshold: number) {
    const product = await prisma.products.findUnique({
      where: { id: productId },
    });

    if (!product) {
      throw new AppError('Product not found', 404);
    }

    if (!ensureTenantAccess(req, product.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    if (threshold < 0) {
      throw new AppError('Stock threshold must be non-negative', 400);
    }

    const updated = await prisma.products.update({
      where: { id: productId },
      data: { lowStockThreshold: threshold },
    });

    return updated;
  }
}

export const inventoryService = new InventoryService();

