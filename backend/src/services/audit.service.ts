import { prisma } from '../lib/db';
import { AuditAction } from '@prisma/client';

export interface CreateAuditLogData {
  userId?: string;
  merchantId?: string;
  action: AuditAction;
  entityType: string;
  entityId?: string;
  changes?: {
    before?: any;
    after?: any;
  };
  ipAddress?: string;
  userAgent?: string;
}

export class AuditService {
  /**
   * Create an audit log entry
   */
  async createLog(data: CreateAuditLogData): Promise<void> {
    try {
      // Generate a cuid-like ID
      const generateId = () => {
        const timestamp = Date.now().toString(36);
        const randomStr = Math.random().toString(36).substring(2, 15);
        return `${timestamp}${randomStr}`;
      };
      
      await prisma.audit_logs.create({
        data: {
          id: generateId(),
          userId: data.userId || undefined,
          merchantId: data.merchantId || undefined,
          action: data.action,
          entityType: data.entityType,
          entityId: data.entityId || undefined,
          changes: data.changes ? JSON.parse(JSON.stringify(data.changes)) : null,
          ipAddress: data.ipAddress || undefined,
          userAgent: data.userAgent || undefined,
        },
      });
    } catch (error) {
      // Don't throw - audit logging failures shouldn't break the main operation
      console.error('Failed to create audit log:', error);
    }
  }

  /**
   * Get audit logs with filters
   */
  async getLogs(filters: {
    userId?: string;
    merchantId?: string;
    entityType?: string;
    entityId?: string;
    startDate?: Date;
    endDate?: Date;
    page?: number;
    limit?: number;
  }) {
    const page = filters.page || 1;
    const limit = filters.limit || 50;
    const skip = (page - 1) * limit;

    const where: any = {};

    if (filters.userId) {
      where.userId = filters.userId;
    }

    if (filters.merchantId) {
      where.merchantId = filters.merchantId;
    }

    if (filters.entityType) {
      where.entityType = filters.entityType;
    }

    if (filters.entityId) {
      where.entityId = filters.entityId;
    }

    if (filters.startDate || filters.endDate) {
      where.createdAt = {};
      if (filters.startDate) {
        where.createdAt.gte = filters.startDate;
      }
      if (filters.endDate) {
        where.createdAt.lte = filters.endDate;
      }
    }

    const [logs, total] = await Promise.all([
      prisma.audit_logs.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          users: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
        },
      }),
      prisma.audit_logs.count({ where }),
    ]);

    return {
      logs,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}

export const auditService = new AuditService();

