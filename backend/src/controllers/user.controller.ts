import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { userService } from '../services/user.service';
import { AppError } from '../middleware/error.middleware';
import { UserRole } from '@prisma/client';
import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email('Invalid email address'),
  firstName: z.string().min(1, 'First name is required'),
  lastName: z.string().optional(),
  role: z.nativeEnum(UserRole),
  merchantId: z.string().optional(),
  companyId: z.string().optional(),
  roleIds: z.array(z.string()).optional(),
});

const updateUserSchema = z.object({
  firstName: z.string().min(1).optional(),
  lastName: z.string().optional(),
  isActive: z.boolean().optional(),
  roleIds: z.array(z.string()).optional(),
});

const changePasswordSchema = z.object({
  oldPassword: z.string().min(1, 'Current password is required'),
  newPassword: z.string().min(8, 'Password must be at least 8 characters'),
});

export class UserController {
  /**
   * Create a new user with temporary password
   */
  async createUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      // Only platform owners and merchant admins can create users
      if (req.user?.role !== 'PLATFORM_OWNER' && req.user?.role !== 'MERCHANT_ADMIN') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const validatedData = createUserSchema.parse(req.body);

      // Platform owners can create users for any company/merchant
      // Merchant admins can only create users for their own merchant
      if (req.user.role === 'MERCHANT_ADMIN') {
        if (!req.user.merchantId) {
          res.status(403).json({
            success: false,
            error: 'Merchant admin must be associated with a merchant',
          });
          return;
        }
        validatedData.merchantId = req.user.merchantId;
        validatedData.role = UserRole.MERCHANT_STAFF; // Merchant admins can only create staff
      }

      const user = await userService.createUserWithTemporaryPassword(
        validatedData,
        req.user.userId
      );

      res.json({
        success: true,
        data: user,
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
        error: error.message || 'Failed to create user',
      });
    }
  }

  /**
   * Get all users
   */
  async getUsers(req: AuthRequest, res: Response): Promise<void> {
    try {
      const merchantId = req.query.merchantId as string | undefined;
      const companyId = req.query.companyId as string | undefined;
      const isActive = req.query.isActive === 'true' ? true : req.query.isActive === 'false' ? false : undefined;
      const role = req.query.role as UserRole | undefined;

      // Access control
      if (req.user?.role === 'PLATFORM_OWNER') {
        // Platform owners can see all users
      } else if (req.user?.role === 'MERCHANT_ADMIN' && req.user?.merchantId) {
        // Merchant admins can only see users from their merchant
        if (merchantId && merchantId !== req.user.merchantId) {
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

      const filters: any = {};
      if (merchantId) filters.merchantId = merchantId;
      if (companyId) filters.companyId = companyId;
      if (isActive !== undefined) filters.isActive = isActive;
      if (role) filters.role = role;

      // For merchant admins, filter by their merchant
      if (req.user?.role === 'MERCHANT_ADMIN' && req.user?.merchantId) {
        filters.merchantId = req.user.merchantId;
      }

      const users = await userService.getUsers(filters);

      res.json({
        success: true,
        data: users,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch users',
      });
    }
  }

  /**
   * Get user by ID
   */
  async getUserById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      const user = await userService.getUserById(id);

      // Access control
      if (req.user?.role === 'PLATFORM_OWNER') {
        // Platform owners can see any user
      } else if (req.user?.role === 'MERCHANT_ADMIN' && req.user?.merchantId) {
        // Merchant admins can only see users from their merchant
        if (user.merchantId !== req.user.merchantId) {
          res.status(403).json({
            success: false,
            error: 'Access denied',
          });
          return;
        }
      } else if (req.user?.userId !== id) {
        // Users can only see themselves
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      res.json({
        success: true,
        data: user,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch user',
      });
    }
  }

  /**
   * Update user
   */
  async updateUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const validatedData = updateUserSchema.parse(req.body);

      // Access control
      if (req.user?.role === 'PLATFORM_OWNER') {
        // Platform owners can update any user
      } else if (req.user?.role === 'MERCHANT_ADMIN' && req.user?.merchantId) {
        // Merchant admins can only update users from their merchant
        const user = await userService.getUserById(id);
        if (user.merchantId !== req.user.merchantId) {
          res.status(403).json({
            success: false,
            error: 'Access denied',
          });
          return;
        }
      } else if (req.user?.userId !== id) {
        // Users can only update themselves (limited fields)
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const user = await userService.updateUser(id, validatedData, req.user!.userId);

      res.json({
        success: true,
        data: user,
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
        error: error.message || 'Failed to update user',
      });
    }
  }

  /**
   * Change password
   */
  async changePassword(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: 'Authentication required',
        });
        return;
      }

      const validatedData = changePasswordSchema.parse(req.body);

      const result = await userService.changePassword(
        req.user.userId,
        validatedData.oldPassword,
        validatedData.newPassword
      );

      res.json({
        success: true,
        data: result,
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
        error: error.message || 'Failed to change password',
      });
    }
  }

  /**
   * Assign role to user
   */
  async assignRoleToUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params; // userId
      const { roleId } = req.body;

      if (!roleId) {
        res.status(400).json({
          success: false,
          error: 'Role ID is required',
        });
        return;
      }

      // Access control similar to createUser
      if (req.user?.role === 'PLATFORM_OWNER') {
        // Platform owners can assign any role
      } else if (req.user?.role === 'MERCHANT_ADMIN' && req.user?.merchantId) {
        // Merchant admins can only assign roles to their merchant's users
        const user = await userService.getUserById(id);
        if (user.merchantId !== req.user.merchantId) {
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

      const assignment = await userService.assignRoleToUser(
        id,
        roleId,
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
  async removeRoleFromUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params; // userId
      const { roleId } = req.params; // roleId from route

      // Similar access control as assignRoleToUser
      if (req.user?.role === 'PLATFORM_OWNER') {
        // Platform owners can remove any role
      } else if (req.user?.role === 'MERCHANT_ADMIN' && req.user?.merchantId) {
        // Merchant admins can only remove roles from their merchant's users
        const user = await userService.getUserById(id);
        if (user.merchantId !== req.user.merchantId) {
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

      const result = await userService.removeRoleFromUser(id, roleId);

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

export const userController = new UserController();

