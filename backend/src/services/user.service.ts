import bcrypt from 'bcryptjs';
import { prisma } from '../lib/db';
import { AppError } from '../middleware/error.middleware';
import { UserRole } from '@prisma/client';
import { notificationService } from './notification.service';

export interface CreateUserData {
  email: string;
  firstName: string;
  lastName?: string;
  role: UserRole;
  merchantId?: string;
  companyId?: string;
  roleIds?: string[]; // RBAC role IDs to assign
}

export interface UpdateUserData {
  firstName?: string;
  lastName?: string;
  isActive?: boolean;
  roleIds?: string[];
}

export class UserService {
  /**
   * Generate a secure temporary password
   */
  generateTemporaryPassword(): string {
    // Generate 12-character password with alphanumeric and special characters
    const length = 12;
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#$%^&*';
    const allChars = uppercase + lowercase + numbers + special;

    let password = '';
    // Ensure at least one character from each category
    password += uppercase[Math.floor(Math.random() * uppercase.length)];
    password += lowercase[Math.floor(Math.random() * lowercase.length)];
    password += numbers[Math.floor(Math.random() * numbers.length)];
    password += special[Math.floor(Math.random() * special.length)];

    // Fill the rest randomly
    for (let i = password.length; i < length; i++) {
      password += allChars[Math.floor(Math.random() * allChars.length)];
    }

    // Shuffle the password
    return password.split('').sort(() => Math.random() - 0.5).join('');
  }

  /**
   * Create user with temporary password
   */
  async createUserWithTemporaryPassword(data: CreateUserData, createdBy: string) {
    const { email, firstName, lastName, role, merchantId, companyId, roleIds } = data;

    // Check if user already exists
    const existingUser = await prisma.users.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new AppError('User with this email already exists', 400);
    }

    // Validate role and tenant assignment
    if (role === UserRole.PLATFORM_OWNER && !companyId) {
      throw new AppError('Platform owner must be associated with a company', 400);
    }

    if (
      (role === UserRole.MERCHANT_ADMIN || role === UserRole.MERCHANT_STAFF) &&
      !merchantId
    ) {
      throw new AppError('Merchant users must be associated with a merchant', 400);
    }

    // Generate temporary password
    const temporaryPassword = this.generateTemporaryPassword();
    const hashedPassword = await bcrypt.hash(temporaryPassword, 10);

    // Temporary password expires in 7 days
    const temporaryPasswordExpiresAt = new Date();
    temporaryPasswordExpiresAt.setDate(temporaryPasswordExpiresAt.getDate() + 7);

    // Create user in a transaction
    const user = await prisma.$transaction(async (tx) => {
      // Generate a cuid-like ID
      const generateId = () => {
        const timestamp = Date.now().toString(36);
        const randomStr = Math.random().toString(36).substring(2, 15);
        return `cl${timestamp}${randomStr}`;
      };

      // Create user
      const newUser = await tx.users.create({
        data: {
          id: generateId(),
          email,
          password: hashedPassword,
          firstName,
          lastName,
          role,
          merchantId: merchantId || null,
          companyId: companyId || null,
          requiresPasswordChange: true,
          temporaryPassword: hashedPassword,
          temporaryPasswordExpiresAt,
          updatedAt: new Date(),
        },
      });

      // Assign RBAC roles if provided
      if (roleIds && roleIds.length > 0) {
        const roleAssignments = roleIds.map((roleId) => ({
          id: generateId(),
          userId: newUser.id,
          roleId,
          assignedBy: createdBy,
        }));

        await tx.user_role_assignments.createMany({
          data: roleAssignments,
        });
      }

      return newUser;
    });

    // Send welcome email with temporary password
    try {
      await notificationService.sendWelcomeEmail({
        email: user.email,
        firstName: user.firstName,
        password: temporaryPassword, // Send plain text password
        role: role,
      });
    } catch (error: any) {
      console.error('Failed to send welcome email:', error);
      // Don't fail user creation if email fails
    }

    // Remove password from response
    const { password: _, temporaryPassword: __, ...userWithoutPassword } = user;

    return {
      ...userWithoutPassword,
      temporaryPassword: temporaryPassword, // Return plain text for display (only this time)
    };
  }

  /**
   * Change user password
   */
  async changePassword(userId: string, oldPassword: string, newPassword: string) {
    const user = await prisma.users.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Verify old password (check both regular password and temporary password)
    const isOldPasswordValid = await bcrypt.compare(oldPassword, user.password);
    const isTemporaryPasswordValid = user.temporaryPassword
      ? await bcrypt.compare(oldPassword, user.temporaryPassword)
      : false;

    if (!isOldPasswordValid && !isTemporaryPasswordValid) {
      throw new AppError('Invalid current password', 400);
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password and clear temporary password requirement
    await prisma.users.update({
      where: { id: userId },
      data: {
        password: hashedPassword,
        temporaryPassword: null,
        temporaryPasswordExpiresAt: null,
        requiresPasswordChange: false,
      },
    });

    return { success: true, message: 'Password changed successfully' };
  }

  /**
   * Force password change check
   */
  async requiresPasswordChange(userId: string): Promise<boolean> {
    const user = await prisma.users.findUnique({
      where: { id: userId },
      select: {
        requiresPasswordChange: true,
        temporaryPasswordExpiresAt: true,
      },
    });

    if (!user) {
      return false;
    }

    // Check if temporary password has expired
    if (user.temporaryPasswordExpiresAt && new Date() > user.temporaryPasswordExpiresAt) {
      return true;
    }

    return user.requiresPasswordChange;
  }

  /**
   * Get all users, optionally filtered
   */
  async getUsers(filters?: {
    merchantId?: string;
    companyId?: string;
    isActive?: boolean;
    role?: UserRole;
  }) {
    const where: any = {};

    if (filters?.merchantId) {
      where.merchantId = filters.merchantId;
    }

    if (filters?.companyId) {
      where.companyId = filters.companyId;
    }

    if (filters?.isActive !== undefined) {
      where.isActive = filters.isActive;
    }

    if (filters?.role) {
      where.role = filters.role;
    }

    const users = await prisma.users.findMany({
      where,
      include: {
        merchants: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        companies: {
          select: {
            id: true,
            name: true,
          },
        },
        user_role_assignments: {
          where: {
            isActive: true,
          },
          include: {
            roles: {
              select: {
                id: true,
                name: true,
                type: true,
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Remove passwords from response
    return users.map(({ password: _, temporaryPassword: __, ...user }) => ({
      ...user,
      roles: (user as any).user_role_assignments?.map((ra: any) => ra.roles) || [],
    }));
  }

  /**
   * Get user by ID
   */
  async getUserById(userId: string) {
    const user = await prisma.users.findUnique({
      where: { id: userId },
      include: {
        merchants: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        companies: {
          select: {
            id: true,
            name: true,
          },
        },
        user_role_assignments: {
          where: {
            isActive: true,
          },
          include: {
            roles: {
              select: {
                id: true,
                name: true,
                type: true,
                description: true,
              },
            },
          },
        },
      },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Remove passwords from response
    const { password: _, temporaryPassword: __, ...userWithoutPassword } = user;

    return {
      ...userWithoutPassword,
      roles: (userWithoutPassword as any).user_role_assignments?.map((ra: any) => ra.roles) || [],
    };
  }

  /**
   * Update user
   */
  async updateUser(userId: string, data: UpdateUserData, updatedBy: string) {
    const user = await prisma.users.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Update user in a transaction
    const updatedUser = await prisma.$transaction(async (tx) => {
      // Update user basic info
      const user = await tx.users.update({
        where: { id: userId },
        data: {
          firstName: data.firstName,
          lastName: data.lastName,
          isActive: data.isActive,
        },
      });

      // Update role assignments if provided
      if (data.roleIds !== undefined) {
        // Deactivate all existing assignments
        await tx.user_role_assignments.updateMany({
          where: { userId },
          data: { isActive: false },
        });

        // Create new assignments
        if (data.roleIds.length > 0) {
          // Generate a cuid-like ID
          const generateId = () => {
            const timestamp = Date.now().toString(36);
            const randomStr = Math.random().toString(36).substring(2, 15);
            return `cl${timestamp}${randomStr}`;
          };

          const roleAssignments = data.roleIds.map((roleId) => ({
            id: generateId(),
            userId,
            roleId,
            assignedBy: updatedBy,
          }));

          await tx.user_role_assignments.createMany({
            data: roleAssignments,
            skipDuplicates: true,
          });
        }
      }

      return user;
    });

    return this.getUserById(updatedUser.id);
  }

  /**
   * Assign role to user
   */
  async assignRoleToUser(userId: string, roleId: string, assignedBy: string) {
    const { roleService } = await import('./role.service');
    return roleService.assignRoleToUser(roleId, userId, assignedBy);
  }

  /**
   * Remove role from user
   */
  async removeRoleFromUser(userId: string, roleId: string) {
    const { roleService } = await import('./role.service');
    return roleService.removeRoleFromUser(roleId, userId);
  }
}

export const userService = new UserService();

