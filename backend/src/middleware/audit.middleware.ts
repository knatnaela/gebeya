import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from './auth.middleware';
import { auditService } from '../services/audit.service';
import { AuditAction } from '@prisma/client';

/**
 * Audit middleware to log requests
 * Can be used selectively on routes that need auditing
 */
export const auditRequest = (
  action: AuditAction,
  entityType: string,
  getEntityId?: (req: AuthRequest) => string | undefined
) => {
  return async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    // Store original json method
    const originalJson = res.json.bind(res);

    // Override res.json to capture response data
    res.json = function (body: any) {
      // Get entity ID from request or response
      const entityId = getEntityId
        ? getEntityId(req)
        : req.params.id || body?.data?.id || body?.id;

      // Get changes if it's an update
      const changes =
        action === 'UPDATE' && body?.data
          ? {
              before: req.body, // This would need to be enhanced to get actual before state
              after: body.data,
            }
          : undefined;

      // Log audit entry asynchronously (don't block response)
      if (req.user) {
        auditService
          .createLog({
            userId: req.user.userId,
            merchantId: req.user.merchantId,
            action,
            entityType,
            entityId,
            changes,
            ipAddress: req.ip || req.headers['x-forwarded-for'] as string,
            userAgent: req.headers['user-agent'],
          })
          .catch((error) => {
            console.error('Audit logging failed:', error);
          });
      }

      return originalJson(body);
    };

    next();
  };
};

