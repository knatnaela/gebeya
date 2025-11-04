import { Router } from 'express';
import { authController } from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

// Public routes
router.post('/login', authController.login.bind(authController));
router.post('/register', authController.register.bind(authController));

// Protected routes
router.get('/me', authenticate, authController.getCurrentUser.bind(authController));
router.post('/change-password', authenticate, authController.changePassword.bind(authController));

export default router;

