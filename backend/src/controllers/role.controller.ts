import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { roleService } from '../services/role.service';
import { AppError } from '../middleware/error.middleware';
import { z } from 'zod';

const createRoleSchema = z.object({
  name: z.string().min(1, 'Role name is required'),
  description: z.string().optional(),
  type: z.enum(['PLATFORM_OWNER', 'MERCHANT']),
  hierarchyLevel: z.number().int().min(1).max(3).optional(),
  companyId: z.string().optional(),
  featureIds: z.array(z.string()).optional(),
  featureActions: z.record(z.string(), z.array(z.string())).optional(),
});

const updateRoleSchema = z.object({
  name: z.string().min(1).optional(),
  description: z.string().optional(),
  hierarchyLevel: z.number().int().min(1).max(3).optional(),
  featureIds: z.array(z.string()).optional(),
  featureActions: z.record(z.string(), z.array(z.string())).optional(),
});

export class RoleController {
  /**
   * Create a new role (platform owner only)
   */
  async createRole(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const validatedData = createRoleSchema.parse(req.body);

      const role = await roleService.createRole({
        ...validatedData,
        createdBy: req.user.userId,
        companyId: validatedData.companyId || req.user.companyId || undefined,
        featureActions: validatedData.featureActions as Record<string, string[]> | undefined,
      });

      res.json({
        success: true,
        data: role,
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
        error: error.message || 'Failed to create role',
      });
    }
  }

  /**
   * Update role
   */
  async updateRole(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const { id } = req.params;
      const validatedData = updateRoleSchema.parse(req.body);

      const role = await roleService.updateRole(id, {
        ...validatedData,
        featureActions: validatedData.featureActions as Record<string, string[]> | undefined,
      }, req.user.userId);

      res.json({
        success: true,
        data: role,
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
        error: error.message || 'Failed to update role',
      });
    }
  }

  /**
   * Delete role
   */
  async deleteRole(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const { id } = req.params;

      const result = await roleService.deleteRole(id);

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to delete role',
      });
    }
  }

  /**
   * Get all roles
   */
  async getRoles(req: AuthRequest, res: Response): Promise<void> {
    try {
      const type = req.query.type as 'PLATFORM_OWNER' | 'MERCHANT' | undefined;
      const companyId = req.query.companyId as string | undefined;

      const filters: any = {};
      if (type) filters.type = type;
      if (companyId) filters.companyId = companyId;

      const roles = await roleService.getRoles(filters);

      res.json({
        success: true,
        data: roles,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch roles',
      });
    }
  }

  /**
   * Get role by ID
   */
  async getRoleById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      const role = await roleService.getRoleById(id);

      res.json({
        success: true,
        data: role,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch role',
      });
    }
  }

  /**
   * Assign role to user
   */
  async assignRole(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params; // roleId
      const { userId } = req.body;

      if (!userId) {
        res.status(400).json({
          success: false,
          error: 'User ID is required',
        });
        return;
      }

      // Platform owners can assign any role, merchants can only assign to their users
      if (req.user?.role === 'PLATFORM_OWNER') {
        // Platform owner can assign any role
      } else if (req.user?.role === 'MERCHANT_ADMIN' && req.user?.merchantId) {
        // Merchant admin can only assign to their merchant's users
        // Check if target user belongs to same merchant
        const { userService } = await import('../services/user.service');
        const targetUser = await userService.getUserById(userId);
        
        if (targetUser.merchantId !== req.user.merchantId) {
          res.status(403).json({
            success: false,
            error: 'Access denied',
          });
          return;
        }
      } else {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const assignment = await roleService.assignRoleToUser(
        id,
        userId,
        req.user!.userId
      );

      res.json({
        success: true,
        data: assignment,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to assign role',
      });
    }
  }

  /**
   * Remove role from user
   */
  async removeRole(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id, userId } = req.params; // roleId and userId from route

      // Similar access checks as assignRole
      if (req.user?.role !== 'PLATFORM_OWNER' && req.user?.role !== 'MERCHANT_ADMIN') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const result = await roleService.removeRoleFromUser(id, userId);

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to remove role',
      });
    }
  }
}

export const roleController = new RoleController();

