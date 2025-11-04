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
  permissions?: Permission[];
  roles?: Role[];
  requiresPasswordChange?: boolean;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
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

  const login = async (email: string, password: string) => {
    try {
      const response = await apiClient.post('/auth/login', { email, password });
      if (response.data.success) {
        const { user, token, requiresPasswordChange } = response.data.data;
        setAuthToken(token);
        
        // Fetch full user data with permissions
        const meResponse = await apiClient.get('/auth/me');
        if (meResponse.data.success) {
          const userData = meResponse.data.data;
          setUser({
            ...userData,
            permissions: userData.permissions || [],
            roles: userData.roles || [],
            requiresPasswordChange: requiresPasswordChange || userData.requiresPasswordChange || false,
          });
        } else {
          // Fallback to basic user data
          setUser({
            ...user,
            permissions: [],
            roles: [],
            requiresPasswordChange: requiresPasswordChange || false,
          });
        }
        
        // If password change is required, redirect to change password page
        if (requiresPasswordChange) {
          router.push('/change-password');
        } else {
          router.push(user.role === 'PLATFORM_OWNER' ? '/company' : '/merchant');
        }
      }
    } catch (error: any) {
      throw new Error(error.response?.data?.error || 'Login failed');
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
        logout,
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

