import { Router } from 'express';
import { merchantController } from '../controllers/merchant.controller';
import { authenticate, requirePlatformOwner } from '../middleware/auth.middleware';

const router = Router();

// Public registration endpoint (no auth required)
router.post('/register', merchantController.registerMerchant.bind(merchantController));

// All other merchant routes require authentication
router.use(authenticate);

// Routes accessible by platform owner only
router.use(requirePlatformOwner);
router.get('/', merchantController.getMerchants.bind(merchantController));
router.get('/pending', merchantController.getPendingMerchants.bind(merchantController));
router.get('/analytics', merchantController.getPlatformAnalytics.bind(merchantController));
router.post('/:id/approve', merchantController.approveMerchant.bind(merchantController));
router.post('/:id/reject', merchantController.rejectMerchant.bind(merchantController));
router.get('/:id', merchantController.getMerchantById.bind(merchantController));
router.get('/:id/analytics', merchantController.getMerchantAnalytics.bind(merchantController));

export default router;

