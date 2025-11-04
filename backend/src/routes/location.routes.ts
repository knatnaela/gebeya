import { Router } from 'express';
import { locationController } from '../controllers/location.controller';
import { authenticate } from '../middleware/auth.middleware';
import { checkSubscriptionStatus } from '../middleware/subscription.middleware';

const router = Router();

// All routes require authentication
router.use(authenticate);
router.use(checkSubscriptionStatus); // Block access if subscription is expired (for merchants)

router.post('/', locationController.createLocation.bind(locationController));
router.get('/', locationController.getLocations.bind(locationController));
router.get('/default', locationController.getDefaultLocation.bind(locationController));
router.get('/:id', locationController.getLocationById.bind(locationController));
router.put('/:id', locationController.updateLocation.bind(locationController));
router.patch('/:id/set-default', locationController.setDefaultLocation.bind(locationController));
router.delete('/:id', locationController.deleteLocation.bind(locationController));

export default router;

