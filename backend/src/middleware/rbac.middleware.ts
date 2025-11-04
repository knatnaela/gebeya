import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth.middleware';
import { AppError } from './error.middleware';
import { permissionService } from '../services/permission.service';

/**
 * Middleware to require feature access
 * @param featureSlug - Feature slug to check
 * @param action - Optional action to check (e.g., "create", "edit", "delete")
 */
export const requireFeature = (featureSlug: string, action?: string) => {
  return async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: 'Authentication required',
        });
        return;
      }

      const hasPermission = await permissionService.checkPermission(
        req.user.userId,
        featureSlug,
        action
      );

      if (!hasPermission) {
        res.status(403).json({
          success: false,
          error: 'Insufficient permissions',
          details: {
            feature: featureSlug,
            action: action || 'view',
            message: 'You do not have permission to access this resource',
          },
        });
        return;
      }

      next();
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: error.message || 'Permission check failed',
      });
    }
  };
};

/**
 * Middleware alias for action-level permission checks
 */
export const requirePermission = (featureSlug: string, action: string) => {
  return requireFeature(featureSlug, action);
};

/**
 * Middleware to check if user must change password
 * Blocks access except for password change endpoint
 */
export const requirePasswordChange = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: 'Authentication required',
      });
      return;
    }

    // Allow password change endpoint
    if (req.path === '/change-password' || req.path.endsWith('/change-password')) {
      next();
      return;
    }

    const { userService } = await import('../services/user.service');
    const requiresChange = await userService.requiresPasswordChange(req.user.userId);

    if (requiresChange) {
      res.status(403).json({
        success: false,
        error: 'Password change required',
        details: {
          message: 'You must change your password before accessing the system',
          requiresPasswordChange: true,
        },
      });
      return;
    }

    next();
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message || 'Password check failed',
    });
  }
};

