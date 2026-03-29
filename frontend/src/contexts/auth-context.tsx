'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import apiClient from '@/lib/api';
import { getAuthToken, setAuthToken, removeAuthToken } from '@/lib/auth';

interface Permission {
  featureSlug: string;
  featureId: string;
  actions: string[];
}

interface Role {
  id: string;
  name: string;
  type: string;
}

interface User {
  id: string;
  email: string;
  firstName: string;
  lastName?: string;
  role: string;
  merchantId?: string;
  companyId?: string;
  /** Nested merchant row from Prisma (`/auth/me`); includes `currency` (ISO 4217). */
  merchants?: { id?: string; currency?: string } | null;
  permissions?: Permission[];
  roles?: Role[];
  requiresPasswordChange?: boolean;
}

export type LoginPasswordPayload =
  | { email: string; password: string }
  | {
      password: string;
      phoneCountryIso: string;
      phoneNationalNumber: string;
    }
  | { password: string; phone: string };

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (payload: LoginPasswordPayload) => Promise<void>;
  gatewayLoginVerify: (requestId: string, code: string) => Promise<void>;
  logout: () => void;
  refreshUser: () => Promise<void>;
  isAuthenticated: boolean;
  isPlatformOwner: boolean;
  isMerchantAdmin: boolean;
  isMerchantStaff: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    // Check if user is already logged in
    const token = getAuthToken();
    if (token) {
      fetchCurrentUser();
    } else {
      setLoading(false);
    }
  }, []);

  const fetchCurrentUser = async () => {
    try {
      const response = await apiClient.get('/auth/me');
      if (response.data.success) {
        const userData = response.data.data;
        // Ensure permissions and roles are included
        setUser({
          ...userData,
          permissions: userData.permissions || [],
          roles: userData.roles || [],
          requiresPasswordChange: userData.requiresPasswordChange || false,
        });
      }
    } catch (error) {
      // Token might be invalid, clear it
      removeAuthToken();
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  const refreshUser = async () => {
    const token = getAuthToken();
    if (!token) return;
    try {
      const response = await apiClient.get('/auth/me');
      if (response.data.success) {
        const userData = response.data.data;
        setUser({
          ...userData,
          permissions: userData.permissions || [],
          roles: userData.roles || [],
          requiresPasswordChange: userData.requiresPasswordChange || false,
        });
      }
    } catch {
      // leave existing user on failure
    }
  };

  const applyLoginSuccess = async (
    user: { role: string },
    token: string,
    requiresPasswordChange: boolean
  ) => {
    setAuthToken(token);

    const meResponse = await apiClient.get('/auth/me');
    let role = user.role;
    if (meResponse.data.success) {
      const userData = meResponse.data.data;
      role = userData.role ?? role;
      setUser({
        ...userData,
        permissions: userData.permissions || [],
        roles: userData.roles || [],
        requiresPasswordChange: requiresPasswordChange || userData.requiresPasswordChange || false,
      });
    } else {
      const u = user as User;
      setUser({
        ...u,
        permissions: [],
        roles: [],
        requiresPasswordChange: requiresPasswordChange || u.requiresPasswordChange || false,
      });
    }

    const needPw =
      requiresPasswordChange || (meResponse.data.success && meResponse.data.data?.requiresPasswordChange);
    if (needPw) {
      router.push('/change-password');
    } else {
      router.push(role === 'PLATFORM_OWNER' ? '/company' : '/merchant');
    }
  };

  const login = async (payload: LoginPasswordPayload) => {
    try {
      const response = await apiClient.post('/auth/login', payload);
      if (response.data.success) {
        const { user, token, requiresPasswordChange } = response.data.data;
        await applyLoginSuccess(user, token, requiresPasswordChange);
      }
    } catch (error: any) {
      throw new Error(error.response?.data?.error || 'Login failed');
    }
  };

  const gatewayLoginVerify = async (requestId: string, code: string) => {
    try {
      const response = await apiClient.post('/auth/login/gateway/verify', { requestId, code });
      if (response.data.success) {
        const { user, token, requiresPasswordChange } = response.data.data;
        await applyLoginSuccess(user, token, requiresPasswordChange);
      }
    } catch (error: any) {
      throw new Error(error.response?.data?.error || 'Verification failed');
    }
  };

  const logout = () => {
    removeAuthToken();
    setUser(null);
    router.push('/login');
  };

  const isPlatformOwner = user?.role === 'PLATFORM_OWNER';
  const isMerchantAdmin = user?.role === 'MERCHANT_ADMIN';
  const isMerchantStaff = user?.role === 'MERCHANT_STAFF';

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        login,
        gatewayLoginVerify,
        logout,
        refreshUser,
        isAuthenticated: !!user,
        isPlatformOwner,
        isMerchantAdmin,
        isMerchantStaff,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

