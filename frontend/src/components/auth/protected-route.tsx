'use client';

import { useEffect, useContext } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/auth-context';
import { PermissionsContext } from '@/contexts/permissions-context';
import { Loader2 } from 'lucide-react';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: string[];
  requiredFeature?: string;
  requiredAction?: string;
}

export function ProtectedRoute({ children, allowedRoles, requiredFeature, requiredAction }: ProtectedRouteProps) {
  const { user, loading, isAuthenticated } = useAuth();
  const router = useRouter();
  
  // Get permissions context if available
  const permissionsContext = useContext(PermissionsContext);

  useEffect(() => {
    if (!loading) {
      if (!isAuthenticated) {
        router.push('/login');
        return;
      }

      // Check role-based access
      if (allowedRoles && user && !allowedRoles.includes(user.role)) {
        router.push('/unauthorized');
        return;
      }

      // Check feature-based access
      if (requiredFeature && permissionsContext) {
        const hasAccess = permissionsContext.canAccess(requiredFeature, requiredAction);
        if (!hasAccess) {
          router.push('/unauthorized');
          return;
        }
      }

      // Check password change requirement
      if (user?.requiresPasswordChange && !window.location.pathname.includes('/change-password')) {
        router.push('/change-password');
        return;
      }
    }
  }, [loading, isAuthenticated, user, allowedRoles, requiredFeature, requiredAction, permissionsContext, router]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  if (!isAuthenticated) {
    return null;
  }

  // Check role-based access
  if (allowedRoles && user && !allowedRoles.includes(user.role)) {
    return null;
  }

  // Check feature-based access
  if (requiredFeature && permissionsContext && !permissionsContext.canAccess(requiredFeature, requiredAction)) {
    return null;
  }

  return <>{children}</>;
}

