import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth.middleware';

// Middleware to extract and validate tenant (merchant) ID
export const requireTenant = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  if (!req.user) {
    res.status(401).json({ error: 'Authentication required' });
    return;
  }

  // Platform owners can access all tenants via query param
  if (req.user.role === 'PLATFORM_OWNER') {
    // If merchantId is provided in query, use it
    if (req.query.merchantId) {
      req.tenantId = req.query.merchantId as string;
    }
    next();
    return;
  }

  // For merchant users, tenantId must come from their user record
  if (!req.user.merchantId) {
    res.status(403).json({ error: 'User is not associated with a merchant' });
    return;
  }

  req.tenantId = req.user.merchantId;
  next();
};

// Extend AuthRequest to include tenantId
declare global {
  namespace Express {
    interface Request {
      tenantId?: string;
    }
  }
}

