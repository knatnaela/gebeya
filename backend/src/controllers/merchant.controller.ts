import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { merchantService, MerchantFilters } from '../services/merchant.service';

export class MerchantController {
  async getMerchants(req: AuthRequest, res: Response): Promise<void> {
    try {
      const filters: MerchantFilters = {
        search: req.query.search as string,
        isActive:
          req.query.isActive !== undefined ? req.query.isActive === 'true' : undefined,
        companyId: req.query.companyId as string,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
      };

      const result = await merchantService.getMerchants(req, filters);

      res.json({
        success: true,
        data: result.merchants,
        pagination: result.pagination,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch merchants',
      });
    }
  }

  async getMerchantById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const merchant = await merchantService.getMerchantById(req, id);

      res.json({
        success: true,
        data: merchant,
      });
    } catch (error: any) {
      res.status(error.statusCode || 404).json({
        success: false,
        error: error.message || 'Merchant not found',
      });
    }
  }

  async getMerchantAnalytics(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const analytics = await merchantService.getMerchantAnalytics(req, id);

      res.json({
        success: true,
        data: analytics,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch merchant analytics',
      });
    }
  }

  async getPlatformAnalytics(req: AuthRequest, res: Response): Promise<void> {
    try {
      const analytics = await merchantService.getPlatformAnalytics(req);

      res.json({
        success: true,
        data: analytics,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch platform analytics',
      });
    }
  }

  /**
   * Register a new merchant (public endpoint - no auth required)
   */
  async registerMerchant(req: AuthRequest, res: Response): Promise<void> {
    try {
      const result = await merchantService.registerMerchant(req.body);

      res.status(201).json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to register merchant',
      });
    }
  }

  /**
   * Get pending merchant registrations (platform owner only)
   */
  async getPendingMerchants(req: AuthRequest, res: Response): Promise<void> {
    try {
      const merchants = await merchantService.getPendingMerchants(req);

      res.json({
        success: true,
        data: merchants,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to fetch pending merchants',
      });
    }
  }

  /**
   * Approve a merchant (platform owner only)
   */
  async approveMerchant(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      // Approve merchant - trial subscription will be created using platform settings defaults
      const result = await merchantService.approveMerchant(req, id);

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to approve merchant',
      });
    }
  }

  /**
   * Reject a merchant (platform owner only)
   */
  async rejectMerchant(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const result = await merchantService.rejectMerchant(req, id);

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Failed to reject merchant',
      });
    }
  }
}

export const merchantController = new MerchantController();

