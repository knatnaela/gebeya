import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { inventoryService, CreateInventoryTransactionData, InventoryFilters } from '../services/inventory.service';
import { inventoryStockService, AddStockData, InventoryEntryFilters, TransferStockData } from '../services/inventory-stock.service';
import { z } from 'zod';
import { InventoryTransactionType } from '@prisma/client';

// Validation schemas
const createTransactionSchema = z.object({
  productId: z.string().min(1, 'Product ID is required'),
  locationId: z.string().optional(),
  type: z.nativeEnum(InventoryTransactionType),
  quantity: z.number().int('Quantity must be an integer').refine(
    (val) => val !== 0,
    'Quantity cannot be zero'
  ),
  reason: z.string().optional(),
  referenceId: z.string().optional(),
  referenceType: z.string().optional(),
});

const addStockSchema = z.object({
  productId: z.string().min(1, 'Product ID is required'),
  locationId: z.string().optional(),
  quantity: z.number().int().positive('Quantity must be a positive integer'),
  batchNumber: z.string().optional(),
  expirationDate: z.string().datetime().optional().transform((val) => val ? new Date(val) : undefined),
  receivedDate: z.string().datetime().optional().transform((val) => val ? new Date(val) : undefined),
  notes: z.string().optional(),
  // Payment tracking fields
  paymentStatus: z.enum(['PAID', 'CREDIT', 'PARTIAL']).optional(),
  supplierName: z.string().optional(),
  supplierContact: z.string().optional(),
  totalCost: z.number().nonnegative().optional(),
  paidAmount: z.number().nonnegative().optional(),
  paymentDueDate: z.string().datetime().optional().transform((val) => val ? new Date(val) : undefined),
});

const markAsPaidSchema = z.object({
  paidAmount: z.number().nonnegative().optional(),
});

const transferStockSchema = z.object({
  productId: z.string().min(1, 'Product ID is required'),
  fromLocationId: z.string().min(1, 'Source location ID is required'),
  toLocationId: z.string().min(1, 'Destination location ID is required'),
  quantity: z.number().int().positive('Quantity must be a positive integer'),
  notes: z.string().optional(),
});

const updateThresholdSchema = z.object({
  threshold: z.number().int().min(0, 'Threshold must be non-negative'),
});

export class InventoryController {
  async createTransaction(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = createTransactionSchema.parse(req.body);
      const transaction = await inventoryService.createTransaction(req, validatedData);

      res.status(201).json({
        success: true,
        data: transaction,
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
        error: (error as any).message || 'Failed to create inventory transaction',
      });
    }
  }

  async getTransactions(req: AuthRequest, res: Response): Promise<void> {
    try {
      const filters: InventoryFilters = {
        productId: req.query.productId as string,
        type: req.query.type as InventoryTransactionType | undefined,
        startDate: req.query.startDate ? new Date(req.query.startDate as string) : undefined,
        endDate: req.query.endDate ? new Date(req.query.endDate as string) : undefined,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
      };

      const result = await inventoryService.getTransactions(req, filters);

      res.json({
        success: true,
        data: result.transactions,
        pagination: result.pagination,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch inventory transactions',
      });
    }
  }

  async getTransactionById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const transaction = await inventoryService.getTransactionById(req, id);

      res.json({
        success: true,
        data: transaction,
      });
    } catch (error: any) {
      res.status(error.statusCode || 404).json({
        success: false,
        error: error.message || 'Transaction not found',
      });
    }
  }

  async getInventorySummary(req: AuthRequest, res: Response): Promise<void> {
    try {
      const summary = await inventoryService.getInventorySummary(req);

      res.json({
        success: true,
        data: summary,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch inventory summary',
      });
    }
  }

  async updateStockThreshold(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const validatedData = updateThresholdSchema.parse(req.body);
      const product = await inventoryService.updateStockThreshold(
        req,
        id,
        validatedData.threshold
      );

      res.json({
        success: true,
        data: product,
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
        error: (error as any).message || 'Failed to update stock threshold',
      });
    }
  }

  async addStock(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = addStockSchema.parse(req.body);
      const entry = await inventoryStockService.addStock(req, validatedData);

      res.status(201).json({
        success: true,
        data: entry,
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
        error: (error as any).message || 'Failed to add stock',
      });
    }
  }

  async getInventoryEntries(req: AuthRequest, res: Response): Promise<void> {
    try {
      const filters: InventoryEntryFilters = {
        productId: req.query.productId as string,
        locationId: req.query.locationId as string,
        batchNumber: req.query.batchNumber as string,
        startDate: req.query.startDate ? new Date(req.query.startDate as string) : undefined,
        endDate: req.query.endDate ? new Date(req.query.endDate as string) : undefined,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
      };

      const result = await inventoryStockService.getInventoryEntries(req, filters);

      res.json({
        success: true,
        data: result.entries,
        pagination: result.pagination,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch inventory entries',
      });
    }
  }

  async getCurrentStock(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { productId } = req.params;
      const locationId = req.query.locationId as string | undefined;

      const stock = await inventoryStockService.getCurrentStock(productId, locationId);

      res.json({
        success: true,
        data: {
          productId,
          locationId: locationId || null,
          stock,
        },
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch current stock',
      });
    }
  }

  async transferStock(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = transferStockSchema.parse(req.body);
      const result = await inventoryStockService.transferStock(req, validatedData);

      res.status(200).json({
        success: true,
        data: result,
        message: 'Stock transferred successfully',
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
        error: (error as any).message || 'Failed to transfer stock',
      });
    }
  }

  async getStockHistory(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { productId } = req.params;
      const locationId = req.query.locationId as string | undefined;

      const history = await inventoryStockService.getStockHistory(productId, locationId);

      res.json({
        success: true,
        data: history,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch stock history',
      });
    }
  }

  async getDebtSummary(req: AuthRequest, res: Response): Promise<void> {
    try {
      const summary = await inventoryStockService.getDebtSummary(req);

      res.json({
        success: true,
        data: summary,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to get debt summary',
      });
    }
  }

  async markAsPaid(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { inventoryId } = req.params;
      const validatedData = markAsPaidSchema.parse(req.body);
      
      const updated = await inventoryStockService.markAsPaid(req, inventoryId, validatedData.paidAmount);

      res.json({
        success: true,
        data: updated,
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
        error: (error as any).message || 'Failed to mark as paid',
      });
    }
  }
}

export const inventoryController = new InventoryController();

