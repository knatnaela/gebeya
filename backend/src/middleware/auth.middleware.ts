import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../lib/jwt';
import { JwtPayload } from '../types';
import { permissionService } from '../services/permission.service';

// Extend Express Request to include user and subscription status
export interface AuthRequest extends Request {
  user?: JwtPayload & {
    permissions?: Array<{
      featureSlug: string;
      featureId: string;
      actions: string[];
    }>;
    roles?: Array<{
      id: string;
      name: string;
      type: string;
    }>;
    requiresPasswordChange?: boolean;
  };
  subscriptionStatus?: {
    status: string;
    isActive: boolean;
    daysRemaining?: number;
    trialEndDate?: Date;
  };
}

export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'Authentication required' });
      return;
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    const decoded = verifyToken(token);

    // Load user permissions and roles
    try {
      const [permissions, roles] = await Promise.all([
        permissionService.getUserPermissions(decoded.userId),
        permissionService.getUserRoles?.(decoded.userId) || Promise.resolve([]),
      ]);

      // Check if password change is required
      const { userService } = await import('../services/user.service');
      const requiresPasswordChange = await userService.requiresPasswordChange(decoded.userId);

      req.user = {
        ...decoded,
        permissions,
        roles: roles.map((r: any) => ({
          id: r.id,
          name: r.name,
          type: r.type,
        })),
        requiresPasswordChange,
      };
    } catch (error) {
      // If permission loading fails, continue with basic user info
      req.user = decoded;
    }

    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid or expired token' });
    return;
  }
};

// Role-based authorization middleware
export const authorize = (...allowedRoles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ error: 'Authentication required' });
      return;
    }

    if (!allowedRoles.includes(req.user.role)) {
      res.status(403).json({ error: 'Insufficient permissions' });
      return;
    }

    next();
  };
};

// Check if user is platform owner
export const requirePlatformOwner = authorize('PLATFORM_OWNER');

// Check if user is merchant admin or platform owner
export const requireMerchantAdmin = authorize('MERCHANT_ADMIN', 'PLATFORM_OWNER');

// Check if user is any merchant role (admin or staff) or platform owner
export const requireMerchantAccess = authorize(
  'MERCHANT_ADMIN',
  'MERCHANT_STAFF',
  'PLATFORM_OWNER'
);

