import React from 'react';
import { usePermissions } from '@/hooks/usePermissions';
import { useOrganizationStatus } from '@/contexts/TenantContext';
import type { UserPermissions } from '@/types/multi-tenant';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Lock, AlertTriangle } from 'lucide-react';

interface PermissionGuardProps {
  children: React.ReactNode;
  module: keyof UserPermissions;
  action?: 'read' | 'write' | 'delete';
  fallback?: React.ReactNode;
  requireActive?: boolean;
}

export const PermissionGuard: React.FC<PermissionGuardProps> = ({
  children,
  module,
  action = 'read',
  fallback,
  requireActive = true
}) => {
  const { canAccess, isLoading } = usePermissions();
  const { isActive, isExpired } = useOrganizationStatus();

  // Mostrar loading
  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-4">
        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  // Verificar se organização está ativa (se necessário)
  if (requireActive && !isActive) {
    return (
      <Alert className="border-red-200 bg-red-50">
        <AlertTriangle className="h-4 w-4 text-red-600" />
        <AlertDescription className="text-red-800">
          {isExpired 
            ? 'Sua assinatura expirou. Entre em contato para reativar sua conta.'
            : 'Sua conta está suspensa. Entre em contato com o suporte.'
          }
        </AlertDescription>
      </Alert>
    );
  }

  // Verificar permissão
  const hasPermission = canAccess(module, action);

  if (!hasPermission) {
    if (fallback) {
      return <>{fallback}</>;
    }

    return (
      <Alert className="border-yellow-200 bg-yellow-50">
        <Lock className="h-4 w-4 text-yellow-600" />
        <AlertDescription className="text-yellow-800">
          Você não tem permissão para acessar esta funcionalidade.
        </AlertDescription>
      </Alert>
    );
  }

  return <>{children}</>;
};

// Componente para proteger botões/ações específicas
interface ActionGuardProps {
  children: React.ReactNode;
  module: keyof UserPermissions;
  action: 'read' | 'write' | 'delete';
  fallback?: React.ReactNode;
  requireActive?: boolean;
}

export const ActionGuard: React.FC<ActionGuardProps> = ({
  children,
  module,
  action,
  fallback = null,
  requireActive = true
}) => {
  const { canAccess } = usePermissions();
  const { isActive } = useOrganizationStatus();

  // Verificar se organização está ativa
  if (requireActive && !isActive) {
    return <>{fallback}</>;
  }

  // Verificar permissão
  const hasPermission = canAccess(module, action);

  if (!hasPermission) {
    return <>{fallback}</>;
  }

  return <>{children}</>;
};

// Hook para usar dentro de componentes
export const usePermissionGuard = () => {
  const { canAccess, guard } = usePermissions();
  const { isActive, isExpired } = useOrganizationStatus();

  return {
    canAccess,
    guard,
    isActive,
    isExpired,
    
    // Função auxiliar para verificar se pode renderizar algo
    canRender: (
      module: keyof UserPermissions, 
      action: 'read' | 'write' | 'delete' = 'read',
      requireActive: boolean = true
    ) => {
      if (requireActive && !isActive) return false;
      return canAccess(module, action);
    }
  };
};