import React from 'react';
import { usePermissions } from '@/hooks/usePermissions';
import type { UserPermissions } from '@/types/multi-tenant';

interface ProtectedNavItemProps {
  children: React.ReactNode;
  module?: keyof UserPermissions;
  action?: 'read' | 'write' | 'delete';
  requirePermission?: boolean;
}

export const ProtectedNavItem: React.FC<ProtectedNavItemProps> = ({
  children,
  module,
  action = 'read',
  requirePermission = true
}) => {
  const { canAccess } = usePermissions();

  // Se não requer permissão, sempre mostra
  if (!requirePermission || !module) {
    return <>{children}</>;
  }

  // Verificar se tem permissão
  const hasPermission = canAccess(module, action);

  if (!hasPermission) {
    return null;
  }

  return <>{children}</>;
};