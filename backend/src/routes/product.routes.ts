import { Router } from 'express';
import { productController } from '../controllers/product.controller';
import { authenticate, requireMerchantAccess } from '../middleware/auth.middleware';
import { requireTenant } from '../middleware/tenant.middleware';
import { checkSubscriptionStatus } from '../middleware/subscription.middleware';

const router = Router();

// All product routes require authentication and merchant access
router.use(authenticate);
router.use(requireTenant);
router.use(checkSubscriptionStatus); // Block access if subscription is expired

// Routes
router.post('/', productController.createProduct.bind(productController));
router.get('/', productController.getProducts.bind(productController));
router.get('/low-stock', productController.getLowStockProducts.bind(productController));
router.get('/:id', productController.getProductById.bind(productController));
router.put('/:id', productController.updateProduct.bind(productController));
router.delete('/:id', productController.deleteProduct.bind(productController));

export default router;

