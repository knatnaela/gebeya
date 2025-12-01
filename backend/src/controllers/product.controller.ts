import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { productService, ProductFilters } from '../services/product.service';
import { z } from 'zod';

// Validation schemas
const createProductSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  brand: z.string().optional(),
  size: z.string().optional(),
  price: z.number().positive('Selling price must be positive'),
  costPrice: z.number().positive('Cost price must be positive'),
  sku: z.string().optional(),
  barcode: z.string().optional(),
  description: z.string().optional(),
  lowStockThreshold: z.number().int().min(0).optional(),
  imageUrl: z.string().url('Invalid image URL').optional().or(z.literal('')),
});

const updateProductSchema = createProductSchema.partial().extend({
  isActive: z.boolean().optional(),
});

export class ProductController {
  async createProduct(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = createProductSchema.parse(req.body);
      const product = await productService.createProduct(req, validatedData);

      res.status(201).json({
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
        error: (error as any).message || 'Failed to create product',
      });
    }
  }

  async getProducts(req: AuthRequest, res: Response): Promise<void> {
    try {
      const filters: ProductFilters = {
        search: req.query.search as string,
        brand: req.query.brand as string,
        minPrice: req.query.minPrice ? parseFloat(req.query.minPrice as string) : undefined,
        maxPrice: req.query.maxPrice ? parseFloat(req.query.maxPrice as string) : undefined,
        lowStock: req.query.lowStock === 'true',
        inStock: req.query.inStock === 'true',
        outOfStock: req.query.outOfStock === 'true',
        minStock: req.query.minStock ? parseInt(req.query.minStock as string, 10) : undefined,
        maxStock: req.query.maxStock ? parseInt(req.query.maxStock as string, 10) : undefined,
        isActive: req.query.isActive !== undefined ? req.query.isActive === 'true' : undefined,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
      };

      const result = await productService.getProducts(req, filters);

      res.json({
        success: true,
        data: result.products,
        pagination: result.pagination,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch products',
      });
    }
  }

  async getProductById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const product = await productService.getProductById(req, id);

      res.json({
        success: true,
        data: product,
      });
    } catch (error: any) {
      res.status(error.statusCode || 404).json({
        success: false,
        error: error.message || 'Product not found',
      });
    }
  }

  async updateProduct(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const validatedData = updateProductSchema.parse(req.body);
      const product = await productService.updateProduct(req, id, validatedData);

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
        error: (error as any).message || 'Failed to update product',
      });
    }
  }

  async deleteProduct(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const result = await productService.deleteProduct(req, id);

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to delete product',
      });
    }
  }

  async getLowStockProducts(req: AuthRequest, res: Response): Promise<void> {
    try {
      const products = await productService.getLowStockProducts(req);

      res.json({
        success: true,
        data: products,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch low stock products',
      });
    }
  }
}

export const productController = new ProductController();

