import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { authService } from '../services/auth.service';
import { z } from 'zod';

// Validation schemas
const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
});

const registerSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  firstName: z.string().min(1, 'First name is required'),
  lastName: z.string().optional(),
  role: z.enum(['PLATFORM_OWNER', 'MERCHANT_ADMIN', 'MERCHANT_STAFF']),
  merchantId: z.string().optional(),
  companyId: z.string().optional(),
});

export class AuthController {
  async login(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = loginSchema.parse(req.body);
      const result = await authService.login(validatedData);

      res.json({
        success: true,
        data: result,
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

      res.status(401).json({
        success: false,
        error: error instanceof Error ? error.message : 'Login failed',
      });
    }
  }

  async register(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = registerSchema.parse(req.body);
      const result = await authService.register(validatedData);

      res.status(201).json({
        success: true,
        data: result,
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

      res.status(400).json({
        success: false,
        error: error instanceof Error ? error.message : 'Registration failed',
      });
    }
  }

  async getCurrentUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: 'Authentication required',
        });
        return;
      }

      const user = await authService.getCurrentUser(req.user.userId);

      // Include permissions and roles from req.user if available
      res.json({
        success: true,
        data: {
          ...user,
          permissions: req.user.permissions,
          roles: req.user.roles,
          requiresPasswordChange: req.user.requiresPasswordChange,
        },
      });
    } catch (error) {
      res.status(404).json({
        success: false,
        error: error instanceof Error ? error.message : 'User not found',
      });
    }
  }

  async changePassword(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: 'Authentication required',
        });
        return;
      }

      const { userController } = await import('./user.controller');
      await userController.changePassword(req, res);
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Password change failed',
      });
    }
  }
}

export const authController = new AuthController();

