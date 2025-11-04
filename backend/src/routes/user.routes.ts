import { Router } from 'express';
import { userController } from '../controllers/user.controller';
import { authenticate } from '../middleware/auth.middleware';
import { checkSubscriptionStatus } from '../middleware/subscription.middleware';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Password change (accessible even when subscription is expired)
router.post('/change-password', userController.changePassword.bind(userController));

// Block merchant access if subscription is expired (platform owners can still access)
// This applies to all routes below
router.use(checkSubscriptionStatus);

// User management routes
router.post('/', userController.createUser.bind(userController));
router.get('/', userController.getUsers.bind(userController));
router.get('/:id', userController.getUserById.bind(userController));
router.put('/:id', userController.updateUser.bind(userController));

// Role assignment routes
router.post('/:id/roles', userController.assignRoleToUser.bind(userController));
router.delete('/:id/roles/:roleId', userController.removeRoleFromUser.bind(userController));

export default router;

