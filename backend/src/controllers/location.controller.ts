import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { locationService } from '../services/location.service';
import { z } from 'zod';

const createLocationSchema = z.object({
  name: z.string().min(1, 'Location name is required'),
  address: z.string().optional(),
  phone: z.string().optional(),
});

const updateLocationSchema = z.object({
  name: z.string().min(1, 'Location name is required').optional(),
  address: z.string().optional(),
  phone: z.string().optional(),
  isActive: z.boolean().optional(),
});

export class LocationController {
  async createLocation(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = createLocationSchema.parse(req.body);
      const location = await locationService.createLocation(req, validatedData);
      res.status(201).json({
        success: true,
        data: location,
      });
    } catch (error: any) {
      res.status(error.status || 400).json({
        success: false,
        error: error.message || 'Failed to create location',
      });
    }
  }

  async getLocations(req: AuthRequest, res: Response): Promise<void> {
    try {
      const locations = await locationService.getLocations(req);
      res.status(200).json({
        success: true,
        data: locations,
      });
    } catch (error: any) {
      res.status(error.status || 500).json({
        success: false,
        error: error.message || 'Failed to fetch locations',
      });
    }
  }

  async getLocationById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const location = await locationService.getLocationById(req, id);
      res.status(200).json({
        success: true,
        data: location,
      });
    } catch (error: any) {
      res.status(error.status || 404).json({
        success: false,
        error: error.message || 'Location not found',
      });
    }
  }

  async updateLocation(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const validatedData = updateLocationSchema.parse(req.body);
      const location = await locationService.updateLocation(req, id, validatedData);
      res.status(200).json({
        success: true,
        data: location,
      });
    } catch (error: any) {
      res.status(error.status || 400).json({
        success: false,
        error: error.message || 'Failed to update location',
      });
    }
  }

  async deleteLocation(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const location = await locationService.deleteLocation(req, id);
      res.status(200).json({
        success: true,
        data: location,
        message: 'Location deleted successfully',
      });
    } catch (error: any) {
      res.status(error.status || 400).json({
        success: false,
        error: error.message || 'Failed to delete location',
      });
    }
  }

  async getDefaultLocation(req: AuthRequest, res: Response): Promise<void> {
    try {
      const location = await locationService.getDefaultLocation(req);
      res.status(200).json({
        success: true,
        data: location,
      });
    } catch (error: any) {
      res.status(error.status || 500).json({
        success: false,
        error: error.message || 'Failed to fetch default location',
      });
    }
  }

  async setDefaultLocation(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const location = await locationService.setDefaultLocation(req, id);
      res.status(200).json({
        success: true,
        data: location,
        message: 'Default location updated successfully',
      });
    } catch (error: any) {
      res.status(error.status || 400).json({
        success: false,
        error: error.message || 'Failed to set default location',
      });
    }
  }
}

export const locationController = new LocationController();

