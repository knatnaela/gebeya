import { Router } from 'express';
import { auditController } from '../controllers/audit.controller';
import { authenticate, requirePlatformOwner } from '../middleware/auth.middleware';

const router = Router();

// All audit routes require authentication
router.use(authenticate);

// Platform owners can see all logs, others see only their merchant's logs
router.get('/', auditController.getLogs.bind(auditController));

export default router;

