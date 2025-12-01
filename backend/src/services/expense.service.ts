import { prisma } from '../lib/db';
import { getTenantId, ensureTenantAccess } from '../utils/tenant';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';
import { ExpenseCategory } from '@prisma/client';
import { auditService } from './audit.service';
import { AuditAction } from '@prisma/client';

export interface CreateExpenseData {
  category: ExpenseCategory;
  amount: number;
  description?: string;
  expenseDate?: Date;
}

export interface UpdateExpenseData {
  category?: ExpenseCategory;
  amount?: number;
  description?: string;
  expenseDate?: Date;
}

export interface ExpenseFilters {
  startDate?: Date;
  endDate?: Date;
  category?: ExpenseCategory;
  minAmount?: number;
  maxAmount?: number;
  page?: number;
  limit?: number;
}

export class ExpenseService {
  /**
   * Create a new expense
   */
  async createExpense(req: AuthRequest, data: CreateExpenseData) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    if (!req.user?.userId) {
      throw new AppError('User ID is required', 400);
    }

    if (!data.amount || data.amount <= 0) {
      throw new AppError('Expense amount must be greater than 0', 400);
    }

    // Generate a cuid-like ID
    const generateId = () => {
      const timestamp = Date.now().toString(36);
      const randomStr = Math.random().toString(36).substring(2, 15);
      return `cl${timestamp}${randomStr}`;
    };

    const expense = await prisma.expenses.create({
      data: {
        id: generateId(),
        merchantId: tenantId,
        userId: req.user.userId,
        category: data.category,
        amount: data.amount,
        description: data.description || null,
        expenseDate: data.expenseDate || new Date(),
        updatedAt: new Date(),
      },
      include: {
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

    // Log audit entry
    if (req.user?.userId) {
      await auditService.createLog({
        userId: req.user.userId,
        merchantId: tenantId,
        action: AuditAction.CREATE,
        entityType: 'Expense',
        entityId: expense.id,
        changes: { after: expense },
      });
    }

    return expense;
  }

  /**
   * Get expenses with filters
   */
  async getExpenses(req: AuthRequest, filters: ExpenseFilters) {
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
      where.expenseDate = {};
      if (filters.startDate) {
        where.expenseDate.gte = filters.startDate;
      }
      if (filters.endDate) {
        where.expenseDate.lte = filters.endDate;
      }
    }

    if (filters.category) {
      where.category = filters.category;
    }

    if (filters.minAmount !== undefined || filters.maxAmount !== undefined) {
      where.amount = {};
      if (filters.minAmount !== undefined) {
        where.amount.gte = filters.minAmount;
      }
      if (filters.maxAmount !== undefined) {
        where.amount.lte = filters.maxAmount;
      }
    }

    const [expenses, total] = await Promise.all([
      prisma.expenses.findMany({
        where,
        skip,
        take: limit,
        orderBy: { expenseDate: 'desc' },
        include: {
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
      prisma.expenses.count({ where }),
    ]);

    return {
      expenses,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get expense by ID
   */
  async getExpenseById(req: AuthRequest, expenseId: string) {
    const expense = await prisma.expenses.findUnique({
      where: { id: expenseId },
      include: {
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

    if (!expense) {
      throw new AppError('Expense not found', 404);
    }

    if (!ensureTenantAccess(req, expense.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    return expense;
  }

  /**
   * Update expense
   */
  async updateExpense(req: AuthRequest, expenseId: string, data: UpdateExpenseData) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    // Check if expense exists and belongs to merchant
    const existingExpense = await prisma.expenses.findUnique({
      where: { id: expenseId },
    });

    if (!existingExpense) {
      throw new AppError('Expense not found', 404);
    }

    if (!ensureTenantAccess(req, existingExpense.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    if (data.amount !== undefined && data.amount <= 0) {
      throw new AppError('Expense amount must be greater than 0', 400);
    }

    const updateData: any = {
      updatedAt: new Date(),
    };

    if (data.category !== undefined) {
      updateData.category = data.category;
    }
    if (data.amount !== undefined) {
      updateData.amount = data.amount;
    }
    if (data.description !== undefined) {
      updateData.description = data.description || null;
    }
    if (data.expenseDate !== undefined) {
      updateData.expenseDate = data.expenseDate;
    }

    const expense = await prisma.expenses.update({
      where: { id: expenseId },
      data: updateData,
      include: {
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

    // Log audit entry
    if (req.user?.userId) {
      await auditService.createLog({
        userId: req.user.userId,
        merchantId: tenantId,
        action: AuditAction.UPDATE,
        entityType: 'Expense',
        entityId: expense.id,
        changes: { before: existingExpense, after: expense },
      });
    }

    return expense;
  }

  /**
   * Delete expense
   */
  async deleteExpense(req: AuthRequest, expenseId: string) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    // Check if expense exists and belongs to merchant
    const existingExpense = await prisma.expenses.findUnique({
      where: { id: expenseId },
    });

    if (!existingExpense) {
      throw new AppError('Expense not found', 404);
    }

    if (!ensureTenantAccess(req, existingExpense.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    await prisma.expenses.delete({
      where: { id: expenseId },
    });

    // Log audit entry
    if (req.user?.userId) {
      await auditService.createLog({
        userId: req.user.userId,
        merchantId: tenantId,
        action: AuditAction.DELETE,
        entityType: 'Expense',
        entityId: expenseId,
        changes: { before: existingExpense },
      });
    }

    return { success: true };
  }

  /**
   * Get expense analytics
   */
  async getExpensesAnalytics(req: AuthRequest, startDate?: Date, endDate?: Date) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    const where: any = {
      merchantId: tenantId,
    };

    if (startDate || endDate) {
      where.expenseDate = {};
      if (startDate) {
        where.expenseDate.gte = startDate;
      }
      if (endDate) {
        where.expenseDate.lte = endDate;
      }
    }

    const [totalExpenses, expensesByCategory, expenses] = await Promise.all([
      prisma.expenses.aggregate({
        where,
        _sum: {
          amount: true,
        },
        _count: {
          id: true,
        },
      }),
      prisma.expenses.groupBy({
        by: ['category'],
        where,
        _sum: {
          amount: true,
        },
        _count: {
          id: true,
        },
      }),
      prisma.expenses.findMany({
        where,
        select: {
          category: true,
          amount: true,
        },
      }),
    ]);

    return {
      totalExpenses: totalExpenses._sum.amount ? Number(totalExpenses._sum.amount) : 0,
      totalCount: totalExpenses._count.id,
      expensesByCategory: expensesByCategory.map((item) => ({
        category: item.category,
        total: Number(item._sum.amount || 0),
        count: item._count.id,
      })),
    };
  }

  /**
   * Get total expenses for a merchant in a date range
   */
  async getTotalExpenses(merchantId: string, startDate?: Date, endDate?: Date): Promise<number> {
    const where: any = {
      merchantId,
    };

    if (startDate || endDate) {
      where.expenseDate = {};
      if (startDate) {
        where.expenseDate.gte = startDate;
      }
      if (endDate) {
        where.expenseDate.lte = endDate;
      }
    }

    const result = await prisma.expenses.aggregate({
      where,
      _sum: {
        amount: true,
      },
    });

    return result._sum.amount ? Number(result._sum.amount) : 0;
  }
}

export const expenseService = new ExpenseService();

