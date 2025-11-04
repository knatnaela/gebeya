import { Router } from 'express';
import { platformSettingsController } from '../controllers/platformSettings.controller';
import { authenticate, requirePlatformOwner } from '../middleware/auth.middleware';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Get settings (accessible by all authenticated users)
router.get('/', platformSettingsController.getSettings.bind(platformSettingsController));

// Update settings (platform owner only)
router.use(requirePlatformOwner);
router.patch('/', platformSettingsController.updateSettings.bind(platformSettingsController));

export default router;

