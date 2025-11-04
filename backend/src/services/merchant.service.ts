import { prisma } from '../lib/db';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';
import bcrypt from 'bcryptjs';
import { MerchantStatus, UserRole } from '@prisma/client';
import { subscriptionService } from './subscription.service';

export interface CreateMerchantData {
  name: string;
  email: string;
  phone?: string;
  address?: string;
  companyId?: string;
}

export interface RegisterMerchantData {
  name: string;
  email: string;
  phone?: string;
  address?: string;
  password: string;
  firstName: string;
  lastName?: string;
}

export interface UpdateMerchantData extends Partial<CreateMerchantData> {
  isActive?: boolean;
}

export interface MerchantFilters {
  search?: string;
  isActive?: boolean;
  companyId?: string;
  page?: number;
  limit?: number;
}

export class MerchantService {
  /**
   * Get all merchants (platform owner only)
   */
  async getMerchants(req: AuthRequest, filters: MerchantFilters) {
    if (req.user?.role !== 'PLATFORM_OWNER') {
      throw new AppError('Access denied', 403);
    }

    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {};

    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { email: { contains: filters.search, mode: 'insensitive' } },
      ];
    }

    if (filters.isActive !== undefined) {
      where.isActive = filters.isActive;
    }

    if (filters.companyId) {
      where.companyId = filters.companyId;
    } else if (req.user?.companyId) {
      where.companyId = req.user.companyId;
    }

    const [merchants, total] = await Promise.all([
      prisma.merchants.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          _count: {
            select: {
              products: true,
              sales: true,
              users: true,
            },
          },
        },
      }),
      prisma.merchants.count({ where }),
    ]);

    return {
      merchants,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get merchant by ID
   */
  async getMerchantById(req: AuthRequest, merchantId: string) {
    const merchant = await prisma.merchants.findUnique({
      where: { id: merchantId },
      include: {
        _count: {
          select: {
            products: true,
            sales: true,
            users: true,
          },
        },
        companies: true,
      },
    });

    if (!merchant) {
      throw new AppError('Merchant not found', 404);
    }

    // Platform owners can see all, merchants can only see themselves
    if (req.user?.role !== 'PLATFORM_OWNER' && req.user?.merchantId !== merchantId) {
      throw new AppError('Access denied', 403);
    }

    return merchant;
  }

  /**
   * Get merchant analytics
   */
  async getMerchantAnalytics(req: AuthRequest, merchantId: string) {
    if (req.user?.role !== 'PLATFORM_OWNER') {
      throw new AppError('Access denied', 403);
    }

    const merchant = await this.getMerchantById(req, merchantId);

    // Get sales analytics
    const salesData = await prisma.sales.aggregate({
      where: { merchantId },
      _sum: { totalAmount: true },
      _count: true,
    });

    // Get product count
    const productCount = await prisma.products.count({
      where: { merchantId, isActive: true },
    });

    // Get low stock count using computed stock
    const products = await prisma.products.findMany({
      where: { merchantId, isActive: true },
      select: { id: true, lowStockThreshold: true },
    });

    // Get default location for stock calculation
    const defaultLocation = await prisma.locations.findFirst({
      where: { merchantId, isDefault: true, isActive: true },
    });

    let lowStockCount = 0;
    if (defaultLocation) {
      const { inventoryStockService } = await import('./inventory-stock.service');
      const productIds = products.map((p) => p.id);
      const stockMap = await inventoryStockService.getCurrentStockForProducts(
        productIds,
        defaultLocation.id
      );

      lowStockCount = products.filter((p) => {
        const currentStock = stockMap[p.id] || 0;
        return currentStock <= p.lowStockThreshold;
      }).length;
    }

    return {
      merchant: {
        id: merchant.id,
        name: merchant.name,
        email: merchant.email,
        isActive: merchant.isActive,
      },
      totalSales: salesData._count,
      totalRevenue: salesData._sum.totalAmount || 0,
      totalProducts: productCount,
      lowStockProducts: lowStockCount,
      totalUsers: merchant._count.users,
    };
  }

  /**
   * Get platform-wide analytics
   */
  async getPlatformAnalytics(req: AuthRequest) {
    if (req.user?.role !== 'PLATFORM_OWNER') {
      throw new AppError('Access denied', 403);
    }

    const companyId = req.user.companyId;
    if (!companyId) {
      throw new AppError('Company ID not found', 400);
    }

    const merchants = await prisma.merchants.findMany({
      where: { companyId },
      include: {
        _count: {
          select: {
            products: true,
            sales: true,
            users: true,
          },
        },
      },
    });

    const totalMerchants = merchants.length;
    const activeMerchants = merchants.filter((m) => m.isActive).length;

    // Aggregate sales data
    const salesData = await prisma.sales.aggregate({
      where: {
        merchants: {
          companyId,
        },
      },
      _sum: { totalAmount: true, platformFee: true },
      _count: true,
    });

    // Get top performing merchants
    const merchantSales = await prisma.sales.groupBy({
      by: ['merchantId'],
      where: {
        merchants: {
          companyId,
        },
      },
      _sum: { totalAmount: true, platformFee: true },
      _count: true,
    });

    const topMerchants = await Promise.all(
      merchantSales
        .sort((a, b) => Number(b._sum.totalAmount || 0) - Number(a._sum.totalAmount || 0))
        .slice(0, 5)
        .map(async (m) => {
          const merchant = await prisma.merchants.findUnique({
            where: { id: m.merchantId },
            select: { id: true, name: true, email: true },
          });
          return {
            merchant,
            totalSales: m._count,
            totalRevenue: m._sum.totalAmount || 0,
          };
        })
    );

    // Calculate platform revenue from transaction fees
    const platformRevenue = salesData._sum.platformFee || 0;

    return {
      totalMerchants,
      activeMerchants,
      totalSales: salesData._count,
      totalRevenue: salesData._sum.totalAmount || 0, // Total merchant revenue (aggregate of all sales)
      platformRevenue: Number(platformRevenue), // Platform revenue from transaction fees
      topMerchants,
    };
  }

  /**
   * Register a new merchant (public endpoint - self-registration)
   */
  async registerMerchant(data: RegisterMerchantData) {
    const { name, email, phone, address, password, firstName, lastName } = data;

    // Check if merchant with this email already exists
    const existingMerchant = await prisma.merchants.findUnique({
      where: { email },
    });

    if (existingMerchant) {
      throw new AppError('Merchant with this email already exists', 400);
    }

    // Check if user with this email already exists
    const existingUser = await prisma.users.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new AppError('User with this email already exists', 400);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create merchant and user in a transaction
    const result = await prisma.$transaction(async (tx) => {
      // Generate a cuid-like ID
      const generateId = () => {
        const timestamp = Date.now().toString(36);
        const randomStr = Math.random().toString(36).substring(2, 15);
        return `cl${timestamp}${randomStr}`;
      };

      // Create merchant with PENDING_APPROVAL status
      const merchant = await tx.merchants.create({
        data: {
          id: generateId(),
          name,
          email,
          phone,
          address,
          status: MerchantStatus.PENDING_APPROVAL,
          isActive: false, // Inactive until approved
          updatedAt: new Date(),
        },
      });

      // Create user account (inactive until merchant is approved)
      const user = await tx.users.create({
        data: {
          id: generateId(),
          email,
          password: hashedPassword,
          firstName,
          lastName,
          role: UserRole.MERCHANT_ADMIN,
          merchantId: merchant.id,
          isActive: false,
          updatedAt: new Date(), // Inactive until merchant is approved
        },
      });

      return { merchant, user };
    });

    return {
      merchant: {
        id: result.merchant.id,
        name: result.merchant.name,
        email: result.merchant.email,
        status: result.merchant.status,
      },
      message: 'Merchant registration submitted. Awaiting platform owner approval.',
    };
  }

  /**
   * Get pending merchant registrations (platform owner only)
   */
  async getPendingMerchants(req: AuthRequest) {
    if (req.user?.role !== 'PLATFORM_OWNER') {
      throw new AppError('Access denied', 403);
    }

    const companyId = req.user.companyId;
    const where: any = {
      status: MerchantStatus.PENDING_APPROVAL,
    };

    if (companyId) {
      where.companyId = companyId;
    }

    const merchants = await prisma.merchants.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        users: {
          where: { role: UserRole.MERCHANT_ADMIN },
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
            isActive: true,
          },
        },
      },
    });

    return merchants;
  }

  /**
   * Approve a merchant (platform owner only)
   * Activates merchant, activates user account, and creates trial subscription
   * Uses default trial period and transaction fee rate from platform settings
   */
  async approveMerchant(req: AuthRequest, merchantId: string) {
    if (req.user?.role !== 'PLATFORM_OWNER') {
      throw new AppError('Access denied', 403);
    }

    const companyId = req.user.companyId;
    if (!companyId) {
      throw new AppError('Company ID not found', 400);
    }

    const merchant = await prisma.merchants.findUnique({
      where: { id: merchantId },
      include: {
        users: {
          where: { role: UserRole.MERCHANT_ADMIN },
        },
      },
    });

    if (!merchant) {
      throw new AppError('Merchant not found', 404);
    }

    if (merchant.status !== MerchantStatus.PENDING_APPROVAL) {
      throw new AppError('Merchant is not pending approval', 400);
    }

    // Approve merchant, activate it, assign to company, and activate user accounts
    const result = await prisma.$transaction(async (tx) => {
      // Update merchant status to ACTIVE and assign to company
      const updatedMerchant = await tx.merchants.update({
        where: { id: merchantId },
        data: {
          status: MerchantStatus.ACTIVE,
          isActive: true,
          companyId,
        },
      });

      // Activate all merchant admin users
      await tx.users.updateMany({
        where: {
          merchantId,
          role: UserRole.MERCHANT_ADMIN,
        },
        data: {
          isActive: true,
        },
      });

      return updatedMerchant;
    });

    // Create trial subscription using platform settings defaults from database
    try {
      const subscription = await subscriptionService.createTrial({
        merchantId: result.id,
        // Not providing trialPeriodDays or transactionFeeRate - createTrial will fetch defaults from platform_settings
      });

      if (!subscription) {
        throw new AppError('Failed to create trial subscription - no subscription returned', 500);
      }

      return {
        merchant: result,
        message: 'Merchant approved and trial subscription created',
      };
    } catch (error: any) {
      // If subscription creation fails, we should still have approved the merchant
      // But we need to report the error
      if (error instanceof AppError) {
        throw new AppError(`Merchant approved but failed to create trial subscription: ${error.message}`, error.statusCode || 500);
      }
      throw new AppError(`Merchant approved but failed to create trial subscription: ${error?.message || 'Unknown error'}`, 500);
    }
  }

  /**
   * Reject a merchant (platform owner only)
   */
  async rejectMerchant(req: AuthRequest, merchantId: string) {
    if (req.user?.role !== 'PLATFORM_OWNER') {
      throw new AppError('Access denied', 403);
    }

    const merchant = await prisma.merchants.findUnique({
      where: { id: merchantId },
    });

    if (!merchant) {
      throw new AppError('Merchant not found', 404);
    }

    if (merchant.status !== MerchantStatus.PENDING_APPROVAL) {
      throw new AppError('Merchant is not pending approval', 400);
    }

    const updatedMerchant = await prisma.merchants.update({
      where: { id: merchantId },
      data: {
        status: MerchantStatus.INACTIVE,
        isActive: false,
      },
    });

    return {
      merchant: updatedMerchant,
      message: 'Merchant registration rejected',
    };
  }
}

export const merchantService = new MerchantService();

