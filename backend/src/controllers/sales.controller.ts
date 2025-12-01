import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { salesService, CreateSaleData, SalesFilters } from '../services/sales.service';
import { z } from 'zod';

// Validation schemas
const saleItemSchema = z.object({
  productId: z.string().min(1, 'Product ID is required'),
  quantity: z.number().int().positive('Quantity must be positive'),
  unitPrice: z.number().positive('Unit price must be positive'),
});

const createSaleSchema = z.object({
  items: z.array(saleItemSchema).min(1, 'Sale must have at least one item'),
  locationId: z.string().optional(), // Optional, defaults to merchant's default location
  notes: z.string().optional(),
  saleDate: z.union([
    z.string().datetime(),
    z.string().regex(/^\d{4}-\d{2}-\d{2}$/), // Date format YYYY-MM-DD
    z.date(),
  ]).optional(),
  customerName: z.string().optional(),
  customerPhone: z.string().optional(),
});

export class SalesController {
  async createSale(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = createSaleSchema.parse(req.body);
      // Convert saleDate string to Date if provided
      let saleDate: Date | undefined;
      if (validatedData.saleDate) {
        if (typeof validatedData.saleDate === 'string') {
          // If it's a date string (YYYY-MM-DD), add time to make it a valid date
          if (/^\d{4}-\d{2}-\d{2}$/.test(validatedData.saleDate)) {
            saleDate = new Date(validatedData.saleDate + 'T00:00:00');
          } else {
            saleDate = new Date(validatedData.saleDate);
          }
        } else {
          saleDate = validatedData.saleDate;
        }
      }
      const saleData = {
        ...validatedData,
        saleDate,
      };
      const sale = await salesService.createSale(req, saleData);

      res.status(201).json({
        success: true,
        data: sale,
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
        error: (error as any).message || 'Failed to create sale',
      });
    }
  }

  async getSales(req: AuthRequest, res: Response): Promise<void> {
    try {
      const filters: SalesFilters = {
        startDate: req.query.startDate ? new Date(req.query.startDate as string) : undefined,
        endDate: req.query.endDate ? new Date(req.query.endDate as string) : undefined,
        minAmount: req.query.minAmount ? parseFloat(req.query.minAmount as string) : undefined,
        maxAmount: req.query.maxAmount ? parseFloat(req.query.maxAmount as string) : undefined,
        userId: req.query.userId as string,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
      };

      const result = await salesService.getSales(req, filters);

      res.json({
        success: true,
        data: result.sales,
        pagination: result.pagination,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch sales',
      });
    }
  }

  async getSaleById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const sale = await salesService.getSaleById(req, id);

      res.json({
        success: true,
        data: sale,
      });
    } catch (error: any) {
      res.status(error.statusCode || 404).json({
        success: false,
        error: error.message || 'Sale not found',
      });
    }
  }

  async getSalesAnalytics(req: AuthRequest, res: Response): Promise<void> {
    try {
      const startDate = req.query.startDate ? new Date(req.query.startDate as string) : undefined;
      const endDate = req.query.endDate ? new Date(req.query.endDate as string) : undefined;

      const analytics = await salesService.getSalesAnalytics(req, startDate, endDate);

      res.json({
        success: true,
        data: analytics,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch sales analytics',
      });
    }
  }
}

export const salesController = new SalesController();

