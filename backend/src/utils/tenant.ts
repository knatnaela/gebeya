import { AuthRequest } from '../middleware/auth.middleware';
import { UserRole } from '@prisma/client';

/**
 * Get tenant ID from request
 * Platform owners can access any tenant via query param
 * Merchant users are restricted to their own tenant
 */
export const getTenantId = (req: AuthRequest): string | null => {
  if (!req.user) {
    return null;
  }

  // Platform owners can specify merchantId in query
  if (req.user.role === UserRole.PLATFORM_OWNER && req.query.merchantId) {
    return req.query.merchantId as string;
  }

  // Merchant users use their assigned merchantId
  return req.user.merchantId || null;
};

/**
 * Ensure user has access to the specified tenant
 */
export const ensureTenantAccess = (req: AuthRequest, merchantId: string): boolean => {
  if (!req.user) {
    return false;
  }

  // Platform owners have access to all tenants
  if (req.user.role === UserRole.PLATFORM_OWNER) {
    return true;
  }

  // Merchant users can only access their own tenant
  return req.user.merchantId === merchantId;
};

