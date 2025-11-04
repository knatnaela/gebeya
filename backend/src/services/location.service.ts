import { prisma } from '../lib/db';
import { getTenantId, ensureTenantAccess } from '../utils/tenant';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';

export interface CreateLocationData {
  name: string;
  address?: string;
  phone?: string;
}

export interface UpdateLocationData {
  name?: string;
  address?: string;
  phone?: string;
  isActive?: boolean;
}

export class LocationService {
  /**
   * Create a new location
   * Auto-sets isDefault to true if this is the first location for the merchant
   */
  async createLocation(req: AuthRequest, data: CreateLocationData) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    // Check if this is the first location (will be default)
    const existingLocations = await prisma.locations.count({
      where: { merchantId: tenantId },
    });

    const isDefault = existingLocations === 0;

    // If setting as default, unset other defaults
    if (isDefault) {
      await prisma.locations.updateMany({
        where: { merchantId: tenantId, isDefault: true },
        data: { isDefault: false },
      });
    }

    // Check for duplicate name
    const existing = await prisma.locations.findFirst({
      where: {
        merchantId: tenantId,
        name: data.name,
      },
    });

    if (existing) {
      throw new AppError('Location with this name already exists', 400);
    }

    // Generate a cuid-like ID
    const generateId = () => {
      const timestamp = Date.now().toString(36);
      const randomStr = Math.random().toString(36).substring(2, 15);
      return `cl${timestamp}${randomStr}`;
    };

    const location = await prisma.locations.create({
      data: {
        id: generateId(),
        merchantId: tenantId,
        name: data.name,
        address: data.address,
        phone: data.phone,
        isDefault,
      },
    });

    return location;
  }

  /**
   * Get all locations for a merchant
   */
  async getLocations(req: AuthRequest) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    const locations = await prisma.locations.findMany({
      where: {
        merchantId: tenantId,
      },
      orderBy: [
        { isDefault: 'desc' },
        { name: 'asc' },
      ],
    });

    return locations;
  }

  /**
   * Get a single location by ID
   */
  async getLocationById(req: AuthRequest, locationId: string) {
    const location = await prisma.locations.findUnique({
      where: { id: locationId },
    });

    if (!location) {
      throw new AppError('Location not found', 404);
    }

    if (!ensureTenantAccess(req, location.merchantId)) {
      throw new AppError('Access denied', 403);
    }

    return location;
  }

  /**
   * Update a location
   */
  async updateLocation(req: AuthRequest, locationId: string, data: UpdateLocationData) {
    const location = await this.getLocationById(req, locationId);

    // If updating name, check for duplicates
    if (data.name && data.name !== location.name) {
      const existing = await prisma.locations.findFirst({
        where: {
          merchantId: location.merchantId,
          name: data.name,
          id: { not: locationId },
        },
      });

      if (existing) {
        throw new AppError('Location with this name already exists', 400);
      }
    }

    const updated = await prisma.locations.update({
      where: { id: locationId },
      data,
    });

    return updated;
  }

  /**
   * Soft delete a location (set isActive = false)
   */
  async deleteLocation(req: AuthRequest, locationId: string) {
    const location = await this.getLocationById(req, locationId);

    // Don't allow deleting the default location if it's the only one
    if (location.isDefault) {
      const activeLocations = await prisma.locations.count({
        where: {
          merchantId: location.merchantId,
          isActive: true,
        },
      });

      if (activeLocations === 1) {
        throw new AppError('Cannot delete the only active location', 400);
      }
    }

    // Soft delete
    const deleted = await prisma.locations.update({
      where: { id: locationId },
      data: { isActive: false },
    });

    // If this was the default, set another location as default
    if (location.isDefault) {
      const newDefault = await prisma.locations.findFirst({
        where: {
          merchantId: location.merchantId,
          isActive: true,
          id: { not: locationId },
        },
        orderBy: { createdAt: 'asc' },
      });

      if (newDefault) {
        await prisma.locations.update({
          where: { id: newDefault.id },
          data: { isDefault: true },
        });
      }
    }

    return deleted;
  }

  /**
   * Get the default location for a merchant
   */
  async getDefaultLocation(req: AuthRequest) {
    const tenantId = getTenantId(req);
    
    if (!tenantId) {
      throw new AppError('Merchant ID is required', 400);
    }

    let location = await prisma.locations.findFirst({
      where: {
        merchantId: tenantId,
        isDefault: true,
        isActive: true,
      },
    });

    // If no default exists, get the first active location
    if (!location) {
      location = await prisma.locations.findFirst({
        where: {
          merchantId: tenantId,
          isActive: true,
        },
        orderBy: { createdAt: 'asc' },
      });

      // If still no location, create a default one
      if (!location) {
        // Generate a cuid-like ID
        const generateId = () => {
          const timestamp = Date.now().toString(36);
          const randomStr = Math.random().toString(36).substring(2, 15);
          return `cl${timestamp}${randomStr}`;
        };

        location = await prisma.locations.create({
          data: {
            id: generateId(),
            merchantId: tenantId,
            name: 'Main Warehouse',
            isDefault: true,
            isActive: true,
          },
        });
      } else {
        // Set it as default
        await prisma.locations.update({
          where: { id: location.id },
          data: { isDefault: true },
        });
        location.isDefault = true;
      }
    }

    return location;
  }

  /**
   * Set a location as the default
   */
  async setDefaultLocation(req: AuthRequest, locationId: string) {
    const location = await this.getLocationById(req, locationId);

    if (!location.isActive) {
      throw new AppError('Cannot set inactive location as default', 400);
    }

    // Unset all other defaults
    await prisma.locations.updateMany({
      where: {
        merchantId: location.merchantId,
        isDefault: true,
      },
      data: { isDefault: false },
    });

    // Set this one as default
    const updated = await prisma.locations.update({
      where: { id: locationId },
      data: { isDefault: true },
    });

    return updated;
  }
}

export const locationService = new LocationService();

