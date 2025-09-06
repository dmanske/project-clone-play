import React from 'react';
import { useTenant, useOrganizationStatus } from '@/contexts/TenantContext';
import { useSuperAdmin } from '@/hooks/useSuperAdmin';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { AlertTriangle, Lock, Loader2 } from 'lucide-react';

interface TenantProtectionProps {
  children: React.ReactNode;
  requireActive?: boolean;
  fallback?: React.ReactNode;
}

export const TenantProtection: React.FC<TenantProtectionProps> = ({
  children,
  requireActive = true,
  fallback
}) => {
  const { tenant, isLoading: tenantLoading } = useTenant();
  const { isActive, isExpired, status } = useOrganizationStatus();
  const { isSuperAdmin, isLoading: superAdminLoading } = useSuperAdmin();

  // Mostrar loading enquanto carrega
  if (tenantLoading || superAdminLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="flex items-center gap-2 text-gray-600">
          <Loader2 className="h-5 w-5 animate-spin" />
          <span>Carregando...</span>
        </div>
      </div>
    );
  }

  // Super admin sempre tem acesso
  if (isSuperAdmin) {
    return <>{children}</>;
  }

  // Verificar se tem tenant
  if (!tenant) {
    if (fallback) {
      return <>{fallback}</>;
    }

    return (
      <Alert className="border-red-200 bg-red-50">
        <Lock className="h-4 w-4 text-red-600" />
        <AlertDescription className="text-red-800">
          Não foi possível carregar os dados da organização. Tente fazer login novamente.
        </AlertDescription>
      </Alert>
    );
  }

  // Verificar se organização está ativa (se necessário)
  if (requireActive && !isActive) {
    if (fallback) {
      return <>{fallback}</>;
    }

    return (
      <Alert className="border-red-200 bg-red-50">
        <AlertTriangle className="h-4 w-4 text-red-600" />
        <AlertDescription className="text-red-800">
          <div className="space-y-2">
            <p>
              {isExpired 
                ? 'Sua assinatura expirou. Entre em contato para reativar sua conta.'
                : 'Sua conta está suspensa. Entre em contato com o suporte.'
              }
            </p>
            <Button 
              size="sm" 
              variant="destructive"
              onClick={() => {
                // TODO: Implementar redirecionamento para página de pagamento
                console.log('Redirecionar para pagamento');
              }}
            >
              {isExpired ? 'Renovar Assinatura' : 'Regularizar Pagamento'}
            </Button>
          </div>
        </AlertDescription>
      </Alert>
    );
  }

  return <>{children}</>;
};

// Componente para proteger rotas específicas
interface RouteProtectionProps {
  children: React.ReactNode;
  requiredModule?: keyof import('@/types/multi-tenant').UserPermissions;
  requiredAction?: 'read' | 'write' | 'delete';
  requireActive?: boolean;
}

export const RouteProtection: React.FC<RouteProtectionProps> = ({
  children,
  requiredModule,
  requiredAction = 'read',
  requireActive = true
}) => {
  return (
    <TenantProtection requireActive={requireActive}>
      {requiredModule ? (
        <PermissionGuard module={requiredModule} action={requiredAction}>
          {children}
        </PermissionGuard>
      ) : (
        children
      )}
    </TenantProtection>
  );
};

// Importar PermissionGuard para usar no RouteProtection
import { PermissionGuard } from './PermissionGuard';