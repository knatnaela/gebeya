import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import { prisma } from '../lib/db';
import { Prisma, UserRole } from '@prisma/client';
import { generateToken } from '../lib/jwt';
import { env } from '../config/env';
import { notificationService } from './notification.service';
import { normalizePhoneFromParts, parseLegacyPhoneString } from '../utils/phone';
import {
  sendVerificationMessage,
  checkVerificationStatus,
  isTelegramGatewayConfigured,
} from './telegram-gateway.service';
import { AppError } from '../middleware/error.middleware';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface LoginWithPasswordInput {
  password: string;
  email?: string;
  phoneCountryIso?: string;
  phoneNationalNumber?: string;
  /** Full E.164 when client sends a single field */
  phone?: string;
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

const PASSWORD_RESET_EXPIRY_MS = 60 * 60 * 1000; // 1 hour

function generateCuidLikeId(): string {
  const timestamp = Date.now().toString(36);
  const randomStr = Math.random().toString(36).substring(2, 15);
  return `cl${timestamp}${randomStr}`;
}

function hashResetToken(rawToken: string): string {
  return crypto.createHash('sha256').update(rawToken, 'utf8').digest('hex');
}

export class AuthService {
  /**
   * Request password reset email. Always returns success message (no email enumeration).
   */
  async requestPasswordReset(email: string): Promise<{ message: string }> {
    const normalized = email.trim().toLowerCase();
    const user = await prisma.users.findFirst({
      where: { email: { equals: normalized, mode: 'insensitive' } },
    });

    if (!user || !user.isActive) {
      return {
        message: 'If an account exists for that email, we sent password reset instructions.',
      };
    }

    await prisma.password_reset_tokens.deleteMany({
      where: { userId: user.id, usedAt: null },
    });

    const rawToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = hashResetToken(rawToken);
    const expiresAt = new Date(Date.now() + PASSWORD_RESET_EXPIRY_MS);

    await prisma.password_reset_tokens.create({
      data: {
        id: generateCuidLikeId(),
        userId: user.id,
        tokenHash,
        expiresAt,
      },
    });

    const resetUrl = `${env.FRONTEND_URL}/reset-password?token=${encodeURIComponent(rawToken)}`;

    try {
      await notificationService.sendPasswordResetEmail({
        email: user.email,
        firstName: user.firstName,
        resetUrl,
      });
    } catch (err) {
      console.error('Password reset email failed:', err);
      // Still avoid leaking whether user exists; log for ops
    }

    if (!env.RESEND_API_KEY) {
      console.warn(
        '[auth] RESEND_API_KEY not set; password reset link (dev only):',
        resetUrl
      );
    }

    return {
      message: 'If an account exists for that email, we sent password reset instructions.',
    };
  }

  /**
   * Complete password reset with one-time token.
   */
  async resetPasswordWithToken(rawToken: string, newPassword: string): Promise<void> {
    if (!rawToken || rawToken.length < 10) {
      throw new Error('Invalid or expired reset link');
    }

    const tokenHash = hashResetToken(rawToken);
    const record = await prisma.password_reset_tokens.findUnique({
      where: { tokenHash },
    });

    if (!record || record.usedAt) {
      throw new Error('Invalid or expired reset link');
    }

    if (record.expiresAt.getTime() < Date.now()) {
      throw new Error('Invalid or expired reset link');
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await prisma.$transaction(async (tx) => {
      await tx.users.update({
        where: { id: record.userId },
        data: {
          password: hashedPassword,
          temporaryPassword: null,
          temporaryPasswordExpiresAt: null,
          requiresPasswordChange: false,
          updatedAt: new Date(),
        },
      });
      await tx.password_reset_tokens.update({
        where: { id: record.id },
        data: { usedAt: new Date() },
      });
    });
  }

  /**
   * Login with email or phone (E.164) + password.
   */
  async loginWithPassword(input: LoginWithPasswordInput) {
    const { password } = input;

    let user: Awaited<
      ReturnType<
        typeof prisma.users.findFirst<{
          include: { merchants: true; companies: true };
        }>
      >
    > | null = null;

    if (input.email) {
      const normalized = input.email.trim().toLowerCase();
      user = await prisma.users.findFirst({
        where: { email: { equals: normalized, mode: 'insensitive' } },
        include: {
          merchants: true,
          companies: true,
        },
      });
    } else if (input.phoneCountryIso && input.phoneNationalNumber) {
      const normalized = normalizePhoneFromParts(input.phoneCountryIso, input.phoneNationalNumber);
      if (!normalized) {
        throw new Error('Invalid phone number');
      }
      user = await prisma.users.findUnique({
        where: { phone: normalized.e164 },
        include: {
          merchants: true,
          companies: true,
        },
      });
    } else if (input.phone) {
      const parsed = parseLegacyPhoneString(input.phone.trim());
      if (!parsed) {
        throw new Error('Invalid phone number');
      }
      user = await prisma.users.findUnique({
        where: { phone: parsed.e164 },
        include: {
          merchants: true,
          companies: true,
        },
      });
    } else {
      throw new Error('Provide email or phone');
    }

    if (!user || !user.isActive) {
      throw new Error('Invalid email or password');
    }

    const isValidPassword = await bcrypt.compare(password, user.password);
    const temporaryPassword = user.temporaryPassword;
    const isValidTemporaryPassword = temporaryPassword
      ? await bcrypt.compare(password, temporaryPassword)
      : false;

    if (!isValidPassword && !isValidTemporaryPassword) {
      throw new Error('Invalid email or password');
    }

    const requiresPasswordChange = user.requiresPasswordChange || false;
    const temporaryPasswordExpired = user.temporaryPasswordExpiresAt
      ? new Date() > user.temporaryPasswordExpiresAt
      : false;

    const token = generateToken({
      userId: user.id,
      email: user.email,
      role: user.role,
      merchantId: user.merchantId || undefined,
      companyId: user.companyId || undefined,
    });

    const { password: _, temporaryPassword: __, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      token,
      requiresPasswordChange: requiresPasswordChange || temporaryPasswordExpired,
    };
  }

  /**
   * @deprecated Use loginWithPassword; kept for internal callers expecting email-only shape.
   */
  async login(credentials: LoginCredentials) {
    return this.loginWithPassword({
      email: credentials.email,
      password: credentials.password,
    });
  }

  /**
   * Start Telegram Gateway OTP login. Returns requestId only when a code was sent.
   * Throws AppError for misconfiguration, invalid phone, inactive account, or Telegram send failure
   * (so clients can show a message). Returns { requestId: null } only when no matching account exists
   * (enumeration-safe).
   */
  async gatewayLoginStart(input: {
    phoneCountryIso?: string;
    phoneNationalNumber?: string;
    phone?: string;
  }): Promise<{ requestId: string | null }> {
    if (!isTelegramGatewayConfigured()) {
      throw new AppError(
        'Telegram Gateway is not configured on the server. Set TELEGRAM_GATEWAY_ACCESS_TOKEN and restart the API.',
        503
      );
    }

    let e164: string;
    try {
      if (input.phoneCountryIso && input.phoneNationalNumber) {
        const n = normalizePhoneFromParts(input.phoneCountryIso, input.phoneNationalNumber);
        if (!n) throw new Error('Invalid phone');
        e164 = n.e164;
      } else if (input.phone) {
        const p = parseLegacyPhoneString(input.phone.trim());
        if (!p) throw new Error('Invalid phone');
        e164 = p.e164;
      } else {
        throw new Error('Phone is required');
      }
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Invalid phone number';
      throw new AppError(msg, 400);
    }

    const phoneWhere: Prisma.usersWhereInput = {
      phone: { equals: e164 },
    };
    const user = await prisma.users.findFirst({ where: phoneWhere });

    if (!user) {
      return { requestId: null };
    }

    if (!user.isActive) {
      throw new AppError(
        'This account is not active yet (for example, merchant registration may still be pending). You cannot sign in with Telegram until the account is active.',
        403
      );
    }

    await prisma.telegram_gateway_verification_sessions.deleteMany({
      where: {
        userId: user.id,
        consumedAt: null,
      },
    });

    let requestId: string;
    try {
      requestId = await sendVerificationMessage({
        phoneNumberE164: e164,
        ttlSeconds: 300,
        codeLength: 6,
        payload: user.id,
      });
    } catch (e) {
      console.error('[auth] Telegram Gateway send failed:', e);
      throw new AppError(
        'Could not send Telegram verification. Check server logs, confirm the token is valid, and that this number can receive Telegram verification.',
        502
      );
    }

    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await prisma.telegram_gateway_verification_sessions.create({
      data: {
        id: generateCuidLikeId(),
        userId: user.id,
        requestId,
        phone: e164,
        expiresAt,
      },
    });

    return { requestId };
  }

  /**
   * Complete Telegram Gateway OTP login.
   */
  async gatewayLoginVerify(input: { requestId: string; code: string }) {
    if (!isTelegramGatewayConfigured()) {
      throw new Error('Telegram Gateway is not configured');
    }

    const session = await prisma.telegram_gateway_verification_sessions.findUnique({
      where: { requestId: input.requestId.trim() },
    });

    if (!session || session.consumedAt) {
      throw new Error('Invalid or expired verification');
    }

    if (session.expiresAt.getTime() < Date.now()) {
      throw new Error('Invalid or expired verification');
    }

    let valid: boolean;
    try {
      valid = await checkVerificationStatus(session.requestId, input.code);
    } catch (e) {
      console.error('[auth] Telegram Gateway verify failed:', e);
      throw new Error('Verification failed');
    }

    if (!valid) {
      throw new Error('Invalid verification code');
    }

    const user = await prisma.users.findUnique({
      where: { id: session.userId },
      include: {
        merchants: true,
        companies: true,
      },
    });

    if (!user || !user.isActive) {
      throw new Error('Invalid or expired verification');
    }

    await prisma.telegram_gateway_verification_sessions.update({
      where: { id: session.id },
      data: { consumedAt: new Date() },
    });

    const requiresPasswordChange = user.requiresPasswordChange || false;
    const temporaryPasswordExpired = user.temporaryPasswordExpiresAt
      ? new Date() > user.temporaryPasswordExpiresAt
      : false;

    const token = generateToken({
      userId: user.id,
      email: user.email,
      role: user.role,
      merchantId: user.merchantId || undefined,
      companyId: user.companyId || undefined,
    });

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

