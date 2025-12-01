import { Router } from 'express';
import { inventoryController } from '../controllers/inventory.controller';
import { authenticate, requireMerchantAccess } from '../middleware/auth.middleware';
import { requireTenant } from '../middleware/tenant.middleware';
import { checkSubscriptionStatus } from '../middleware/subscription.middleware';

const router = Router();

// All inventory routes require authentication and merchant access
router.use(authenticate);
router.use(requireTenant);
router.use(requireMerchantAccess);
router.use(checkSubscriptionStatus); // Block access if subscription is expired

// Routes
router.post('/transactions', inventoryController.createTransaction.bind(inventoryController));
router.get('/transactions', inventoryController.getTransactions.bind(inventoryController));
router.get('/transactions/:id', inventoryController.getTransactionById.bind(inventoryController));
router.get('/summary', inventoryController.getInventorySummary.bind(inventoryController));
router.put('/products/:id/threshold', inventoryController.updateStockThreshold.bind(inventoryController));

// Stock management routes
router.post('/stock', inventoryController.addStock.bind(inventoryController));
router.get('/entries', inventoryController.getInventoryEntries.bind(inventoryController));
router.get('/stock/:productId', inventoryController.getCurrentStock.bind(inventoryController));
router.post('/transfer', inventoryController.transferStock.bind(inventoryController));
router.get('/stock/:productId/history', inventoryController.getStockHistory.bind(inventoryController));

// Debt/Credit tracking routes
router.get('/debt-summary', inventoryController.getDebtSummary.bind(inventoryController));
router.patch('/entries/:inventoryId/mark-paid', inventoryController.markAsPaid.bind(inventoryController));

export default router;

