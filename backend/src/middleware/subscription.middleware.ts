import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth.middleware';
import { subscriptionService } from '../services/subscription.service';
import { AppError } from './error.middleware';

/**
 * Middleware to check if merchant has an active subscription/trial
 * Blocks access if trial is expired
 */
export const checkSubscriptionStatus = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Skip check for platform owners
    if (req.user?.role === 'PLATFORM_OWNER') {
      next();
      return;
    }

    // Skip check for non-merchant users
    if (!req.user?.merchantId) {
      next();
      return;
    }

    const merchantId = req.user.merchantId;
    const subscriptionStatus = await subscriptionService.checkSubscriptionStatus(merchantId);

    // If subscription is expired, block access
    if (!subscriptionStatus.isActive) {
      res.status(403).json({
        success: false,
        error: 'Trial subscription has expired',
        details: {
          status: subscriptionStatus.status,
          trialEndDate: subscriptionStatus.trialEndDate,
          message: 'Please contact the platform owner to extend your trial or activate your subscription.',
        },
      });
      return;
    }

    // Add subscription status to request for use in controllers
    req.subscriptionStatus = subscriptionStatus;

    next();
  } catch (error: any) {
    // If there's an error checking subscription, block access for security
    // This prevents merchants from accessing the system if subscription check fails
    console.error('Error checking subscription status:', error);
    res.status(500).json({
      success: false,
      error: 'Unable to verify subscription status. Please contact support.',
    });
    return;
  }
};

/**
 * Middleware to check if subscription is expiring soon (warning only, doesn't block)
 */
export const checkSubscriptionWarning = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Skip check for platform owners
    if (req.user?.role === 'PLATFORM_OWNER') {
      next();
      return;
    }

    // Skip check for non-merchant users
    if (!req.user?.merchantId) {
      next();
      return;
    }

    const merchantId = req.user.merchantId;
    const subscriptionStatus = await subscriptionService.checkSubscriptionStatus(merchantId);

    // If subscription is active and expiring soon (less than 7 days), add warning
    if (subscriptionStatus.isActive && subscriptionStatus.daysRemaining !== undefined) {
      if (subscriptionStatus.daysRemaining <= 7 && subscriptionStatus.daysRemaining > 0) {
        // Add warning to response headers (can be read by frontend)
        res.setHeader('X-Subscription-Warning', JSON.stringify({
          daysRemaining: subscriptionStatus.daysRemaining,
          trialEndDate: subscriptionStatus.trialEndDate,
          message: `Your trial expires in ${subscriptionStatus.daysRemaining} days. Please contact the platform owner.`,
        }));
      }
    }

    next();
  } catch (error: any) {
    // Don't block access on warning check errors
    next();
  }
};

