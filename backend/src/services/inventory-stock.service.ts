import { prisma } from '../lib/db';
import { getTenantId, ensureTenantAccess } from '../utils/tenant';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';
import { InventoryTransactionType } from '@prisma/client';
import { notificationService } from './notification.service';
import { locationService } from './location.service';

export interface AddStockData {
  productId: string;
  locationId?: string; // Optional, defaults to merchant's default location
  quantity: number;
  batchNumber?: string;
  expirationDate?: Date;
  receivedDate?: Date;
  notes?: string;
  // Payment tracking fields
  paymentStatus?: 'PAID' | 'CREDIT' | 'PARTIAL';
  supplierName?: string;
  supplierContact?: string;
  totalCost?: number;
  paidAmount?: number;
  paymentDueDate?: Date;
}

export interface InventoryEntryFilters {
  productId?: string;
  locationId?: string;
  batchNumber?: string;
  startDate?: Date;
  endDate?: Date;
  page?: number;
  limit?: number;
}

export interface TransferStockData {
  productId: string;
  fromLocationId: string;
  toLocationId: string;
  quantity: number;
  notes?: string;
}

export class InventoryStockService {
  /**
   * Calculate current stock for a product at a location
   * 
   * Stock calculation logic:
   * 1. Inventory entries: Stock physically received (from STOCK_IN and TRANSFER_IN operations)
   * 2. Transactions: All stock movements that affect inventory but don't create inventory entries:
   *    - SALE: reduces stock (quantity is negative)
   *    - TRANSFER_OUT: reduces stock at source (quantity is negative)
   *    - ADJUSTMENT: can be positive (stock increase/correction) or negative (stock decrease/correction)
   *    - RESTOCK: increases stock (quantity is positive) - but doesn't create inventory entry
   *    - RETURN: increases stock (quantity is positive) - but doesn't create inventory entry
   * 
   * We exclude STOCK_IN and TRANSFER_IN because they create inventory entries.
   * 
   * Formula: Stock = SUM(inventory entries) + SUM(all transactions except STOCK_IN and TRANSFER_IN)
   */
  async getCurrentStock(productId: string, locationId?: string): Promise<number> {
    // Sum all Inventory entries (stock physically received via STOCK_IN and TRANSFER_IN)
    const inventoryWhere: any = { productId };
    if (locationId) {
      inventoryWhere.locationId = locationId;
    }

    const inventorySum = await prisma.inventory.aggregate({
      where: inventoryWhere,
      _sum: { quantity: true },
    });

    // Sum all transactions EXCEPT STOCK_IN and TRANSFER_IN (which create inventory entries)
    // This includes: SALE, TRANSFER_OUT, ADJUSTMENT (positive/negative), RESTOCK, RETURN
    const transactionWhere: any = {
      productId,
      type: {
        notIn: [InventoryTransactionType.STOCK_IN, InventoryTransactionType.TRANSFER_IN],
      },
    };
    if (locationId) {
      transactionWhere.locationId = locationId;
    }

    const transactionSum = await prisma.inventory_transactions.aggregate({
      where: transactionWhere,
      _sum: { quantity: true },
    });

    const totalInventory = inventorySum._sum.quantity || 0;
    const totalTransactions = transactionSum._sum.quantity || 0; // Can be positive or negative

    // Debug logging (can remove later)
    if (totalInventory + totalTransactions < 0) {
      console.log(`[DEBUG] Stock calculation for product ${productId}, location ${locationId || 'all'}:`);
      console.log(`  Inventory entries sum: ${totalInventory}`);
      console.log(`  Transactions sum (excluding STOCK_IN/TRANSFER_IN): ${totalTransactions}`);
      console.log(`  Total: ${totalInventory + totalTransactions}`);
    }

    return totalInventory + totalTransactions;
  }

  /**
   * Get current stock for multiple products at a location
   */
  async getCurrentStockForProducts(
    productIds: string[],
    locationId?: string
  ): Promise<Record<string, number>> {
    const stockMap: Record<string, number> = {};

    // Get inventory sums per product
    const inventoryWhere: any = {
      productId: { in: productIds },
    };
    if (locationId) {
      inventoryWhere.locationId = locationId;
    }

    const inventoryEntries = await prisma.inventory.groupBy({
      by: ['productId'],
      where: inventoryWhere,
      _sum: { quantity: true },
    });

    // Get transaction sums per product (excluding STOCK_IN and TRANSFER_IN)
    const transactionWhere: any = {
      productId: { in: productIds },
      type: {
        notIn: [InventoryTransactionType.STOCK_IN, InventoryTransactionType.TRANSFER_IN],
      },
    };
    if (locationId) {
      transactionWhere.locationId = locationId;
    }

    const transactions = await prisma.inventory_transactions.groupBy({
      by: ['productId'],
      where: transactionWhere,
      _sum: { quantity: true },
    });

    // Combine results
    for (const productId of productIds) {
      const inventorySum =
        inventoryEntries.find((e) => e.productId === productId)?._sum.quantity || 0;
      const transactionSum =
        transactions.find((t) => t.productId === productId)?._sum.quantity || 0;
      stockMap[productId] = inventorySum + transactionSum;
    }

    return stockMap;
  }

  /**
   * Add stock (create new immutable Inventory entry)
   */
  async addStock(req: AuthRequest, data: AddStockData) {
    const tenantId = getTenantId(req);

    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    if (!req.user?.userId) {
      throw new AppError('User ID is required', 400);
    }

    if (data.quantity <= 0) {
      throw new AppError('Quantity must be greater than 0', 400);
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

    // Create Inventory entry and transaction in a single transaction
    const result = await prisma.$transaction(async (tx) => {
      // Generate a cuid-like ID
      const generateId = () => {
        const timestamp = Date.now().toString(36);
        const randomStr = Math.random().toString(36).substring(2, 15);
        return `cl${timestamp}${randomStr}`;
      };

      // Determine payment status and set paidAt if fully paid
      const paymentStatus = data.paymentStatus || 'PAID';
      const paidAt = paymentStatus === 'PAID' ? new Date() : null;

      // Create immutable Inventory entry
      const inventoryEntry = await tx.inventory.create({
        data: {
          id: generateId(),
          productId: data.productId,
          locationId,
          quantity: data.quantity,
          batchNumber: data.batchNumber,
          expirationDate: data.expirationDate,
          receivedDate: data.receivedDate || new Date(),
          notes: data.notes,
          addedBy: req.user!.userId,
          // Payment tracking fields
          paymentStatus: paymentStatus as any,
          supplierName: data.supplierName,
          supplierContact: data.supplierContact,
          totalCost: data.totalCost,
          paidAmount: data.paidAmount || (paymentStatus === 'PAID' ? data.totalCost : null),
          paymentDueDate: data.paymentDueDate,
          paidAt: paidAt,
        },
        include: {
          products: true,
          locations: true,
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

      // Create InventoryTransaction for tracking
      await tx.inventory_transactions.create({
        data: {
          id: generateId(),
          merchantId: tenantId,
          productId: data.productId,
          locationId,
          userId: req.user!.userId,
          type: InventoryTransactionType.STOCK_IN,
          quantity: data.quantity,
          referenceId: inventoryEntry.id,
          referenceType: 'STOCK_ADD',
          reason: data.notes || `Stock added: ${data.quantity} units`,
        },
      });

      return inventoryEntry;
    });

    // Check for low stock and send notification if needed
    const currentStock = await this.getCurrentStock(data.productId, locationId);
    if (currentStock <= product.lowStockThreshold) {
      await this.checkAndSendLowStockAlert(product, currentStock, req);
    }

    return result;
  }

  /**
   * Get inventory entries with filters
   */
  async getInventoryEntries(req: AuthRequest, filters: InventoryEntryFilters) {
    const tenantId = getTenantId(req);

    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      products: {
        merchantId: tenantId,
      },
    };

    if (filters.productId) {
      where.productId = filters.productId;
    }

    if (filters.locationId) {
      where.locationId = filters.locationId;
    }

    if (filters.batchNumber) {
      where.batchNumber = { contains: filters.batchNumber, mode: 'insensitive' };
    }

    if (filters.startDate || filters.endDate) {
      where.receivedDate = {};
      if (filters.startDate) {
        where.receivedDate.gte = filters.startDate;
      }
      if (filters.endDate) {
        where.receivedDate.lte = filters.endDate;
      }
    }

    const [entries, total] = await Promise.all([
      prisma.inventory.findMany({
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
      prisma.inventory.count({ where }),
    ]);

    return {
      entries,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get stock history for a product (Inventory entries + transactions)
   */
  async getStockHistory(productId: string, locationId?: string) {
    const product = await prisma.products.findUnique({
      where: { id: productId },
    });

    if (!product) {
      throw new AppError('Product not found', 404);
    }

    const inventoryWhere: any = { productId };
    if (locationId) {
      inventoryWhere.locationId = locationId;
    }

    const transactionWhere: any = { productId };
    if (locationId) {
      transactionWhere.locationId = locationId;
    }

    const [inventoryEntries, transactions] = await Promise.all([
      prisma.inventory.findMany({
        where: inventoryWhere,
        orderBy: { createdAt: 'desc' },
        include: {
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
            },
          },
        },
      }),
      prisma.inventory_transactions.findMany({
        where: transactionWhere,
        orderBy: { createdAt: 'desc' },
        include: {
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
            },
          },
        },
      }),
    ]);

    return {
      inventoryEntries,
      transactions,
    };
  }

  /**
   * Transfer stock between locations
   */
  async transferStock(req: AuthRequest, data: TransferStockData) {
    const tenantId = getTenantId(req);

    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    if (!req.user?.userId) {
      throw new AppError('User ID is required', 400);
    }

    if (data.quantity <= 0) {
      throw new AppError('Quantity must be greater than 0', 400);
    }

    if (data.fromLocationId === data.toLocationId) {
      throw new AppError('Source and destination locations must be different', 400);
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

    // Verify locations belong to merchant
    const [fromLocation, toLocation] = await Promise.all([
      prisma.locations.findUnique({ where: { id: data.fromLocationId } }),
      prisma.locations.findUnique({ where: { id: data.toLocationId } }),
    ]);

    if (!fromLocation || fromLocation.merchantId !== tenantId) {
      throw new AppError('Source location not found or access denied', 404);
    }

    if (!toLocation || toLocation.merchantId !== tenantId) {
      throw new AppError('Destination location not found or access denied', 404);
    }

    // Check available stock at source location
    const availableStock = await this.getCurrentStock(data.productId, data.fromLocationId);

    // If stock is negative, get detailed breakdown to help diagnose
    if (availableStock < 0) {
      // Get detailed breakdown for better error message
      const inventoryWhere: any = { productId: data.productId, locationId: data.fromLocationId };
      const transactionWhere: any = {
        productId: data.productId,
        locationId: data.fromLocationId,
        type: {
          notIn: [InventoryTransactionType.STOCK_IN, InventoryTransactionType.TRANSFER_IN],
        },
      };

      const [inventoryEntries, transactions] = await Promise.all([
        prisma.inventory.findMany({ where: inventoryWhere, select: { quantity: true } }),
        prisma.inventory_transactions.findMany({
          where: transactionWhere,
          select: { type: true, quantity: true },
        }),
      ]);

      const inventoryTotal = inventoryEntries.reduce((sum, e) => sum + e.quantity, 0);
      const transactionTotal = transactions.reduce((sum, t) => sum + t.quantity, 0);

      console.error(`[ERROR] Negative stock for product ${data.productId} at location ${data.fromLocationId}:`);
      console.error(`  Inventory entries: ${inventoryEntries.length} entries, total: ${inventoryTotal}`);
      console.error(`  Transactions: ${transactions.length} transactions, total: ${transactionTotal}`);
      console.error(`  Calculated stock: ${availableStock}`);

      throw new AppError(
        `Cannot transfer from "${fromLocation.name}": Stock is negative (${availableStock}). ` +
        `This location has ${inventoryEntries.length} inventory entries (total: ${inventoryTotal}) ` +
        `and ${transactions.length} outbound transactions (total: ${transactionTotal}). ` +
        `Please add stock to this location first to correct the negative balance.`,
        400
      );
    }

    if (availableStock < data.quantity) {
      throw new AppError(
        `Insufficient stock at source location "${fromLocation.name}". Available: ${availableStock}, Requested: ${data.quantity}`,
        400
      );
    }

    // Create transfer transactions and inventory entry at destination
    // When stock is transferred, it's physically received at the destination location,
    // so we create a new inventory entry there. The inventory entries table will show
    // all stock physically present at each location, making it easy to see what's where.
    const result = await prisma.$transaction(async (tx) => {
      // Generate a cuid-like ID
      const generateId = () => {
        const timestamp = Date.now().toString(36);
        const randomStr = Math.random().toString(36).substring(2, 15);
        return `cl${timestamp}${randomStr}`;
      };

      // Create TRANSFER_OUT transaction at source location (negative quantity)
      const transferOut = await tx.inventory_transactions.create({
        data: {
          id: generateId(),
          merchantId: tenantId,
          productId: data.productId,
          locationId: data.fromLocationId,
          userId: req.user!.userId,
          type: InventoryTransactionType.TRANSFER_OUT,
          quantity: -data.quantity,
          referenceType: 'TRANSFER',
          reason: data.notes || `Transfer to ${toLocation.name}`,
        },
      });

      // Create new inventory entry at destination location (stock is physically received there)
      // This makes the inventory entries table clear - you can see all stock at each location
      const inventoryEntry = await tx.inventory.create({
        data: {
          id: generateId(),
          productId: data.productId,
          locationId: data.toLocationId,
          quantity: data.quantity,
          receivedDate: new Date(),
          notes: data.notes || `Transferred from ${fromLocation.name}`,
          addedBy: req.user!.userId,
        },
      });

      // Create TRANSFER_IN transaction at destination for audit trail
      // Note: This transaction is NOT counted in stock calculation (excluded in getCurrentStock)
      // It's only for tracking/history purposes
      const transferIn = await tx.inventory_transactions.create({
        data: {
          id: generateId(),
          merchantId: tenantId,
          productId: data.productId,
          locationId: data.toLocationId,
          userId: req.user!.userId,
          type: InventoryTransactionType.TRANSFER_IN,
          quantity: data.quantity, // This won't be counted in stock calculation
          referenceId: inventoryEntry.id,
          referenceType: 'TRANSFER',
          reason: data.notes || `Transfer from ${fromLocation.name}`,
        },
      });

      return { transferOut, transferIn, inventoryEntry };
    });

    // Check for low stock at source location after transfer
    const newStockAtSource = await this.getCurrentStock(data.productId, data.fromLocationId);
    if (newStockAtSource <= product.lowStockThreshold) {
      await this.checkAndSendLowStockAlert(product, newStockAtSource, req);
    }

    return result;
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
      // Get merchant admin emails (users with merchant admin role)
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
   * Get debt summary - total outstanding debt from unpaid inventory
   */
  async getDebtSummary(req: AuthRequest) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    // Get all unpaid inventory entries (CREDIT or PARTIAL status)
    const unpaidInventory = await prisma.inventory.findMany({
      where: {
        products: {
          merchantId: tenantId,
        },
        paymentStatus: {
          in: ['CREDIT', 'PARTIAL'],
        },
      },
      include: {
        products: {
          select: {
            id: true,
            name: true,
            costPrice: true,
          },
        },
        locations: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    // Calculate totals
    let totalDebt = 0;
    let totalCredit = 0;
    let totalPartial = 0;
    const unpaidItems: any[] = [];

    unpaidInventory.forEach((entry) => {
      const totalCost = Number(entry.totalCost || 0);
      const paidAmount = Number(entry.paidAmount || 0);
      const outstandingAmount = totalCost - paidAmount;

      if (entry.paymentStatus === 'CREDIT') {
        totalCredit += outstandingAmount;
        totalDebt += outstandingAmount;
      } else if (entry.paymentStatus === 'PARTIAL') {
        totalPartial += outstandingAmount;
        totalDebt += outstandingAmount;
      }

      unpaidItems.push({
        id: entry.id,
        productId: entry.productId,
        productName: entry.products.name,
        quantity: entry.quantity,
        locationName: entry.locations.name,
        supplierName: entry.supplierName,
        supplierContact: entry.supplierContact,
        totalCost: totalCost,
        paidAmount: paidAmount,
        outstandingAmount: outstandingAmount,
        paymentStatus: entry.paymentStatus,
        paymentDueDate: entry.paymentDueDate,
        receivedDate: entry.receivedDate,
        createdAt: entry.createdAt,
      });
    });

    // Group by supplier
    const supplierDebts: Record<string, { name: string; contact?: string; totalDebt: number; items: any[] }> = {};
    
    unpaidItems.forEach((item) => {
      const supplierKey = item.supplierName || 'Unknown Supplier';
      if (!supplierDebts[supplierKey]) {
        supplierDebts[supplierKey] = {
          name: supplierKey,
          contact: item.supplierContact,
          totalDebt: 0,
          items: [],
        };
      }
      supplierDebts[supplierKey].totalDebt += item.outstandingAmount;
      supplierDebts[supplierKey].items.push(item);
    });

    return {
      totalDebt,
      totalCredit,
      totalPartial,
      unpaidCount: unpaidItems.length,
      unpaidItems: unpaidItems.sort((a, b) => {
        // Sort by payment due date (earliest first), then by date received
        if (a.paymentDueDate && b.paymentDueDate) {
          return new Date(a.paymentDueDate).getTime() - new Date(b.paymentDueDate).getTime();
        }
        if (a.paymentDueDate) return -1;
        if (b.paymentDueDate) return 1;
        return new Date(b.receivedDate).getTime() - new Date(a.receivedDate).getTime();
      }),
      supplierDebts: Object.values(supplierDebts).sort((a, b) => b.totalDebt - a.totalDebt),
    };
  }

  /**
   * Mark inventory entry as paid
   */
  async markAsPaid(req: AuthRequest, inventoryId: string, paidAmount?: number) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    // Get inventory entry and verify it belongs to the tenant
    const inventoryEntry = await prisma.inventory.findUnique({
      where: { id: inventoryId },
      include: {
        products: true,
      },
    });

    if (!inventoryEntry) {
      throw new AppError('Inventory entry not found', 404);
    }

    if (!ensureTenantAccess(req, inventoryEntry.products.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    const totalCost = Number(inventoryEntry.totalCost || 0);
    const currentPaidAmount = Number(inventoryEntry.paidAmount || 0);
    const newPaidAmount = paidAmount !== undefined ? paidAmount : totalCost;
    const outstandingAmount = totalCost - newPaidAmount;

    // Determine new payment status
    let newPaymentStatus: 'PAID' | 'CREDIT' | 'PARTIAL' = 'PAID';
    if (outstandingAmount > 0) {
      newPaymentStatus = newPaidAmount > 0 ? 'PARTIAL' : 'CREDIT';
    }

    // Update inventory entry
    const updated = await prisma.inventory.update({
      where: { id: inventoryId },
      data: {
        paymentStatus: newPaymentStatus,
        paidAmount: newPaidAmount,
        paidAt: newPaymentStatus === 'PAID' ? new Date() : inventoryEntry.paidAt,
      },
      include: {
        products: {
          select: {
            id: true,
            name: true,
          },
        },
        locations: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    return updated;
  }
}

export const inventoryStockService = new InventoryStockService();

