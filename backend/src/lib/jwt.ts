import * as jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { JwtPayload, UserRole } from '../types';

export const generateToken = (payload: {
  userId: string;
  email: string;
  role: UserRole;
  merchantId?: string;
  companyId?: string;
}): string => {
  const tokenPayload: Record<string, string> = {
    userId: payload.userId,
    email: payload.email,
    role: payload.role,
  };
  
  if (payload.merchantId) {
    tokenPayload.merchantId = payload.merchantId;
  }
  
  if (payload.companyId) {
    tokenPayload.companyId = payload.companyId;
  }
  
  const secret: string = env.JWT_SECRET;
  // @ts-ignore - TypeScript has issues with jsonwebtoken overloads
  return jwt.sign(tokenPayload, secret, {
    expiresIn: env.JWT_EXPIRES_IN,
  });
};

export const verifyToken = (token: string): JwtPayload => {
  try {
    const decoded = jwt.verify(token, env.JWT_SECRET) as JwtPayload;
    return decoded;
  } catch (error) {
    throw new Error('Invalid or expired token');
  }
};

export const decodeToken = (token: string): JwtPayload | null => {
  try {
    return jwt.decode(token) as JwtPayload;
  } catch (error) {
    return null;
  }
};

