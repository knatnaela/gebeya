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

      const rawCodes = req.body.phoneFirstCountryIsoCodes;
      let phoneFirstCountryIsoCodes: string[] | undefined;
      if (Array.isArray(rawCodes)) {
        phoneFirstCountryIsoCodes = rawCodes.map((c: unknown) => String(c).trim()).filter(Boolean);
      } else if (typeof rawCodes === 'string' && rawCodes.trim()) {
        phoneFirstCountryIsoCodes = rawCodes
          .split(/[\s,]+/)
          .map((c) => c.trim())
          .filter(Boolean);
      }

      const data: UpdatePlatformSettingsData = {
        defaultTrialPeriodDays: req.body.defaultTrialPeriodDays
          ? parseInt(req.body.defaultTrialPeriodDays, 10)
          : undefined,
        defaultTransactionFeeRate: req.body.defaultTransactionFeeRate
          ? parseFloat(req.body.defaultTransactionFeeRate)
          : undefined,
        globalFeatureFlags: req.body.globalFeatureFlags,
        phoneFirstCountryIsoCodes,
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

