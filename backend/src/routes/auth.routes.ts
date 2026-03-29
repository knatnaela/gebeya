import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { authController } from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

const forgotPasswordLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
});

const resetPasswordLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
});

const publicAuthConfigLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 120,
  standardHeaders: true,
  legacyHeaders: false,
});

const gatewayStartLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
});

const gatewayVerifyLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
});

// Public routes
router.get(
  '/public-config',
  publicAuthConfigLimiter,
  authController.publicAuthConfig.bind(authController)
);
router.post('/login', authController.login.bind(authController));
router.post(
  '/login/gateway/start',
  gatewayStartLimiter,
  authController.gatewayLoginStart.bind(authController)
);
router.post(
  '/login/gateway/verify',
  gatewayVerifyLimiter,
  authController.gatewayLoginVerify.bind(authController)
);
router.post('/register', authController.register.bind(authController));
router.post(
  '/forgot-password',
  forgotPasswordLimiter,
  authController.forgotPassword.bind(authController)
);
router.post(
  '/reset-password',
  resetPasswordLimiter,
  authController.resetPassword.bind(authController)
);

// Protected routes
router.get('/me', authenticate, authController.getCurrentUser.bind(authController));
router.post('/change-password', authenticate, authController.changePassword.bind(authController));

export default router;

