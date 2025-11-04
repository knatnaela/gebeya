import { prisma } from '../lib/db';
import { AppError } from '../middleware/error.middleware';
import { seedFeatures } from '../../prisma/seeds/features.seed';

export type RoleType = 'PLATFORM_OWNER' | 'MERCHANT';

export interface CreateFeatureData {
  name: string;
  slug: string;
  description?: string;
  type: RoleType;
  category: string;
  isPageLevel?: boolean;
  defaultActions?: string[];
}

export interface UpdateFeatureData {
  name?: string;
  description?: string;
  category?: string;
  isPageLevel?: boolean;
  defaultActions?: string[];
}

export class FeatureService {
  /**
   * Get all features, optionally filtered by type
   */
  async getAllFeatures(filters?: { type?: RoleType; category?: string }) {
    const where: any = {};

    if (filters?.type) {
      where.type = filters.type;
    }

    if (filters?.category) {
      where.category = filters.category;
    }

    const features = await prisma.features.findMany({
      where,
      orderBy: [
        { category: 'asc' },
        { name: 'asc' },
      ],
    });

    return features;
  }

  /**
   * Get feature by ID
   */
  async getFeatureById(featureId: string) {
    const feature = await prisma.features.findUnique({
      where: { id: featureId },
      include: {
        role_features: {
          include: {
            roles: {
              select: {
                id: true,
                name: true,
                type: true,
              },
            },
          },
        },
      },
    });

    if (!feature) {
      throw new AppError('Feature not found', 404);
    }

    return feature;
  }

  /**
   * Get feature by slug
   */
  async getFeatureBySlug(slug: string) {
    const feature = await prisma.features.findUnique({
      where: { slug },
    });

    if (!feature) {
      throw new AppError('Feature not found', 404);
    }

    return feature;
  }

  /**
   * Seed initial features
   */
  async seedFeatures() {
    try {
      await seedFeatures();
      return { success: true, message: 'Features seeded successfully' };
    } catch (error: any) {
      throw new AppError(`Failed to seed features: ${error.message}`, 500);
    }
  }

  /**
   * Create a new feature (platform owner only)
   */
  async createFeature(data: CreateFeatureData) {
    // Check if slug already exists
    const existingFeature = await prisma.features.findUnique({
      where: { slug: data.slug },
    });

    if (existingFeature) {
      throw new AppError('Feature with this slug already exists', 400);
    }

    // Generate a cuid-like ID
    const generateId = () => {
      const timestamp = Date.now().toString(36);
      const randomStr = Math.random().toString(36).substring(2, 15);
      return `cl${timestamp}${randomStr}`;
    };

    const feature = await prisma.features.create({
      data: {
        id: generateId(),
        name: data.name,
        slug: data.slug,
        description: data.description,
        type: data.type,
        category: data.category,
        isPageLevel: data.isPageLevel ?? true,
        defaultActions: data.defaultActions || [],
        updatedAt: new Date(),
      },
    });

    return feature;
  }

  /**
   * Update feature details
   */
  async updateFeature(featureId: string, data: UpdateFeatureData) {
    const feature = await prisma.features.findUnique({
      where: { id: featureId },
    });

    if (!feature) {
      throw new AppError('Feature not found', 404);
    }

    const updatedFeature = await prisma.features.update({
      where: { id: featureId },
      data: {
        name: data.name,
        description: data.description,
        category: data.category,
        isPageLevel: data.isPageLevel,
        defaultActions: data.defaultActions,
      },
    });

    return updatedFeature;
  }

  /**
   * Get features assigned to a role
   */
  async getFeaturesByRole(roleId: string) {
    const roleFeatures = await prisma.role_features.findMany({
      where: { roleId },
      include: {
        features: true,
      },
    });

    return roleFeatures.map((rf) => ({
      ...rf.features,
      actions: rf.actions as string[],
    }));
  }
}

export const featureService = new FeatureService();

