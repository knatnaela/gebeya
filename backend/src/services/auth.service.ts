import bcrypt from 'bcryptjs';
import { prisma } from '../lib/db';
import { UserRole } from '@prisma/client';
import { generateToken } from '../lib/jwt';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  firstName: string;
  lastName?: string;
  role: UserRole;
  merchantId?: string;
  companyId?: string;
}

export class AuthService {
  async login(credentials: LoginCredentials) {
    const { email, password } = credentials;

    // Find user with related merchant/company
    const user = await prisma.users.findUnique({
      where: { email },
      include: {
        merchants: true,
        companies: true,
      },
    });

    if (!user || !user.isActive) {
      throw new Error('Invalid email or password');
    }

    // Verify password (check both regular password and temporary password)
    const isValidPassword = await bcrypt.compare(password, user.password);
    const temporaryPassword = (user as any).temporaryPassword;
    const isValidTemporaryPassword = temporaryPassword
      ? await bcrypt.compare(password, temporaryPassword)
      : false;

    if (!isValidPassword && !isValidTemporaryPassword) {
      throw new Error('Invalid email or password');
    }

    // Check if password change is required
    const requiresPasswordChange = (user as any).requiresPasswordChange || false;
    const temporaryPasswordExpired = (user as any).temporaryPasswordExpiresAt
      ? new Date() > (user as any).temporaryPasswordExpiresAt
      : false;

    // Generate JWT token
    const token = generateToken({
      userId: user.id,
      email: user.email,
      role: user.role,
      merchantId: user.merchantId || undefined,
      companyId: user.companyId || undefined,
    });

    // Remove password from response
    const { password: _, temporaryPassword: __, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      token,
      requiresPasswordChange: requiresPasswordChange || temporaryPasswordExpired,
    };
  }

  async register(data: RegisterData) {
    const { email, password, firstName, lastName, role, merchantId, companyId } = data;

    // Check if user already exists
    const existingUser = await prisma.users.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // Validate role and tenant assignment
    if (role === UserRole.PLATFORM_OWNER && !companyId) {
      throw new Error('Platform owner must be associated with a company');
    }

    if (
      (role === UserRole.MERCHANT_ADMIN || role === UserRole.MERCHANT_STAFF) &&
      !merchantId
    ) {
      throw new Error('Merchant users must be associated with a merchant');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generate a cuid-like ID
    const generateId = () => {
      const timestamp = Date.now().toString(36);
      const randomStr = Math.random().toString(36).substring(2, 15);
      return `cl${timestamp}${randomStr}`;
    };

    // Create user
    const user = await prisma.users.create({
      data: {
        id: generateId(),
        email,
        password: hashedPassword,
        firstName,
        lastName,
        role,
        merchantId: merchantId || null,
        companyId: companyId || null,
        updatedAt: new Date(),
      },
      include: {
        merchants: true,
        companies: true,
      },
    });

    // Generate token
    const token = generateToken({
      userId: user.id,
      email: user.email,
      role: user.role,
      merchantId: user.merchantId || undefined,
      companyId: user.companyId || undefined,
    });

    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      token,
    };
  }

  async getCurrentUser(userId: string) {
    const user = await prisma.users.findUnique({
      where: { id: userId },
      include: {
        merchants: true,
        companies: true,
      },
    });

    if (!user) {
      throw new Error('User not found');
    }

    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;

    return userWithoutPassword;
  }
}

export const authService = new AuthService();

