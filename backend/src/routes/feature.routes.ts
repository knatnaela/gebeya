import { Router } from 'express';
import { featureController } from '../controllers/feature.controller';
import { authenticate, requirePlatformOwner } from '../middleware/auth.middleware';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Get routes accessible to all authenticated users
router.get('/', featureController.getFeatures.bind(featureController));
router.get('/:id', featureController.getFeatureById.bind(featureController));

// Platform owner only routes
router.use(requirePlatformOwner);
router.post('/seed', featureController.seedFeatures.bind(featureController));
router.post('/', featureController.createFeature.bind(featureController));
router.put('/:id', featureController.updateFeature.bind(featureController));

export default router;

