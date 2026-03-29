import { prisma } from '../lib/db';
import { getTenantId, ensureTenantAccess } from '../utils/tenant';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';
import { Prisma, SaleStatus } from '@prisma/client';
import { auditService } from './audit.service';
import { AuditAction } from '@prisma/client';
import { subscriptionService } from './subscription.service';
import { inventoryStockService } from './inventory-stock.service';
import { inventoryFifoService } from './inventory-fifo.service';
import { locationService } from './location.service';
import { expenseService } from './expense.service';
import { toCustomerDbPhoneFieldsOrThrow } from '../utils/phone';

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
  customerPhoneCountryIso?: string;
  customerPhoneNationalNumber?: string;
  /** @deprecated Prefer structured fields */
  customerPhone?: string;
}

export interface SalesFilters {
  startDate?: Date;
  endDate?: Date;
  minAmount?: number;
  maxAmount?: number;
  userId?: string;
  locationId?: string;
  page?: number;
  limit?: number;
}

/** SQL fragment for `sales` rows scoped by merchant + optional saleDate range (analytics). */
function buildSalesAnalyticsWhereSql(
  merchantId: string,
  startDate?: Date,
  endDate?: Date
): Prisma.Sql {
  const parts: Prisma.Sql[] = [
    Prisma.sql`s."merchantId" = ${merchantId}`,
    Prisma.sql`s."status" = 'COMPLETED'`,
  ];
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

    // Calculate platform transaction fee
    const platformFee = await subscriptionService.calculateTransactionFee(totalAmount, tenantId);

    let customerPhoneFields;
    try {
      customerPhoneFields = toCustomerDbPhoneFieldsOrThrow({
        customerPhoneCountryIso: data.customerPhoneCountryIso,
        customerPhoneNationalNumber: data.customerPhoneNationalNumber,
        customerPhoneLegacy: data.customerPhone,
      });
    } catch (e) {
      throw new AppError(e instanceof Error ? e.message : 'Invalid customer phone', 400);
    }

    const { result, costOfGoodsSold } = await prisma.$transaction(async (tx) => {
      const generateId = () => {
        const timestamp = Date.now().toString(36);
        const randomStr = Math.random().toString(36).substring(2, 15);
        return `cl${timestamp}${randomStr}`;
      };

      const lineData: Array<{
        lineCogs: number;
        allocations: Awaited<ReturnType<typeof inventoryFifoService.allocateFifo>>;
      }> = [];

      for (const item of data.items) {
        const product = products.find((p) => p.id === item.productId)!;
        let allocations;
        try {
          allocations = await inventoryFifoService.allocateFifo(tx, {
            productId: item.productId,
            locationId,
            quantity: item.quantity,
            fallbackUnitCost: Number(product.costPrice),
          });
        } catch (err) {
          if (err instanceof AppError && err.statusCode === 400) {
            throw new AppError(
              `Insufficient stock for ${product.name} (FIFO allocation failed).`,
              400
            );
          }
          throw err;
        }
        const lineCogs =
          Math.round(allocations.reduce((s, a) => s + a.totalCost, 0) * 100) / 100;
        lineData.push({ lineCogs, allocations });
      }

      const costOfGoodsSoldInner = lineData.reduce((s, ld) => s + ld.lineCogs, 0);

      const saleItemIds = data.items.map(() => generateId());

      const sale = await tx.sales.create({
        data: {
          id: generateId(),
          merchantId: tenantId,
          userId: req.user!.userId,
          locationId,
          totalAmount,
          platformFee,
          saleDate: data.saleDate || new Date(),
          customerName: data.customerName || null,
          customerPhoneCountryIso: customerPhoneFields.customerPhoneCountryIso,
          customerPhoneDialCode: customerPhoneFields.customerPhoneDialCode,
          customerPhoneNationalNumber: customerPhoneFields.customerPhoneNationalNumber,
          customerPhone: customerPhoneFields.customerPhone,
          notes: data.notes,
          updatedAt: new Date(),
          status: SaleStatus.COMPLETED,
          sale_items: {
            create: data.items.map((item, idx) => {
              const product = products.find((p) => p.id === item.productId);
              return {
                id: saleItemIds[idx],
                productId: item.productId,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                defaultPrice: product ? Number(product.price) : item.unitPrice,
                totalPrice: item.quantity * item.unitPrice,
                cogsAmount: lineData[idx].lineCogs,
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

      for (let i = 0; i < data.items.length; i++) {
        for (const alloc of lineData[i].allocations) {
          await tx.saleItemConsumption.create({
            data: {
              id: generateId(),
              saleItemId: saleItemIds[i],
              inventoryId: alloc.inventoryId,
              quantity: alloc.quantity,
              unitCost: alloc.unitCost,
              totalCost: alloc.totalCost,
            },
          });
        }
      }

      return { result: sale, costOfGoodsSold: costOfGoodsSoldInner };
    });

    const netIncome = totalAmount - costOfGoodsSold;
    const profitMargin = totalAmount > 0 ? (netIncome / totalAmount) * 100 : 0;

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
   * Void a sale: restore inventory from FIFO consumption rows and mark sale VOIDED.
   */
  async voidSale(req: AuthRequest, saleId: string, data?: { reason?: string }) {
    const tenantId = getTenantId(req);

    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    if (!req.user?.userId) {
      throw new AppError('User ID is required', 400);
    }

    const sale = await prisma.sales.findUnique({
      where: { id: saleId },
      include: {
        sale_items: { select: { id: true } },
      },
    });

    if (!sale) {
      throw new AppError('Sale not found', 404);
    }

    if (!ensureTenantAccess(req, sale.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    if (sale.status === SaleStatus.VOIDED) {
      return this.getSaleById(req, saleId);
    }

    const consumptions = await prisma.saleItemConsumption.findMany({
      where: {
        reversedAt: null,
        sale_items: { saleId },
      },
      orderBy: { id: 'asc' },
    });

    await prisma.$transaction(async (tx) => {
      for (const row of consumptions) {
        await tx.inventory.update({
          where: { id: row.inventoryId },
          data: { remainingQuantity: { increment: row.quantity } },
        });
        await tx.saleItemConsumption.update({
          where: { id: row.id },
          data: { reversedAt: new Date() },
        });
      }

      await tx.sales.update({
        where: { id: saleId },
        data: {
          status: SaleStatus.VOIDED,
          voidedAt: new Date(),
          voidReason: data?.reason ?? null,
          voidedByUserId: req.user!.userId,
          updatedAt: new Date(),
        },
      });
    });

    if (req.user?.userId) {
      await auditService.createLog({
        userId: req.user.userId,
        merchantId: tenantId,
        action: AuditAction.UPDATE,
        entityType: 'Sale',
        entityId: saleId,
        changes: { after: { status: 'VOIDED', voidReason: data?.reason } },
      });
    }

    return this.getSaleById(req, saleId);
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

    if (filters.locationId) {
      where.locationId = filters.locationId;
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
          locations: {
            select: {
              id: true,
              name: true,
            },
          },
          voidedBy: {
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
      const costOfGoodsSold =
        sale.status === SaleStatus.VOIDED
          ? 0
          : sale.sale_items.reduce((sum, item) => {
              const legacy = item.quantity * Number(item.products.costPrice || 0);
              const cogs =
                item.cogsAmount != null ? Number(item.cogsAmount) : legacy;
              return sum + cogs;
            }, 0);
      const netIncome =
        sale.status === SaleStatus.VOIDED
          ? 0
          : Number(sale.totalAmount) - costOfGoodsSold;
      const profitMargin =
        sale.status === SaleStatus.VOIDED || Number(sale.totalAmount) === 0
          ? 0
          : (netIncome / Number(sale.totalAmount)) * 100;

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
            phoneCountryIso: true,
            phoneDialCode: true,
            phoneNationalNumber: true,
            phone: true,
            address: true,
          },
        },
        locations: {
          select: {
            id: true,
            name: true,
          },
        },
        voidedBy: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
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
    const costOfGoodsSold =
      sale.status === SaleStatus.VOIDED
        ? 0
        : sale.sale_items.reduce((sum, item) => {
            const legacy = item.quantity * Number(item.products.costPrice || 0);
            const cogs =
              item.cogsAmount != null ? Number(item.cogsAmount) : legacy;
            return sum + cogs;
          }, 0);
    const netIncome =
      sale.status === SaleStatus.VOIDED
        ? 0
        : Number(sale.totalAmount) - costOfGoodsSold;
    const profitMargin =
      sale.status === SaleStatus.VOIDED || Number(sale.totalAmount) === 0
        ? 0
        : (netIncome / Number(sale.totalAmount)) * 100;

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
      status: SaleStatus.COMPLETED,
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
        SELECT COALESCE(
          SUM(COALESCE(si."cogsAmount", si.quantity * p."costPrice")),
          0
        ) AS cogs
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
        Prisma.sql`s."status" = 'COMPLETED'`,
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

