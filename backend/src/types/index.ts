// Shared TypeScript types for the backend
import { UserRole } from '@prisma/client';

export { UserRole };

export interface JwtPayload {
  userId: string;
  email: string;
  role: UserRole;
  merchantId?: string;
  companyId?: string;
}

export interface AuthenticatedRequest {
  user?: JwtPayload;
}

