import { Router } from 'express';
import { subscriptionController } from '../controllers/subscription.controller';
import { authenticate, requirePlatformOwner } from '../middleware/auth.middleware';

const router = Router();

// All subscription routes require authentication
router.use(authenticate);

// Routes accessible by merchants (their own subscription)
// These routes should be accessible even when subscription is expired
// so merchants can see their subscription status
router.get('/merchant/:merchantId', subscriptionController.getSubscriptionByMerchant.bind(subscriptionController));
router.get('/status', subscriptionController.checkSubscriptionStatus.bind(subscriptionController));

// Routes accessible by platform owner only
router.use(requirePlatformOwner);
router.get('/', subscriptionController.getAllSubscriptions.bind(subscriptionController));
router.patch('/:id/extend', subscriptionController.extendTrial.bind(subscriptionController));
router.patch('/:id/reset', subscriptionController.resetTrial.bind(subscriptionController));
router.patch('/:id/trial-period', subscriptionController.updateTrialPeriod.bind(subscriptionController));
router.patch('/:id/fee-rate', subscriptionController.updateTransactionFeeRate.bind(subscriptionController));
router.patch('/:id/reactivate', subscriptionController.reactivateSubscription.bind(subscriptionController));

export default router;

