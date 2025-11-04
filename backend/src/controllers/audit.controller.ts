import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { auditService } from '../services/audit.service';
import { requirePlatformOwner } from '../middleware/auth.middleware';

export class AuditController {
  async getLogs(req: AuthRequest, res: Response): Promise<void> {
    try {
      const filters = {
        userId: req.query.userId as string | undefined,
        merchantId: req.query.merchantId as string | undefined,
        entityType: req.query.entityType as string | undefined,
        entityId: req.query.entityId as string | undefined,
        startDate: req.query.startDate ? new Date(req.query.startDate as string) : undefined,
        endDate: req.query.endDate ? new Date(req.query.endDate as string) : undefined,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
      };

      // Non-platform owners can only see their merchant's logs
      if (req.user && req.user.role !== 'PLATFORM_OWNER' && req.user.merchantId) {
        filters.merchantId = req.user.merchantId;
      }

      const result = await auditService.getLogs(filters);

      res.json({
        success: true,
        data: result.logs,
        pagination: result.pagination,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: error.message || 'Failed to fetch audit logs',
      });
    }
  }
}

export const auditController = new AuditController();

