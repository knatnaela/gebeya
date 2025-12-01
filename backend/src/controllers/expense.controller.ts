import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { expenseService, CreateExpenseData, UpdateExpenseData, ExpenseFilters } from '../services/expense.service';
import { z } from 'zod';
import { ExpenseCategory } from '@prisma/client';

// Validation schemas
const createExpenseSchema = z.object({
  category: z.nativeEnum(ExpenseCategory),
  amount: z.number().positive('Amount must be greater than 0'),
  description: z.string().optional(),
  expenseDate: z.union([
    z.string().datetime(),
    z.string().regex(/^\d{4}-\d{2}-\d{2}$/), // Date format YYYY-MM-DD
    z.date(),
  ]).optional(),
});

const updateExpenseSchema = z.object({
  category: z.nativeEnum(ExpenseCategory).optional(),
  amount: z.number().positive('Amount must be greater than 0').optional(),
  description: z.string().optional(),
  expenseDate: z.union([
    z.string().datetime(),
    z.string().regex(/^\d{4}-\d{2}-\d{2}$/), // Date format YYYY-MM-DD
    z.date(),
  ]).optional(),
});

export class ExpenseController {
  async createExpense(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = createExpenseSchema.parse(req.body);
      // Convert expenseDate string to Date if provided
      let expenseDate: Date | undefined;
      if (validatedData.expenseDate) {
        if (typeof validatedData.expenseDate === 'string') {
          // If it's a date string (YYYY-MM-DD), add time to make it a valid date
          if (/^\d{4}-\d{2}-\d{2}$/.test(validatedData.expenseDate)) {
            expenseDate = new Date(validatedData.expenseDate + 'T00:00:00');
          } else {
            expenseDate = new Date(validatedData.expenseDate);
          }
        } else {
          expenseDate = validatedData.expenseDate;
        }
      }
      const expenseData: CreateExpenseData = {
        ...validatedData,
        expenseDate,
      };
      const expense = await expenseService.createExpense(req, expenseData);

      res.status(201).json({
        success: true,
        data: expense,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }

      res.status((error as any).statusCode || 500).json({
        success: false,
        error: (error as any).message || 'Failed to create expense',
      });
    }
  }

  async getExpenses(req: AuthRequest, res: Response): Promise<void> {
    try {
      const filters: ExpenseFilters = {
        startDate: req.query.startDate ? new Date(req.query.startDate as string) : undefined,
        endDate: req.query.endDate ? new Date(req.query.endDate as string) : undefined,
        category: req.query.category ? (req.query.category as ExpenseCategory) : undefined,
        minAmount: req.query.minAmount ? parseFloat(req.query.minAmount as string) : undefined,
        maxAmount: req.query.maxAmount ? parseFloat(req.query.maxAmount as string) : undefined,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
      };

      const result = await expenseService.getExpenses(req, filters);

      res.json({
        success: true,
        data: result.expenses,
        pagination: result.pagination,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch expenses',
      });
    }
  }

  async getExpenseById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const expense = await expenseService.getExpenseById(req, id);

      res.json({
        success: true,
        data: expense,
      });
    } catch (error: any) {
      res.status(error.statusCode || 404).json({
        success: false,
        error: error.message || 'Expense not found',
      });
    }
  }

  async updateExpense(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const validatedData = updateExpenseSchema.parse(req.body);
      // Convert expenseDate string to Date if provided
      let expenseDate: Date | undefined;
      if (validatedData.expenseDate) {
        if (typeof validatedData.expenseDate === 'string') {
          // If it's a date string (YYYY-MM-DD), add time to make it a valid date
          if (/^\d{4}-\d{2}-\d{2}$/.test(validatedData.expenseDate)) {
            expenseDate = new Date(validatedData.expenseDate + 'T00:00:00');
          } else {
            expenseDate = new Date(validatedData.expenseDate);
          }
        } else {
          expenseDate = validatedData.expenseDate;
        }
      }
      const expenseData: UpdateExpenseData = {
        ...validatedData,
        expenseDate,
      };
      const expense = await expenseService.updateExpense(req, id, expenseData);

      res.json({
        success: true,
        data: expense,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }

      res.status((error as any).statusCode || 500).json({
        success: false,
        error: (error as any).message || 'Failed to update expense',
      });
    }
  }

  async deleteExpense(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      await expenseService.deleteExpense(req, id);

      res.json({
        success: true,
        message: 'Expense deleted successfully',
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to delete expense',
      });
    }
  }

  async getExpensesAnalytics(req: AuthRequest, res: Response): Promise<void> {
    try {
      const startDate = req.query.startDate ? new Date(req.query.startDate as string) : undefined;
      const endDate = req.query.endDate ? new Date(req.query.endDate as string) : undefined;

      const analytics = await expenseService.getExpensesAnalytics(req, startDate, endDate);

      res.json({
        success: true,
        data: analytics,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch expense analytics',
      });
    }
  }
}

export const expenseController = new ExpenseController();

