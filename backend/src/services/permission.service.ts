import { prisma } from '../lib/db';
import { roleService } from './role.service';

export interface Permission {
  featureSlug: string;
  featureId: string;
  actions: string[];
}

export class PermissionService {
  /**
   * Get all permissions for a user (from their active roles)
   */
  async getUserPermissions(userId: string): Promise<Permission[]> {
    // Get user's active role assignments
    const assignments = await prisma.user_role_assignments.findMany({
      where: {
        userId,
        isActive: true,
      },
      include: {
        roles: {
          include: {
            role_features: {
              include: {
                features: true,
              },
            },
          },
        },
      },
    });

    // Aggregate permissions from all roles
    const permissionMap = new Map<string, Permission>();

    for (const assignment of assignments) {
      for (const roleFeature of assignment.roles.role_features) {
        const feature = roleFeature.features;
        const actions = (roleFeature.actions as string[]) || [];

        if (permissionMap.has(feature.slug)) {
          // Merge actions from different roles
          const existing = permissionMap.get(feature.slug)!;
          const mergedActions = [...new Set([...existing.actions, ...actions])];
          permissionMap.set(feature.slug, {
            ...existing,
            actions: mergedActions,
          });
        } else {
          permissionMap.set(feature.slug, {
            featureSlug: feature.slug,
            featureId: feature.id,
            actions,
          });
        }
      }
    }

    return Array.from(permissionMap.values());
  }

  /**
   * Check if user has permission for a feature
   */
  async hasFeatureAccess(userId: string, featureSlug: string): Promise<boolean> {
    const permissions = await this.getUserPermissions(userId);
    return permissions.some((p) => p.featureSlug === featureSlug);
  }

  /**
   * Check if user has permission for a specific action on a feature
   */
  async hasActionAccess(userId: string, featureSlug: string, action: string): Promise<boolean> {
    const permissions = await this.getUserPermissions(userId);
    const permission = permissions.find((p) => p.featureSlug === featureSlug);
    
    if (!permission) {
      return false;
    }

    // If it's a page-level feature, having the feature means all actions are allowed
    // Otherwise, check if the specific action is in the actions array
    const feature = await prisma.features.findUnique({
      where: { slug: featureSlug },
    });

    if (!feature) {
      return false;
    }

    // Page-level features don't need action checks
    if (feature.isPageLevel) {
      return true;
    }

    // For action-level features, check if action is allowed
    return permission.actions.includes(action);
  }

  /**
   * Check if user has permission for feature + action
   */
  async checkPermission(userId: string, featureSlug: string, action?: string): Promise<boolean> {
    if (action) {
      return this.hasActionAccess(userId, featureSlug, action);
    }
    return this.hasFeatureAccess(userId, featureSlug);
  }

  /**
   * Get all features user can access
   */
  async getAccessibleFeatures(userId: string) {
    const permissions = await this.getUserPermissions(userId);
    const featureSlugs = permissions.map((p) => p.featureSlug);

    const features = await prisma.features.findMany({
      where: {
        slug: {
          in: featureSlugs,
        },
      },
      orderBy: [
        { category: 'asc' },
        { name: 'asc' },
      ],
    });

    // Map features with their permissions
    return features.map((feature) => {
      const permission = permissions.find((p) => p.featureSlug === feature.slug);
      return {
        ...feature,
        actions: permission?.actions || [],
      };
    });
  }

  /**
   * Check if user has any of the specified roles
   */
  async hasRole(userId: string, roleNames: string[]): Promise<boolean> {
    const assignments = await prisma.user_role_assignments.findMany({
      where: {
        userId,
        isActive: true,
      },
      include: {
        roles: true,
      },
    });

    return assignments.some((assignment) => roleNames.includes(assignment.roles.name));
  }

  /**
   * Get user roles (for auth middleware)
   */
  async getUserRoles(userId: string) {
    const { roleService } = await import('./role.service');
    return roleService.getUserRoles(userId);
  }
}

export const permissionService = new PermissionService();

