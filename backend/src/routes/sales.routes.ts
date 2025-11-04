import { Router } from 'express';
import { salesController } from '../controllers/sales.controller';
import { authenticate, requireMerchantAccess } from '../middleware/auth.middleware';
import { requireTenant } from '../middleware/tenant.middleware';
import { checkSubscriptionStatus } from '../middleware/subscription.middleware';

const router = Router();

// All sales routes require authentication and merchant access
router.use(authenticate);
router.use(requireTenant);
router.use(requireMerchantAccess);
router.use(checkSubscriptionStatus); // Block access if subscription is expired

// Routes
router.post('/', salesController.createSale.bind(salesController));
router.get('/', salesController.getSales.bind(salesController));
router.get('/analytics', salesController.getSalesAnalytics.bind(salesController));
router.get('/:id', salesController.getSaleById.bind(salesController));

export default router;

