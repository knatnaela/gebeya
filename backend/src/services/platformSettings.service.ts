import { prisma } from '../lib/db';
import { AppError } from '../middleware/error.middleware';

export interface UpdatePlatformSettingsData {
  defaultTrialPeriodDays?: number;
  defaultTransactionFeeRate?: number;
  globalFeatureFlags?: Record<string, any>;
}

export class PlatformSettingsService {
  /**
   * Get platform settings (singleton - always returns first or creates default)
   */
  async getSettings() {
    try {
      let settings = await prisma.platform_settings.findFirst();

      // Create default settings if none exist
      if (!settings) {
        // Generate a cuid-like ID
        const generateId = () => {
          const timestamp = Date.now().toString(36);
          const randomStr = Math.random().toString(36).substring(2, 15);
          return `cl${timestamp}${randomStr}`;
        };

        settings = await prisma.platform_settings.create({
          data: {
            id: generateId(),
            defaultTrialPeriodDays: 30,
            defaultTransactionFeeRate: 5.00, // 5%
            globalFeatureFlags: {},
            updatedAt: new Date(),
          },
        });
      }

      if (!settings) {
        throw new AppError('Failed to retrieve or create platform settings', 500);
      }

      // Validate the settings object has required fields
      if (settings.defaultTrialPeriodDays === null || settings.defaultTrialPeriodDays === undefined) {
        throw new AppError(`Platform settings has null/undefined defaultTrialPeriodDays. Settings ID: ${settings.id}`, 500);
      }

      if (settings.defaultTransactionFeeRate === null || settings.defaultTransactionFeeRate === undefined) {
        throw new AppError(`Platform settings has null/undefined defaultTransactionFeeRate. Settings ID: ${settings.id}`, 500);
      }

      return settings;
    } catch (error: any) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(`Failed to get platform settings: ${error?.message || 'Unknown error'}`, 500);
    }
  }

  /**
   * Update platform settings
   */
  async updateSettings(data: UpdatePlatformSettingsData) {
    const settings = await this.getSettings();

    const updatedSettings = await prisma.platform_settings.update({
      where: { id: settings.id },
      data: {
        defaultTrialPeriodDays: data.defaultTrialPeriodDays ?? settings.defaultTrialPeriodDays,
        defaultTransactionFeeRate: data.defaultTransactionFeeRate ?? settings.defaultTransactionFeeRate,
        globalFeatureFlags: (data.globalFeatureFlags ?? settings.globalFeatureFlags) as any,
      },
    });

    return updatedSettings;
  }

  /**
   * Get a specific global feature flag
   */
  async getGlobalFeatureFlag(featureName: string): Promise<boolean | null> {
    const settings = await this.getSettings();
    const flags = settings.globalFeatureFlags as Record<string, any>;
    return flags[featureName] ?? null;
  }

  /**
   * Update a global feature flag
   */
  async updateGlobalFeatureFlag(featureName: string, isEnabled: boolean, config?: Record<string, any>) {
    const settings = await this.getSettings();
    const flags = settings.globalFeatureFlags as Record<string, any>;

    flags[featureName] = {
      enabled: isEnabled,
      config: config || {},
    };

    const updatedSettings = await prisma.platform_settings.update({
      where: { id: settings.id },
      data: {
        globalFeatureFlags: flags,
      },
    });

    return updatedSettings;
  }
}

export const platformSettingsService = new PlatformSettingsService();

