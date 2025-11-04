import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { featureService } from '../services/feature.service';
import { AppError } from '../middleware/error.middleware';
import { z } from 'zod';

const createFeatureSchema = z.object({
  name: z.string().min(1, 'Feature name is required'),
  slug: z.string().min(1, 'Feature slug is required'),
  description: z.string().optional(),
  type: z.enum(['PLATFORM_OWNER', 'MERCHANT']),
  category: z.string().min(1, 'Category is required'),
  isPageLevel: z.boolean().optional(),
  defaultActions: z.array(z.string()).optional(),
});

const updateFeatureSchema = z.object({
  name: z.string().min(1).optional(),
  description: z.string().optional(),
  category: z.string().optional(),
  isPageLevel: z.boolean().optional(),
  defaultActions: z.array(z.string()).optional(),
});

export class FeatureController {
  /**
   * Get all features
   */
  async getFeatures(req: AuthRequest, res: Response): Promise<void> {
    try {
      const type = req.query.type as 'PLATFORM_OWNER' | 'MERCHANT' | undefined;
      const category = req.query.category as string | undefined;

      const features = await featureService.getAllFeatures({ type, category });

      res.json({
        success: true,
        data: features,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch features',
      });
    }
  }

  /**
   * Get feature by ID
   */
  async getFeatureById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      const feature = await featureService.getFeatureById(id);

      res.json({
        success: true,
        data: feature,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch feature',
      });
    }
  }

  /**
   * Seed features (platform owner only)
   */
  async seedFeatures(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const result = await featureService.seedFeatures();

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to seed features',
      });
    }
  }

  /**
   * Create a new feature (platform owner only)
   */
  async createFeature(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const validatedData = createFeatureSchema.parse(req.body);

      const feature = await featureService.createFeature(validatedData);

      res.json({
        success: true,
        data: feature,
      });
    } catch (error: any) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to create feature',
      });
    }
  }

  /**
   * Update feature
   */
  async updateFeature(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const { id } = req.params;
      const validatedData = updateFeatureSchema.parse(req.body);

      const feature = await featureService.updateFeature(id, validatedData);

      res.json({
        success: true,
        data: feature,
      });
    } catch (error: any) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to update feature',
      });
    }
  }
}

export const featureController = new FeatureController();

