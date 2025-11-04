import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { subscriptionService, ExtendTrialData, ResetTrialData, UpdateTrialPeriodData, ReactivateSubscriptionData } from '../services/subscription.service';
import { z } from 'zod';

const extendTrialSchema = z.object({
  additionalDays: z.number().int().positive('Additional days must be a positive integer'),
});

const resetTrialSchema = z.object({
  newTrialPeriodDays: z.number().int().positive('Trial period days must be a positive integer'),
});

const updateTrialPeriodSchema = z.object({
  newTrialPeriodDays: z.number().int().positive('Trial period days must be a positive integer'),
});

const updateTransactionFeeRateSchema = z.object({
  feeRate: z.number().min(0, 'Fee rate must be at least 0').max(100, 'Fee rate cannot exceed 100'),
});

const reactivateSubscriptionSchema = z.object({
  trialPeriodDays: z.number().int().positive('Trial period days must be a positive integer').optional(),
  transactionFeeRate: z.number().min(0, 'Fee rate must be at least 0').max(100, 'Fee rate cannot exceed 100').optional(),
});

export class SubscriptionController {
  /**
   * Get subscription for a merchant
   */
  async getSubscriptionByMerchant(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { merchantId } = req.params;

      // Platform owners can see any merchant's subscription
      // Merchants can only see their own
      if (req.user?.role !== 'PLATFORM_OWNER' && req.user?.merchantId !== merchantId) {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const subscription = await subscriptionService.getSubscriptionByMerchantId(merchantId);

      if (!subscription) {
        res.status(404).json({
          success: false,
          error: 'Subscription not found',
        });
        return;
      }

      res.json({
        success: true,
        data: subscription,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch subscription',
      });
    }
  }

  /**
   * Get all subscriptions (platform owner only)
   */
  async getAllSubscriptions(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const filters = {
        status: req.query.status as any,
        merchantId: req.query.merchantId as string,
        search: req.query.search as string,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
      };

      const result = await subscriptionService.getAllSubscriptions(filters);

      res.json({
        success: true,
        data: result.subscriptions,
        pagination: result.pagination,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch subscriptions',
      });
    }
  }

  /**
   * Extend trial period (platform owner only)
   */
  async extendTrial(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const { id } = req.params;
      const validatedData = extendTrialSchema.parse(req.body);

      const subscription = await subscriptionService.extendTrial(id, validatedData);

      res.json({
        success: true,
        data: subscription,
        message: `Trial extended by ${validatedData.additionalDays} days`,
      });
    } catch (error: any) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to extend trial',
      });
    }
  }

  /**
   * Reset trial period (platform owner only)
   */
  async resetTrial(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const { id } = req.params;
      const validatedData = resetTrialSchema.parse(req.body);

      const subscription = await subscriptionService.resetTrial(id, validatedData);

      res.json({
        success: true,
        data: subscription,
        message: `Trial reset to ${validatedData.newTrialPeriodDays} days`,
      });
    } catch (error: any) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to reset trial',
      });
    }
  }

  /**
   * Update trial period duration (platform owner only)
   */
  async updateTrialPeriod(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const { id } = req.params;
      const validatedData = updateTrialPeriodSchema.parse(req.body);

      const subscription = await subscriptionService.updateTrialPeriod(id, validatedData);

      res.json({
        success: true,
        data: subscription,
        message: `Trial period updated to ${validatedData.newTrialPeriodDays} days`,
      });
    } catch (error: any) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to update trial period',
      });
    }
  }

  /**
   * Update transaction fee rate (platform owner only)
   */
  async updateTransactionFeeRate(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const { id } = req.params;
      const validatedData = updateTransactionFeeRateSchema.parse(req.body);

      const subscription = await subscriptionService.updateTransactionFeeRate(id, validatedData.feeRate);

      res.json({
        success: true,
        data: subscription,
        message: `Transaction fee rate updated to ${validatedData.feeRate}%`,
      });
    } catch (error: any) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to update transaction fee rate',
      });
    }
  }

  /**
   * Check subscription status for current merchant
   */
  async checkSubscriptionStatus(req: AuthRequest, res: Response): Promise<void> {
    try {
      const merchantId = req.user?.merchantId;

      if (!merchantId) {
        res.status(400).json({
          success: false,
          error: 'Merchant ID not found',
        });
        return;
      }

      const status = await subscriptionService.checkSubscriptionStatus(merchantId);

      res.json({
        success: true,
        data: status,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to check subscription status',
      });
    }
  }

  /**
   * Reactivate an expired subscription (platform owner only)
   */
  async reactivateSubscription(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const { id } = req.params;
      const validatedData = reactivateSubscriptionSchema.parse(req.body);

      const subscription = await subscriptionService.reactivateSubscription(id, validatedData);

      res.json({
        success: true,
        data: subscription,
        message: 'Subscription reactivated successfully',
      });
    } catch (error: any) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to reactivate subscription',
      });
    }
  }
}

export const subscriptionController = new SubscriptionController();

