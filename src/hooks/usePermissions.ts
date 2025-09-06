import { useMemo } from 'react';
import { useTenant } from '@/contexts/TenantContext';
import { useAuth } from '@/contexts/AuthContext';
import { useSuperAdmin } from './useSuperAdmin';
import type { 
  UserPermissions, 
  TenantGuard, 
  UsePermissionsReturn 
} from '@/types/multi-tenant';

export const usePermissions = (): UsePermissionsReturn => {
  const { tenant, isLoading } = useTenant();
  const { profile } = useAuth();
  const { isSuperAdmin } = useSuperAdmin();

  // Criar guard de permissões
  const guard = useMemo<TenantGuard>(() => {
    const permissions = tenant?.permissions;
    const userRole = profile?.role;

    return {
      canRead: (module: keyof UserPermissions) => {
        // Super admin tem acesso total
        if (isSuperAdmin) return true;
        if (!permissions) return false;
        return permissions[module]?.read ?? false;
      },

      canWrite: (module: keyof UserPermissions) => {
        // Super admin tem acesso total
        if (isSuperAdmin) return true;
        if (!permissions) return false;
        return permissions[module]?.write ?? false;
      },

      canDelete: (module: keyof UserPermissions) => {
        // Super admin tem acesso total
        if (isSuperAdmin) return true;
        if (!permissions) return false;
        return permissions[module]?.delete ?? false;
      },

      isAdmin: () => {
        return userRole === 'admin' || userRole === 'owner' || isSuperAdmin;
      },

      isOwner: () => {
        return userRole === 'owner' || isSuperAdmin;
      },

      isSuperAdmin: () => {
        return isSuperAdmin;
      }
    };
  }, [tenant?.permissions, profile?.role, isSuperAdmin]);

  // Função auxiliar para verificar acesso
  const canAccess = (
    module: keyof UserPermissions, 
    action: 'read' | 'write' | 'delete'
  ): boolean => {
    switch (action) {
      case 'read':
        return guard.canRead(module);
      case 'write':
        return guard.canWrite(module);
      case 'delete':
        return guard.canDelete(module);
      default:
        return false;
    }
  };

  return {
    permissions: tenant?.permissions ?? null,
    guard,
    isLoading,
    canAccess
  };
};

// Hook específico para verificar se pode acessar uma rota
export const useRoutePermission = (module: keyof UserPermissions, action: 'read' | 'write' | 'delete' = 'read') => {
  const { canAccess, isLoading } = usePermissions();
  
  return {
    canAccess: canAccess(module, action),
    isLoading
  };
};

// Hook para verificar múltiplas permissões
export const useMultiplePermissions = (checks: Array<{ module: keyof UserPermissions; action: 'read' | 'write' | 'delete' }>) => {
  const { canAccess, isLoading } = usePermissions();
  
  const results = useMemo(() => {
    return checks.reduce((acc, check) => {
      acc[`${check.module}_${check.action}`] = canAccess(check.module, check.action);
      return acc;
    }, {} as Record<string, boolean>);
  }, [canAccess, checks]);
  
  return {
    permissions: results,
    isLoading,
    hasAnyPermission: Object.values(results).some(Boolean),
    hasAllPermissions: Object.values(results).every(Boolean)
  };
};