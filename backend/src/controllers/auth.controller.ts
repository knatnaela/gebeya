import { Request, Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';
import { authService } from '../services/auth.service';
import { platformSettingsService } from '../services/platformSettings.service';
import { z } from 'zod';

const forgotPasswordSchema = z.object({
  email: z.string().email('Invalid email address'),
});

const resetPasswordSchema = z.object({
  token: z.string().min(1, 'Reset token is required'),
  newPassword: z.string().min(8, 'Password must be at least 8 characters'),
});

// Validation schemas — exactly one of: email, or structured phone, or E.164 phone
const loginSchema = z
  .object({
    email: z.string().email('Invalid email address').optional(),
    password: z.string().min(6, 'Password must be at least 6 characters'),
    phoneCountryIso: z.string().length(2).optional(),
    phoneNationalNumber: z.string().optional(),
    phone: z.string().optional(),
  })
  .superRefine((data, ctx) => {
    const hasEmail = !!data.email?.trim();
    const hasParts = !!(data.phoneCountryIso && data.phoneNationalNumber?.trim());
    const hasE164 = !!data.phone?.trim();
    if (hasEmail && (hasParts || hasE164)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Provide either email or phone, not both',
        path: [],
      });
    }
    if (!hasEmail && !hasParts && !hasE164) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Provide email or phone',
        path: [],
      });
    }
    if (data.phoneCountryIso && !data.phoneNationalNumber?.trim()) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'National number is required with country',
        path: ['phoneNationalNumber'],
      });
    }
    if (!data.phoneCountryIso && data.phoneNationalNumber?.trim()) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Country is required with national number',
        path: ['phoneCountryIso'],
      });
    }
  });

const gatewayStartSchema = z
  .object({
    phoneCountryIso: z.string().length(2).optional(),
    phoneNationalNumber: z.string().optional(),
    phone: z.string().optional(),
  })
  .superRefine((data, ctx) => {
    const hasParts = !!(data.phoneCountryIso && data.phoneNationalNumber?.trim());
    const hasE164 = !!data.phone?.trim();
    if (hasParts && hasE164) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Use structured phone or E.164, not both',
        path: [],
      });
    }
    if (!hasParts && !hasE164) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Phone is required',
        path: [],
      });
    }
    if (data.phoneCountryIso && !data.phoneNationalNumber?.trim()) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'National number is required',
        path: ['phoneNationalNumber'],
      });
    }
    if (!data.phoneCountryIso && data.phoneNationalNumber?.trim()) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Country is required',
        path: ['phoneCountryIso'],
      });
    }
  });

const gatewayVerifySchema = z.object({
  requestId: z.string().min(1, 'Request id is required'),
  code: z.string().min(4).max(12),
});

const registerSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  firstName: z.string().min(1, 'First name is required'),
  lastName: z.string().optional(),
  role: z.enum(['PLATFORM_OWNER', 'MERCHANT_ADMIN', 'MERCHANT_STAFF']),
  merchantId: z.string().optional(),
  companyId: z.string().optional(),
});

export class AuthController {
  async publicAuthConfig(_req: Request, res: Response): Promise<void> {
    try {
      const data = await platformSettingsService.getPublicAuthUiConfig();
      res.json({
        success: true,
        data,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Failed to load config',
      });
    }
  }

  async login(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = loginSchema.parse(req.body);
      const result = await authService.loginWithPassword(validatedData);

      res.json({
        success: true,
        data: result,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }

      res.status(401).json({
        success: false,
        error: error instanceof Error ? error.message : 'Login failed',
      });
    }
  }

  async gatewayLoginStart(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validated = gatewayStartSchema.parse(req.body);
      const result = await authService.gatewayLoginStart(validated);
      res.json({
        success: true,
        data: result,
        message: 'If an account exists for this number, a verification code was sent.',
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          error: error.message,
        });
        return;
      }
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Request failed',
      });
    }
  }

  async gatewayLoginVerify(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validated = gatewayVerifySchema.parse(req.body);
      const result = await authService.gatewayLoginVerify(validated);
      res.json({
        success: true,
        data: result,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(401).json({
        success: false,
        error: error instanceof Error ? error.message : 'Verification failed',
      });
    }
  }

  async register(req: AuthRequest, res: Response): Promise<void> {
    try {
      const validatedData = registerSchema.parse(req.body);
      const result = await authService.register(validatedData);

      res.status(201).json({
        success: true,
        data: result,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }

      res.status(400).json({
        success: false,
        error: error instanceof Error ? error.message : 'Registration failed',
      });
    }
  }

  async getCurrentUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: 'Authentication required',
        });
        return;
      }

      const user = await authService.getCurrentUser(req.user.userId);

      // Include permissions and roles from req.user if available
      res.json({
        success: true,
        data: {
          ...user,
          permissions: req.user.permissions,
          roles: req.user.roles,
          requiresPasswordChange: req.user.requiresPasswordChange,
        },
      });
    } catch (error) {
      res.status(404).json({
        success: false,
        error: error instanceof Error ? error.message : 'User not found',
      });
    }
  }

  async forgotPassword(req: Request, res: Response): Promise<void> {
    try {
      const validatedData = forgotPasswordSchema.parse(req.body);
      const result = await authService.requestPasswordReset(validatedData.email);
      res.json({
        success: true,
        data: result,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Request failed',
      });
    }
  }

  async resetPassword(req: Request, res: Response): Promise<void> {
    try {
      const validatedData = resetPasswordSchema.parse(req.body);
      await authService.resetPasswordWithToken(
        validatedData.token,
        validatedData.newPassword
      );
      res.json({
        success: true,
        data: { message: 'Password has been reset. You can sign in with your new password.' },
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.issues,
        });
        return;
      }
      res.status(400).json({
        success: false,
        error: error instanceof Error ? error.message : 'Password reset failed',
      });
    }
  }

  async changePassword(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: 'Authentication required',
        });
        return;
      }

      const { userController } = await import('./user.controller');
      await userController.changePassword(req, res);
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Password change failed',
      });
    }
  }
}

export const authController = new AuthController();

