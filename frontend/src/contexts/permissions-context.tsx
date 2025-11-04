'use client';

import { createContext, useContext, ReactNode } from 'react';
import { useAuth } from './auth-context';

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

interface PermissionsContextType {
  permissions: Permission[];
  roles: Role[];
  hasFeature: (featureSlug: string) => boolean;
  hasAction: (featureSlug: string, action: string) => boolean;
  canAccess: (featureSlug: string, action?: string) => boolean;
  getUserRoles: () => Role[];
}

const PermissionsContext = createContext<PermissionsContextType | undefined>(undefined);

// Export context for direct use when needed
export { PermissionsContext };

export function PermissionsProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();

  const permissions: Permission[] = user?.permissions || [];
  const roles: Role[] = user?.roles || [];

  const hasFeature = (featureSlug: string): boolean => {
    return permissions.some((p) => p.featureSlug === featureSlug);
  };

  const hasAction = (featureSlug: string, action: string): boolean => {
    const permission = permissions.find((p) => p.featureSlug === featureSlug);
    if (!permission) {
      return false;
    }

    // If it's a page-level feature, having the feature means all actions are allowed
    // For action-level features, check if the specific action is in the actions array
    // Since we don't have feature metadata in the context, we'll check if actions array is empty
    // Empty actions array typically means page-level access (all actions allowed)
    if (permission.actions.length === 0) {
      return true; // Page-level feature, all actions allowed
    }

    return permission.actions.includes(action);
  };

  const canAccess = (featureSlug: string, action?: string): boolean => {
    if (action) {
      return hasAction(featureSlug, action);
    }
    return hasFeature(featureSlug);
  };

  const getUserRoles = (): Role[] => {
    return roles;
  };

  return (
    <PermissionsContext.Provider
      value={{
        permissions,
        roles,
        hasFeature,
        hasAction,
        canAccess,
        getUserRoles,
      }}
    >
      {children}
    </PermissionsContext.Provider>
  );
}

export function usePermissions() {
  const context = useContext(PermissionsContext);
  if (context === undefined) {
    throw new Error('usePermissions must be used within a PermissionsProvider');
  }
  return context;
}

