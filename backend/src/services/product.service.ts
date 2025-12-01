import { prisma } from '../lib/db';
import { getTenantId, ensureTenantAccess } from '../utils/tenant';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';
import { auditService } from './audit.service';
import { AuditAction } from '@prisma/client';
import { inventoryStockService } from './inventory-stock.service';
import { locationService } from './location.service';

export interface CreateProductData {
  name: string;
  brand?: string;
  size?: string;
  price: number;  // Selling price
  costPrice: number;  // Purchase/bought price
  sku?: string;
  barcode?: string;
  description?: string;
  lowStockThreshold?: number;
  imageUrl?: string;
}

export interface UpdateProductData extends Partial<CreateProductData> {
  isActive?: boolean;
}

export interface ProductFilters {
  search?: string;
  brand?: string;
  minPrice?: number;
  maxPrice?: number;
  lowStock?: boolean;
  inStock?: boolean; // Products with stock > 0
  outOfStock?: boolean; // Products with stock = 0
  minStock?: number; // Minimum stock quantity
  maxStock?: number; // Maximum stock quantity
  isActive?: boolean;
  page?: number;
  limit?: number;
}

export class ProductService {
  async createProduct(req: AuthRequest, data: CreateProductData) {
    const tenantId = getTenantId(req);

    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    // Check if SKU or barcode already exists for this merchant
    if (data.sku) {
      const existingSku = await prisma.products.findFirst({
        where: {
          merchantId: tenantId,
          sku: data.sku,
        },
      });

      if (existingSku) {
        throw new AppError('Product with this SKU already exists', 400);
      }
    }

    if (data.barcode) {
      const existingBarcode = await prisma.products.findFirst({
        where: {
          merchantId: tenantId,
          barcode: data.barcode,
        },
      });

      if (existingBarcode) {
        throw new AppError('Product with this barcode already exists', 400);
      }
    }

    // Generate a cuid-like ID
    const generateId = () => {
      const timestamp = Date.now().toString(36);
      const randomStr = Math.random().toString(36).substring(2, 15);
      return `cl${timestamp}${randomStr}`;
    };

    const product = await prisma.products.create({
      data: {
        id: generateId(),
        merchantId: tenantId,
        name: data.name,
        brand: data.brand,
        size: data.size,
        price: data.price,
        costPrice: data.costPrice,
        sku: data.sku,
        barcode: data.barcode,
        description: data.description,
        lowStockThreshold: data.lowStockThreshold || 5,
        imageUrl: data.imageUrl,
        updatedAt: new Date(),
      },
    });

    // Log audit entry
    if (req.user?.userId) {
      await auditService.createLog({
        userId: req.user.userId,
        merchantId: tenantId,
        action: AuditAction.CREATE,
        entityType: 'Product',
        entityId: product.id,
        changes: { after: product },
      });
    }

    return product;
  }

  async getProducts(req: AuthRequest, filters: ProductFilters) {
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

    // Apply filters
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { brand: { contains: filters.search, mode: 'insensitive' } },
        { sku: { contains: filters.search, mode: 'insensitive' } },
        { barcode: { contains: filters.search, mode: 'insensitive' } },
      ];
    }

    if (filters.brand) {
      where.brand = { equals: filters.brand, mode: 'insensitive' };
    }

    if (filters.minPrice !== undefined || filters.maxPrice !== undefined) {
      where.price = {};
      if (filters.minPrice !== undefined) {
        where.price.gte = filters.minPrice;
      }
      if (filters.maxPrice !== undefined) {
        where.price.lte = filters.maxPrice;
      }
    }

    if (filters.isActive !== undefined) {
      where.isActive = filters.isActive;
    }

    // Check if stock filters are applied
    const hasStockFilters = filters.lowStock || filters.inStock || filters.outOfStock ||
      filters.minStock !== undefined || filters.maxStock !== undefined;

    let products: any[];
    let total: number;

    if (hasStockFilters) {
      // When stock filters are applied, we need to:
      // 1. Fetch all products matching base filters (without pagination)
      // 2. Calculate stock for all products
      // 3. Filter by stock
      // 4. Then apply pagination

      const allProducts = await prisma.products.findMany({
        where,
        orderBy: { createdAt: 'desc' },
      });

      const defaultLocation = await locationService.getDefaultLocation(req);
      const productIds = allProducts.map((p) => p.id);
      const stockMap = await inventoryStockService.getCurrentStockForProducts(
        productIds,
        defaultLocation.id
      );

      // Filter by stock
      const filteredProducts = allProducts.filter((p) => {
        const currentStock = stockMap[p.id] || 0;

        // Low stock filter
        if (filters.lowStock && currentStock > p.lowStockThreshold) {
          return false;
        }

        // In stock filter (stock > 0)
        if (filters.inStock && currentStock <= 0) {
          return false;
        }

        // Out of stock filter (stock = 0)
        if (filters.outOfStock && currentStock > 0) {
          return false;
        }

        // Minimum stock filter
        if (filters.minStock !== undefined && currentStock < filters.minStock) {
          return false;
        }

        // Maximum stock filter
        if (filters.maxStock !== undefined && currentStock > filters.maxStock) {
          return false;
        }

        return true;
      });

      total = filteredProducts.length;

      // Apply pagination after stock filtering
      products = filteredProducts.slice(skip, skip + limit);
    } else {
      // No stock filters - use normal pagination
      products = await prisma.products.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      });

      total = await prisma.products.count({ where });
    }

    return {
      products,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getProductById(req: AuthRequest, productId: string) {
    const product = await prisma.products.findUnique({
      where: { id: productId },
    });

    if (!product) {
      throw new AppError('Product not found', 404);
    }

    if (!ensureTenantAccess(req, product.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    return product;
  }

  async updateProduct(req: AuthRequest, productId: string, data: UpdateProductData) {
    const product = await this.getProductById(req, productId);

    // Check SKU/barcode uniqueness if being updated
    if (data.sku && data.sku !== product.sku) {
      const existing = await prisma.products.findFirst({
        where: {
          merchantId: product.merchantId,
          sku: data.sku,
          id: { not: productId },
        },
      });

      if (existing) {
        throw new AppError('Product with this SKU already exists', 400);
      }
    }

    if (data.barcode && data.barcode !== product.barcode) {
      const existing = await prisma.products.findFirst({
        where: {
          merchantId: product.merchantId,
          barcode: data.barcode,
          id: { not: productId },
        },
      });

      if (existing) {
        throw new AppError('Product with this barcode already exists', 400);
      }
    }

    const before = { ...product };
    const updated = await prisma.products.update({
      where: { id: productId },
      data,
    });

    // Log audit entry
    if (req.user?.userId) {
      await auditService.createLog({
        userId: req.user.userId,
        merchantId: product.merchantId,
        action: AuditAction.UPDATE,
        entityType: 'Product',
        entityId: productId,
        changes: { before, after: updated },
      });
    }

    return updated;
  }

  async deleteProduct(req: AuthRequest, productId: string) {
    const product = await this.getProductById(req, productId);

    // Soft delete by setting isActive to false
    const before = { ...product };
    await prisma.products.update({
      where: { id: productId },
      data: { isActive: false },
    });

    // Log audit entry
    if (req.user?.userId) {
      await auditService.createLog({
        userId: req.user.userId,
        merchantId: product.merchantId,
        action: AuditAction.DELETE,
        entityType: 'Product',
        entityId: productId,
        changes: { before },
      });
    }

    return { message: 'Product deleted successfully' };
  }

  async getLowStockProducts(req: AuthRequest) {
    const tenantId = getTenantId(req);

    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    const products = await prisma.products.findMany({
      where: {
        merchantId: tenantId,
        isActive: true,
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

    // Filter products where currentStock <= lowStockThreshold
    const lowStockProducts = products
      .map((p) => ({
        ...p,
        stockQuantity: stockMap[p.id] || 0, // Add computed stock for compatibility
      }))
      .filter((p) => p.stockQuantity <= p.lowStockThreshold);

    return lowStockProducts;
  }
}

export const productService = new ProductService();

