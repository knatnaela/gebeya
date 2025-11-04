import { prisma } from '../lib/db';
import { AppError } from '../middleware/error.middleware';
import { RoleType } from './feature.service';

export interface CreateRoleData {
  name: string;
  description?: string;
  type: RoleType;
  hierarchyLevel?: number;
  companyId?: string;
  createdBy: string;
  featureIds?: string[];
  featureActions?: Record<string, string[]>; // featureId -> actions array
}

export interface UpdateRoleData {
  name?: string;
  description?: string;
  hierarchyLevel?: number;
  featureIds?: string[];
  featureActions?: Record<string, string[]>;
}

export class RoleService {
  /**
   * Create a new role (platform owner only)
   */
  async createRole(data: CreateRoleData) {
    const { name, description, type, hierarchyLevel, companyId, createdBy, featureIds, featureActions } = data;

    // Validate hierarchy level
    if (hierarchyLevel && (hierarchyLevel < 1 || hierarchyLevel > 3)) {
      throw new AppError('Hierarchy level must be between 1 and 3', 400);
    }

    // Create role with features in a transaction
    const role = await prisma.$transaction(async (tx) => {
      // Generate a cuid-like ID
      const generateId = () => {
        const timestamp = Date.now().toString(36);
        const randomStr = Math.random().toString(36).substring(2, 15);
        return `cl${timestamp}${randomStr}`;
      };

      const newRole = await tx.roles.create({
        data: {
          id: generateId(),
          name,
          description,
          type,
          hierarchyLevel: hierarchyLevel || 1,
          companyId: companyId || null,
          createdBy,
          updatedAt: new Date(),
        },
      });

      // Assign features if provided
      if (featureIds && featureIds.length > 0) {
        const roleFeatures = featureIds.map((featureId) => {
          const actions = featureActions?.[featureId] || [];
          return {
            id: generateId(),
            roleId: newRole.id,
            featureId,
            actions: actions.length > 0 ? actions : undefined,
          };
        });

        await tx.role_features.createMany({
          data: roleFeatures,
        });
      }

      return newRole;
    });

    // Fetch role with features
    return this.getRoleById(role.id);
  }

  /**
   * Update role
   */
  async updateRole(roleId: string, data: UpdateRoleData, userId: string) {
    const role = await prisma.roles.findUnique({
      where: { id: roleId },
    });

    if (!role) {
      throw new AppError('Role not found', 404);
    }

    // Prevent updating system roles
    if (role.isSystemRole) {
      throw new AppError('Cannot update system roles', 403);
    }

    // Validate hierarchy level
    if (data.hierarchyLevel && (data.hierarchyLevel < 1 || data.hierarchyLevel > 3)) {
      throw new AppError('Hierarchy level must be between 1 and 3', 400);
    }

    // Update role and features in a transaction
    const updatedRole = await prisma.$transaction(async (tx) => {
      // Update role
      const role = await tx.roles.update({
        where: { id: roleId },
        data: {
          name: data.name,
          description: data.description,
          hierarchyLevel: data.hierarchyLevel,
        },
      });

      // Update features if provided
      if (data.featureIds !== undefined) {
        // Remove all existing features
        await tx.role_features.deleteMany({
          where: { roleId },
        });

        // Add new features
        if (data.featureIds.length > 0) {
          // Generate a cuid-like ID
          const generateId = () => {
            const timestamp = Date.now().toString(36);
            const randomStr = Math.random().toString(36).substring(2, 15);
            return `cl${timestamp}${randomStr}`;
          };

          const roleFeatures = data.featureIds.map((featureId) => {
            const actions = data.featureActions?.[featureId] || [];
            return {
              id: generateId(),
              roleId,
              featureId,
              actions: actions.length > 0 ? actions : undefined,
            };
          });

          await tx.role_features.createMany({
            data: roleFeatures,
          });
        }
      }

      return role;
    });

    return this.getRoleById(updatedRole.id);
  }

  /**
   * Delete role (soft delete by marking as inactive)
   */
  async deleteRole(roleId: string) {
    const role = await prisma.roles.findUnique({
      where: { id: roleId },
    });

    if (!role) {
      throw new AppError('Role not found', 404);
    }

    // Prevent deleting system roles
    if (role.isSystemRole) {
      throw new AppError('Cannot delete system roles', 403);
    }

    // Check if role is assigned to any users
    const activeAssignments = await prisma.user_role_assignments.count({
      where: {
        roleId,
        isActive: true,
      },
    });

    if (activeAssignments > 0) {
      throw new AppError('Cannot delete role that is assigned to users. Please remove assignments first.', 400);
    }

    // Delete role (hard delete since we checked for assignments)
    await prisma.roles.delete({
      where: { id: roleId },
    });

    return { success: true, message: 'Role deleted successfully' };
  }

  /**
   * Get all roles, optionally filtered by type
   */
  async getRoles(filters?: { type?: RoleType; companyId?: string }) {
    const where: any = {};

    if (filters?.type) {
      where.type = filters.type;
    }

    if (filters?.companyId !== undefined) {
      where.companyId = filters.companyId;
    }

    const roles = await prisma.roles.findMany({
      where,
      include: {
        role_features: {
          include: {
            features: true,
          },
        },
        _count: {
          select: {
            user_role_assignments: {
              where: {
                isActive: true,
              },
            },
          },
        },
      },
      orderBy: [
        { hierarchyLevel: 'desc' },
        { name: 'asc' },
      ],
    });

    return roles.map((role) => ({
      ...role,
      features: role.role_features.map((rf: any) => ({
        ...rf.features,
        actions: rf.actions as string[],
      })),
      userCount: role._count.user_role_assignments,
    }));
  }

  /**
   * Get role by ID with features
   */
  async getRoleById(roleId: string) {
    const role = await prisma.roles.findUnique({
      where: { id: roleId },
      include: {
        role_features: {
          include: {
            features: true,
          },
        },
        _count: {
          select: {
            user_role_assignments: {
              where: {
                isActive: true,
              },
            },
          },
        },
      },
    });

    if (!role) {
      throw new AppError('Role not found', 404);
    }

    return {
      ...role,
      features: role.role_features.map((rf: any) => ({
        ...rf.features,
        actions: rf.actions as string[],
      })),
      userCount: role._count.user_role_assignments,
    };
  }

  /**
   * Assign role to user
   */
  async assignRoleToUser(roleId: string, userId: string, assignedBy: string) {
    // Verify role exists
    const role = await prisma.roles.findUnique({
      where: { id: roleId },
    });

    if (!role) {
      throw new AppError('Role not found', 404);
    }

    // Check if assignment already exists
    const existingAssignment = await prisma.user_role_assignments.findUnique({
      where: {
        userId_roleId: {
          userId,
          roleId,
        },
      },
    });

    if (existingAssignment) {
      // Reactivate if it was deactivated
      if (!existingAssignment.isActive) {
        const updated = await prisma.user_role_assignments.update({
          where: { id: existingAssignment.id },
          data: {
            isActive: true,
            assignedBy,
            assignedAt: new Date(),
          },
        });
        return updated;
      }
      throw new AppError('Role is already assigned to this user', 400);
    }

    // Create new assignment
    // Generate a cuid-like ID
    const generateId = () => {
      const timestamp = Date.now().toString(36);
      const randomStr = Math.random().toString(36).substring(2, 15);
      return `cl${timestamp}${randomStr}`;
    };

    const assignment = await prisma.user_role_assignments.create({
      data: {
        id: generateId(),
        userId,
        roleId,
        assignedBy,
      },
      include: {
        roles: true,
        users: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });

    return assignment;
  }

  /**
   * Remove role assignment from user
   */
  async removeRoleFromUser(roleId: string, userId: string) {
    const assignment = await prisma.user_role_assignments.findUnique({
      where: {
        userId_roleId: {
          userId,
          roleId,
        },
      },
    });

    if (!assignment) {
      throw new AppError('Role assignment not found', 404);
    }

    // Soft delete by setting isActive to false
    await prisma.user_role_assignments.update({
      where: { id: assignment.id },
      data: {
        isActive: false,
      },
    });

    return { success: true, message: 'Role assignment removed successfully' };
  }

  /**
   * Get roles assigned to a user
   */
  async getUserRoles(userId: string) {
    const assignments = await prisma.user_role_assignments.findMany({
      where: {
        userId,
        isActive: true,
      },
      include: {
        roles: {
          include: {
            role_features: {
              include: {
                features: true,
              },
            },
          },
        },
      },
    });

    return assignments.map((assignment) => ({
      ...assignment.roles,
      features: assignment.roles.role_features.map((rf: any) => ({
        ...rf.features,
        actions: rf.actions as string[],
      })),
      assignedAt: assignment.assignedAt,
      assignedBy: assignment.assignedBy,
    }));
  }
}

export const roleService = new RoleService();

