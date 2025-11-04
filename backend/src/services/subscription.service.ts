import { prisma } from '../lib/db';
import { AppError } from '../middleware/error.middleware';
import { platformSettingsService } from './platformSettings.service';

// Import enums from Prisma client using require to avoid TypeScript issues
const PrismaClient = require('@prisma/client');
const SubscriptionPlanType = PrismaClient.SubscriptionPlanType;
const SubscriptionStatus = PrismaClient.SubscriptionStatus;

// Type aliases for return types
type SubscriptionStatusType = 'ACTIVE_TRIAL' | 'ACTIVE_PAID' | 'EXPIRED' | 'CANCELLED';
type SubscriptionPlanTypeType = 'TRIAL' | 'MONTHLY' | 'YEARLY';

export interface CreateTrialData {
  merchantId: string;
  trialPeriodDays?: number;
  transactionFeeRate?: number;
}

export interface ExtendTrialData {
  additionalDays: number;
}

export interface ResetTrialData {
  newTrialPeriodDays: number;
}

export interface UpdateTrialPeriodData {
  newTrialPeriodDays: number;
}

export interface ReactivateSubscriptionData {
  trialPeriodDays?: number;
  transactionFeeRate?: number;
}

export class SubscriptionService {
  /**
   * Create a trial subscription for a merchant
   */
  async createTrial(data: CreateTrialData) {
    const { merchantId, trialPeriodDays, transactionFeeRate } = data;

    // Check if merchant already has an active subscription
    const existingSubscription = await prisma.subscriptions.findFirst({
      where: {
        merchantId,
        status: {
          in: ['ACTIVE_TRIAL', 'ACTIVE_PAID'],
        },
      },
    });

    if (existingSubscription) {
      throw new AppError('Merchant already has an active subscription', 400);
    }

    // Get default settings if not provided
    try {
      // Check if platformSettingsService exists
      if (!platformSettingsService) {
        throw new AppError('Platform settings service is not initialized', 500);
      }

      const settings = await platformSettingsService.getSettings();

      if (!settings || typeof settings !== 'object') {
        throw new AppError('Platform settings not found - getSettings() returned null/undefined or invalid object', 500);
      }

      // Safely access settings properties with explicit checks
      const defaultTrialPeriodDays = settings?.defaultTrialPeriodDays;
      const defaultTransactionFeeRate = settings?.defaultTransactionFeeRate;
      const settingsId = settings?.id;

      // Validate required fields exist
      if (defaultTrialPeriodDays == null || defaultTrialPeriodDays === undefined) {
        throw new AppError(`Platform settings missing defaultTrialPeriodDays. Settings ID: ${settingsId || 'unknown'}`, 500);
      }

      if (defaultTransactionFeeRate == null || defaultTransactionFeeRate === undefined) {
        throw new AppError(`Platform settings missing defaultTransactionFeeRate. Settings ID: ${settingsId || 'unknown'}`, 500);
      }

      const finalTrialPeriodDays = trialPeriodDays ?? defaultTrialPeriodDays;
      const finalTransactionFeeRate = transactionFeeRate ?? Number(defaultTransactionFeeRate);

      // Validate final values are numbers
      if (typeof finalTrialPeriodDays !== 'number' || isNaN(finalTrialPeriodDays)) {
        throw new AppError(`Invalid trialPeriodDays: ${finalTrialPeriodDays}`, 500);
      }

      if (typeof finalTransactionFeeRate !== 'number' || isNaN(finalTransactionFeeRate)) {
        throw new AppError(`Invalid transactionFeeRate: ${finalTransactionFeeRate}`, 500);
      }

      // Continue with the rest of the function using finalTrialPeriodDays and finalTransactionFeeRate
      // Calculate trial end date
      const startDate = new Date();
      const trialEndDate = new Date(startDate);
      trialEndDate.setDate(trialEndDate.getDate() + finalTrialPeriodDays);

      // Generate a cuid-like ID
      const generateId = () => {
        const timestamp = Date.now().toString(36);
        const randomStr = Math.random().toString(36).substring(2, 15);
        return `cl${timestamp}${randomStr}`;
      };

      const subscription = await prisma.subscriptions.create({
        data: {
          id: generateId(),
          merchantId,
          planType: SubscriptionPlanType.TRIAL,
          status: SubscriptionStatus.ACTIVE_TRIAL,
          startDate,
          trialEndDate,
          trialPeriodDays: finalTrialPeriodDays,
          transactionFeeRate: finalTransactionFeeRate,
          updatedAt: new Date(),
        },
      });

      if (!subscription) {
        throw new AppError('Failed to create subscription - Prisma returned null/undefined', 500);
      }

      // Validate the created subscription has required fields
      if (subscription.trialPeriodDays === null || subscription.trialPeriodDays === undefined) {
        throw new AppError(`Created subscription missing trialPeriodDays. Subscription ID: ${subscription.id}`, 500);
      }

      return subscription;
    } catch (error: any) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(`Failed to create trial subscription: ${error?.message || 'Unknown error'}`, 500);
    }
  }

  /**
   * Extend trial period by adding additional days
   */
  async extendTrial(subscriptionId: string, data: ExtendTrialData) {
    const { additionalDays } = data;

    if (additionalDays <= 0) {
      throw new AppError('Additional days must be greater than 0', 400);
    }

    const subscription = await prisma.subscriptions.findUnique({
      where: { id: subscriptionId },
    });

    if (!subscription) {
      throw new AppError('Subscription not found', 404);
    }

    if (subscription.status !== SubscriptionStatus.ACTIVE_TRIAL) {
      throw new AppError('Can only extend active trial subscriptions', 400);
    }

    // Validate subscription has required fields
    if (subscription.trialPeriodDays === null || subscription.trialPeriodDays === undefined) {
      throw new AppError(`Subscription missing trialPeriodDays. Subscription ID: ${subscriptionId}`, 500);
    }

    if (!subscription.trialEndDate) {
      throw new AppError(`Subscription missing trialEndDate. Subscription ID: ${subscriptionId}`, 500);
    }

    // Calculate new trial end date
    const currentEndDate = new Date(subscription.trialEndDate);
    const newTrialEndDate = new Date(currentEndDate);
    newTrialEndDate.setDate(newTrialEndDate.getDate() + additionalDays);

    const updatedSubscription = await prisma.subscriptions.update({
      where: { id: subscriptionId },
      data: {
        trialEndDate: newTrialEndDate,
        trialPeriodDays: subscription.trialPeriodDays + additionalDays,
      },
    });

    return updatedSubscription;
  }

  /**
   * Reset trial period with new end date
   */
  async resetTrial(subscriptionId: string, data: ResetTrialData) {
    const { newTrialPeriodDays } = data;

    if (newTrialPeriodDays <= 0) {
      throw new AppError('Trial period days must be greater than 0', 400);
    }

    const subscription = await prisma.subscriptions.findUnique({
      where: { id: subscriptionId },
    });

    if (!subscription) {
      throw new AppError('Subscription not found', 404);
    }

    if (subscription.status !== SubscriptionStatus.ACTIVE_TRIAL) {
      throw new AppError('Can only reset active trial subscriptions', 400);
    }

    // Calculate new trial end date from current date
    const startDate = new Date();
    const newTrialEndDate = new Date(startDate);
    newTrialEndDate.setDate(newTrialEndDate.getDate() + newTrialPeriodDays);

    const updatedSubscription = await prisma.subscriptions.update({
      where: { id: subscriptionId },
      data: {
        startDate,
        trialEndDate: newTrialEndDate,
        trialPeriodDays: newTrialPeriodDays,
      },
    });

    return updatedSubscription;
  }

  /**
   * Update trial period duration (changes end date proportionally)
   */
  async updateTrialPeriod(subscriptionId: string, data: UpdateTrialPeriodData) {
    const { newTrialPeriodDays } = data;

    if (newTrialPeriodDays <= 0) {
      throw new AppError('Trial period days must be greater than 0', 400);
    }

    const subscription = await prisma.subscriptions.findUnique({
      where: { id: subscriptionId },
    });

    if (!subscription) {
      throw new AppError('Subscription not found', 404);
    }

    if (subscription.status !== SubscriptionStatus.ACTIVE_TRIAL) {
      throw new AppError('Can only update active trial subscriptions', 400);
    }

    // Calculate new trial end date based on days elapsed
    const startDate = new Date(subscription.startDate);
    const currentDate = new Date();
    const daysElapsed = Math.floor(
      (currentDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)
    );

    const newTrialEndDate = new Date(startDate);
    newTrialEndDate.setDate(newTrialEndDate.getDate() + newTrialPeriodDays);

    // If days elapsed exceeds new period, set end date to current date + remaining days
    if (daysElapsed >= newTrialPeriodDays) {
      const newStartDate = new Date();
      newStartDate.setDate(newStartDate.getDate());
      const updatedTrialEndDate = new Date(newStartDate);
      updatedTrialEndDate.setDate(updatedTrialEndDate.getDate() + newTrialPeriodDays);

      const updatedSubscription = await prisma.subscriptions.update({
        where: { id: subscriptionId },
        data: {
          startDate: newStartDate,
          trialEndDate: updatedTrialEndDate,
          trialPeriodDays: newTrialPeriodDays,
        },
      });

      return updatedSubscription;
    }

    const updatedSubscription = await prisma.subscriptions.update({
      where: { id: subscriptionId },
      data: {
        trialEndDate: newTrialEndDate,
        trialPeriodDays: newTrialPeriodDays,
      },
    });

    return updatedSubscription;
  }

  /**
   * Check subscription status for a merchant
   */
  async checkSubscriptionStatus(merchantId: string): Promise<{
    status: SubscriptionStatusType;
    isActive: boolean;
    daysRemaining?: number;
    trialEndDate?: Date;
  }> {
    const subscription = await prisma.subscriptions.findFirst({
      where: { merchantId },
      orderBy: { createdAt: 'desc' },
    });

    if (!subscription) {
      return {
        status: SubscriptionStatus.EXPIRED,
        isActive: false,
      };
    }

    // Check if trial has expired
    const now = new Date();
    const trialEndDate = new Date(subscription.trialEndDate);

    if (subscription.status === SubscriptionStatus.ACTIVE_TRIAL && now > trialEndDate) {
      // Update status to expired
      await prisma.subscriptions.update({
        where: { id: subscription.id },
        data: { status: SubscriptionStatus.EXPIRED },
      });

      return {
        status: SubscriptionStatus.EXPIRED,
        isActive: false,
        trialEndDate,
      };
    }

    const daysRemaining = subscription.status === SubscriptionStatus.ACTIVE_TRIAL
      ? Math.ceil((trialEndDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
      : undefined;

    return {
      status: subscription.status,
      isActive: subscription.status === SubscriptionStatus.ACTIVE_TRIAL || subscription.status === SubscriptionStatus.ACTIVE_PAID,
      daysRemaining,
      trialEndDate: subscription.status === SubscriptionStatus.ACTIVE_TRIAL ? trialEndDate : undefined,
    };
  }

  /**
   * Get subscription for a merchant
   */
  async getSubscriptionByMerchantId(merchantId: string) {
    const subscription = await prisma.subscriptions.findFirst({
      where: { merchantId },
      orderBy: { createdAt: 'desc' },
      include: {
        subscription_payments: {
          orderBy: { paymentDate: 'desc' },
        },
      },
    });

    return subscription;
  }

  /**
   * Get all subscriptions (platform owner only)
   */
  async getAllSubscriptions(filters?: {
    status?: SubscriptionStatusType;
    merchantId?: string;
    search?: string;
    page?: number;
    limit?: number;
  }) {
    const page = filters?.page || 1;
    const limit = filters?.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {};

    if (filters?.status) {
      where.status = filters.status;
    }

    if (filters?.merchantId) {
      where.merchantId = filters.merchantId;
    }

    // Add search filter for merchant name or email
    if (filters?.search) {
      where.merchant = {
        OR: [
          { email: { contains: filters.search, mode: 'insensitive' } },
          { name: { contains: filters.search, mode: 'insensitive' } },
        ],
      };
    }

    const [subscriptions, total] = await Promise.all([
      prisma.subscriptions.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          merchants: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
          subscription_payments: {
            orderBy: { paymentDate: 'desc' },
            take: 5,
          },
        },
      }),
      prisma.subscriptions.count({ where }),
    ]);

    return {
      subscriptions,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Calculate transaction fee for a sale amount
   */
  async calculateTransactionFee(saleAmount: number, merchantId: string): Promise<number> {
    const subscription = await this.getSubscriptionByMerchantId(merchantId);

    if (!subscription) {
      // Use default transaction fee rate if no subscription
      const settings = await platformSettingsService.getSettings();
      const defaultRate = Number(settings.defaultTransactionFeeRate);
      return (saleAmount * defaultRate) / 100;
    }

    const feeRate = Number(subscription.transactionFeeRate);
    return (saleAmount * feeRate) / 100;
  }

  /**
   * Update transaction fee rate for a subscription
   */
  async updateTransactionFeeRate(subscriptionId: string, feeRate: number) {
    if (feeRate < 0 || feeRate > 100) {
      throw new AppError('Transaction fee rate must be between 0 and 100', 400);
    }

    const subscription = await prisma.subscriptions.findUnique({
      where: { id: subscriptionId },
    });

    if (!subscription) {
      throw new AppError('Subscription not found', 404);
    }

    const updatedSubscription = await prisma.subscriptions.update({
      where: { id: subscriptionId },
      data: {
        transactionFeeRate: feeRate,
      },
    });

    return updatedSubscription;
  }

  /**
   * Reactivate an expired subscription (renew trial)
   */
  async reactivateSubscription(subscriptionId: string, data?: ReactivateSubscriptionData) {
    const subscription = await prisma.subscriptions.findUnique({
      where: { id: subscriptionId },
    });

    if (!subscription) {
      throw new AppError('Subscription not found', 404);
    }

    // Only allow reactivating expired or cancelled subscriptions
    if (subscription.status !== SubscriptionStatus.EXPIRED && subscription.status !== SubscriptionStatus.CANCELLED) {
      throw new AppError('Can only reactivate expired or cancelled subscriptions', 400);
    }

    // Check if merchant already has an active subscription
    const existingActiveSubscription = await prisma.subscriptions.findFirst({
      where: {
        merchantId: subscription.merchantId,
        status: {
          in: ['ACTIVE_TRIAL', 'ACTIVE_PAID'],
        },
        id: {
          not: subscriptionId, // Exclude the current subscription
        },
      },
    });

    if (existingActiveSubscription) {
      throw new AppError('Merchant already has an active subscription', 400);
    }

    // Get default settings if not provided
    try {
      if (!platformSettingsService) {
        throw new AppError('Platform settings service is not initialized', 500);
      }

      const settings = await platformSettingsService.getSettings();

      if (!settings || typeof settings !== 'object') {
        throw new AppError('Platform settings not found - getSettings() returned null/undefined or invalid object', 500);
      }

      const defaultTrialPeriodDays = settings?.defaultTrialPeriodDays;
      const defaultTransactionFeeRate = settings?.defaultTransactionFeeRate;
      const settingsId = settings?.id;

      if (defaultTrialPeriodDays == null || defaultTrialPeriodDays === undefined) {
        throw new AppError(`Platform settings missing defaultTrialPeriodDays. Settings ID: ${settingsId || 'unknown'}`, 500);
      }

      if (defaultTransactionFeeRate == null || defaultTransactionFeeRate === undefined) {
        throw new AppError(`Platform settings missing defaultTransactionFeeRate. Settings ID: ${settingsId || 'unknown'}`, 500);
      }

      const finalTrialPeriodDays = data?.trialPeriodDays ?? defaultTrialPeriodDays;
      const finalTransactionFeeRate = data?.transactionFeeRate ?? Number(defaultTransactionFeeRate);

      // Validate final values are numbers
      if (typeof finalTrialPeriodDays !== 'number' || isNaN(finalTrialPeriodDays)) {
        throw new AppError(`Invalid trialPeriodDays: ${finalTrialPeriodDays}`, 500);
      }

      if (typeof finalTransactionFeeRate !== 'number' || isNaN(finalTransactionFeeRate)) {
        throw new AppError(`Invalid transactionFeeRate: ${finalTransactionFeeRate}`, 500);
      }

      // Calculate new trial end date
      const startDate = new Date();
      const trialEndDate = new Date(startDate);
      trialEndDate.setDate(trialEndDate.getDate() + finalTrialPeriodDays);

      const updatedSubscription = await prisma.subscriptions.update({
        where: { id: subscriptionId },
        data: {
          planType: SubscriptionPlanType.TRIAL,
          status: SubscriptionStatus.ACTIVE_TRIAL,
          startDate,
          trialEndDate,
          trialPeriodDays: finalTrialPeriodDays,
          transactionFeeRate: finalTransactionFeeRate,
        },
      });

      if (!updatedSubscription) {
        throw new AppError('Failed to reactivate subscription - Prisma returned null/undefined', 500);
      }

      if (updatedSubscription.trialPeriodDays === null || updatedSubscription.trialPeriodDays === undefined) {
        throw new AppError(`Reactivated subscription missing trialPeriodDays. Subscription ID: ${updatedSubscription.id}`, 500);
      }

      return updatedSubscription;
    } catch (error: any) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(`Failed to reactivate subscription: ${error?.message || 'Unknown error'}`, 500);
    }
  }
}

export const subscriptionService = new SubscriptionService();

