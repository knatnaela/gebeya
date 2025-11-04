import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { platformSettingsService, UpdatePlatformSettingsData } from '../services/platformSettings.service';

export class PlatformSettingsController {
  /**
   * Get platform settings
   */
  async getSettings(req: AuthRequest, res: Response): Promise<void> {
    try {
      const settings = await platformSettingsService.getSettings();

      res.json({
        success: true,
        data: settings,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch platform settings',
      });
    }
  }

  /**
   * Update platform settings (platform owner only)
   */
  async updateSettings(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.user?.role !== 'PLATFORM_OWNER') {
        res.status(403).json({
          success: false,
          error: 'Access denied',
        });
        return;
      }

      const data: UpdatePlatformSettingsData = {
        defaultTrialPeriodDays: req.body.defaultTrialPeriodDays
          ? parseInt(req.body.defaultTrialPeriodDays, 10)
          : undefined,
        defaultTransactionFeeRate: req.body.defaultTransactionFeeRate
          ? parseFloat(req.body.defaultTransactionFeeRate)
          : undefined,
        globalFeatureFlags: req.body.globalFeatureFlags,
      };

      const settings = await platformSettingsService.updateSettings(data);

      res.json({
        success: true,
        data: settings,
        message: 'Platform settings updated successfully',
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to update platform settings',
      });
    }
  }
}

export const platformSettingsController = new PlatformSettingsController();

