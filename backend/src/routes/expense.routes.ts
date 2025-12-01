import { Router } from 'express';
import { expenseController } from '../controllers/expense.controller';
import { authenticate, requireMerchantAccess } from '../middleware/auth.middleware';
import { requireTenant } from '../middleware/tenant.middleware';
import { checkSubscriptionStatus } from '../middleware/subscription.middleware';

const router = Router();

// All expense routes require authentication and merchant access
router.use(authenticate);
router.use(requireTenant);
router.use(requireMerchantAccess);
router.use(checkSubscriptionStatus); // Block access if subscription is expired

// Routes
router.post('/', expenseController.createExpense.bind(expenseController));
router.get('/', expenseController.getExpenses.bind(expenseController));
router.get('/analytics', expenseController.getExpensesAnalytics.bind(expenseController));
router.get('/:id', expenseController.getExpenseById.bind(expenseController));
router.put('/:id', expenseController.updateExpense.bind(expenseController));
router.delete('/:id', expenseController.deleteExpense.bind(expenseController));

export default router;

