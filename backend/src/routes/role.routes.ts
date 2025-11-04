import { Router } from 'express';
import { roleController } from '../controllers/role.controller';
import { authenticate, requirePlatformOwner } from '../middleware/auth.middleware';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Routes accessible to all authenticated users
router.get('/', roleController.getRoles.bind(roleController));

// Role assignment routes (platform owner and merchant admins can use)
// Must come before :id routes to avoid route conflicts
router.post('/:id/assign', roleController.assignRole.bind(roleController));
router.delete('/:id/assign/:userId', roleController.removeRole.bind(roleController));

// Get role by ID (accessible to all authenticated users)
router.get('/:id', roleController.getRoleById.bind(roleController));

// Platform owner only routes
router.use(requirePlatformOwner);
router.post('/', roleController.createRole.bind(roleController));
router.put('/:id', roleController.updateRole.bind(roleController));
router.delete('/:id', roleController.deleteRole.bind(roleController));

export default router;

