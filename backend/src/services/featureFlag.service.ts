import { prisma } from '../lib/db';
import { AppError } from '../middleware/error.middleware';
import { platformSettingsService } from './platformSettings.service';

export interface EnableMerchantFeatureData {
  featureName: string;
  config?: Record<string, any>;
}

export interface UpdateGlobalFeatureData {
  featureName: string;
  isEnabled: boolean;
  config?: Record<string, any>;
}

export class FeatureFlagService {
  /**
   * Check if a global feature is enabled
   */
  async checkGlobalFeature(featureName: string): Promise<boolean> {
    const settings = await platformSettingsService.getSettings();
    const flags = settings.globalFeatureFlags as Record<string, any>;
    const feature = flags[featureName];

    if (!feature) {
      return false;
    }

    return feature.enabled === true;
  }

  /**
   * Check if a merchant-specific feature is enabled
   * Returns true if merchant feature is enabled, or if global feature is enabled and merchant hasn't disabled it
   */
  async checkMerchantFeature(merchantId: string, featureName: string): Promise<boolean> {
    // First check merchant-specific flag
    const merchantFlag = await prisma.merchant_feature_flags.findUnique({
      where: {
        merchantId_featureName: {
          merchantId,
          featureName,
        },
      },
    });

    if (merchantFlag) {
      return merchantFlag.isEnabled;
    }

    // If no merchant-specific flag, check global feature
    return this.checkGlobalFeature(featureName);
  }

  /**
   * Enable a feature for a specific merchant
   */
  async enableMerchantFeature(merchantId: string, data: EnableMerchantFeatureData) {
    const { featureName, config } = data;

    // Generate a cuid-like ID
    const generateId = () => {
      const timestamp = Date.now().toString(36);
      const randomStr = Math.random().toString(36).substring(2, 15);
      return `cl${timestamp}${randomStr}`;
    };

    const merchantFlag = await prisma.merchant_feature_flags.upsert({
      where: {
        merchantId_featureName: {
          merchantId,
          featureName,
        },
      },
      update: {
        isEnabled: true,
        config: config || {},
      },
      create: {
        id: generateId(),
        merchantId,
        featureName,
        isEnabled: true,
        config: config || {},
        updatedAt: new Date(),
      },
    });

    return merchantFlag;
  }

  /**
   * Disable a feature for a specific merchant
   */
  async disableMerchantFeature(merchantId: string, featureName: string) {
    // Generate a cuid-like ID
    const generateId = () => {
      const timestamp = Date.now().toString(36);
      const randomStr = Math.random().toString(36).substring(2, 15);
      return `cl${timestamp}${randomStr}`;
    };

    const merchantFlag = await prisma.merchant_feature_flags.upsert({
      where: {
        merchantId_featureName: {
          merchantId,
          featureName,
        },
      },
      update: {
        isEnabled: false,
      },
      create: {
        id: generateId(),
        merchantId,
        featureName,
        isEnabled: false,
        config: {},
        updatedAt: new Date(),
      },
    });

    return merchantFlag;
  }

  /**
   * Update a global feature flag
   */
  async updateGlobalFeature(data: UpdateGlobalFeatureData) {
    const { featureName, isEnabled, config } = data;

    return await platformSettingsService.updateGlobalFeatureFlag(featureName, isEnabled, config);
  }

  /**
   * Get all merchant feature flags
   */
  async getMerchantFeatureFlags(merchantId: string) {
    const flags = await prisma.merchant_feature_flags.findMany({
      where: { merchantId },
    });

    return flags;
  }

  /**
   * Get all merchant feature flags with global defaults
   */
  async getMerchantFeaturesWithDefaults(merchantId: string) {
    const merchantFlags = await prisma.merchant_feature_flags.findMany({
      where: { merchantId },
    });

    const settings = await platformSettingsService.getSettings();
    const globalFlags = settings.globalFeatureFlags as Record<string, any>;

    // Combine merchant-specific and global flags
    const allFeatures: Record<string, {
      isEnabled: boolean;
      isGlobal: boolean;
      config: Record<string, any>;
    }> = {};

    // Add global features
    for (const [featureName, feature] of Object.entries(globalFlags)) {
      if (typeof feature === 'object' && feature !== null && 'enabled' in feature) {
        allFeatures[featureName] = {
          isEnabled: feature.enabled === true,
          isGlobal: true,
          config: feature.config || {},
        };
      }
    }

    // Override with merchant-specific flags
    for (const flag of merchantFlags) {
      allFeatures[flag.featureName] = {
        isEnabled: flag.isEnabled,
        isGlobal: false,
        config: flag.config as Record<string, any> || {},
      };
    }

    return allFeatures;
  }

  /**
   * Get all global feature flags
   */
  async getGlobalFeatureFlags() {
    const settings = await platformSettingsService.getSettings();
    return settings.globalFeatureFlags as Record<string, any>;
  }
}

export const featureFlagService = new FeatureFlagService();

