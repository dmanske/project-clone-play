import React from 'react';
import { useOrganizationStatus, useTenant } from '@/contexts/TenantContext';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { AlertTriangle, Clock, CreditCard, CheckCircle } from 'lucide-react';
import { ORGANIZATION_STATUS_LABELS, ORGANIZATION_STATUS_COLORS } from '@/types/multi-tenant';

export const OrganizationStatusBanner: React.FC = () => {
  const { tenant } = useTenant();
  const { 
    isActive, 
    isTrial, 
    status, 
    daysUntilExpiry, 
    isExpired, 
    isExpiringSoon 
  } = useOrganizationStatus();

  if (!tenant || !status) return null;

  // Não mostrar banner se está ativo e não é trial
  if (isActive && !isTrial) return null;

  const getIcon = () => {
    switch (status) {
      case 'TRIAL':
        return isExpiringSoon ? <AlertTriangle className="h-4 w-4" /> : <Clock className="h-4 w-4" />;
      case 'SUSPENDED':
        return <CreditCard className="h-4 w-4" />;
      case 'BLOCKED':
        return <AlertTriangle className="h-4 w-4" />;
      default:
        return <CheckCircle className="h-4 w-4" />;
    }
  };

  const getMessage = () => {
    switch (status) {
      case 'TRIAL':
        if (isExpired) {
          return 'Seu período trial expirou. Atualize seu plano para continuar usando o sistema.';
        }
        if (isExpiringSoon) {
          return `Seu período trial expira em ${daysUntilExpiry} dia(s). Atualize seu plano para não perder o acesso.`;
        }
        return `Você está no período trial. ${daysUntilExpiry} dia(s) restante(s).`;
      
      case 'SUSPENDED':
        return 'Sua conta está suspensa por falta de pagamento. Regularize sua situação para continuar usando o sistema.';
      
      case 'BLOCKED':
        return 'Sua conta foi bloqueada. Entre em contato com o suporte para mais informações.';
      
      default:
        return 'Status da conta desconhecido.';
    }
  };

  const getVariant = () => {
    if (isExpired || status === 'BLOCKED') return 'destructive';
    if (isExpiringSoon || status === 'SUSPENDED') return 'default';
    return 'default';
  };

  const getBgColor = () => {
    if (isExpired || status === 'BLOCKED') return 'bg-red-50 border-red-200';
    if (isExpiringSoon || status === 'SUSPENDED') return 'bg-yellow-50 border-yellow-200';
    return 'bg-blue-50 border-blue-200';
  };

  const getTextColor = () => {
    if (isExpired || status === 'BLOCKED') return 'text-red-800';
    if (isExpiringSoon || status === 'SUSPENDED') return 'text-yellow-800';
    return 'text-blue-800';
  };

  return (
    <Alert className={`mb-4 ${getBgColor()}`}>
      <div className={getTextColor()}>
        {getIcon()}
      </div>
      <div className="flex items-center justify-between w-full">
        <AlertDescription className={`${getTextColor()} flex-1`}>
          <div className="flex items-center gap-2">
            <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${ORGANIZATION_STATUS_COLORS[status]}`}>
              {ORGANIZATION_STATUS_LABELS[status]}
            </span>
            <span>{getMessage()}</span>
          </div>
        </AlertDescription>
        
        {(isTrial || status === 'SUSPENDED') && (
          <div className="flex gap-2 ml-4">
            <Button 
              size="sm" 
              variant={getVariant()}
              onClick={() => {
                // TODO: Implementar redirecionamento para página de pagamento
                console.log('Redirecionar para pagamento');
              }}
            >
              {isTrial ? 'Ativar Plano' : 'Regularizar Pagamento'}
            </Button>
          </div>
        )}
      </div>
    </Alert>
  );
};

// Componente menor para mostrar apenas o status
export const OrganizationStatusBadge: React.FC = () => {
  const { tenant } = useTenant();
  const { status } = useOrganizationStatus();

  if (!tenant || !status) return null;

  return (
    <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${ORGANIZATION_STATUS_COLORS[status]}`}>
      {ORGANIZATION_STATUS_LABELS[status]}
    </span>
  );
};