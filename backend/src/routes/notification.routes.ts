import { Router } from 'express';
import { notificationController } from '../controllers/notification.controller';
import { authenticate, requireMerchantAccess } from '../middleware/auth.middleware';
import { requireTenant } from '../middleware/tenant.middleware';

const router = Router();

// All notification routes require authentication
router.use(authenticate);
router.use(requireTenant);
router.use(requireMerchantAccess);

// Manual trigger endpoints (for testing)
router.post('/trigger/daily-summary', notificationController.triggerDailySummary.bind(notificationController));

export default router;

