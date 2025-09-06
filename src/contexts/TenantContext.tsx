import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from './AuthContext';
import type { 
  TenantContext as TenantContextType, 
  OrganizationSubscription, 
  OrganizationSettings, 
  UserPermissions,
  UseTenantReturn 
} from '@/types/multi-tenant';
import { toast } from 'sonner';

const TenantContext = createContext<UseTenantReturn | undefined>(undefined);

export const TenantProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { user, profile } = useAuth();
  const [tenant, setTenant] = useState<TenantContextType | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Função para buscar dados do tenant
  const fetchTenantData = async (organizationId: string): Promise<TenantContextType | null> => {
    try {
      // Buscar organização
      const { data: organization, error: orgError } = await supabase
        .from('organizations')
        .select('id, name, slug, logo_url')
        .eq('id', organizationId)
        .single();

      if (orgError) throw orgError;

      // Buscar assinatura
      const { data: subscription, error: subError } = await supabase
        .from('organization_subscriptions')
        .select('*')
        .eq('organization_id', organizationId)
        .single();

      if (subError) throw subError;

      // Buscar configurações
      const { data: settings, error: settingsError } = await supabase
        .from('organization_settings')
        .select('*')
        .eq('organization_id', organizationId)
        .single();

      if (settingsError) throw settingsError;

      // Buscar permissões do usuário
      const { data: permissions, error: permError } = await supabase
        .from('user_permissions')
        .select('permissions')
        .eq('user_id', user?.id)
        .eq('organization_id', organizationId)
        .single();

      if (permError) throw permError;

      // Verificar se está ativo
      const isActive = await checkOrganizationStatus(subscription);
      const isTrial = subscription.status === 'TRIAL';
      
      // Calcular dias até expirar
      let daysUntilExpiry: number | undefined;
      if (isTrial) {
        const trialEnd = new Date(subscription.trial_end_date);
        const now = new Date();
        const diffTime = trialEnd.getTime() - now.getTime();
        daysUntilExpiry = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      }

      return {
        organization,
        subscription,
        settings,
        permissions: permissions.permissions,
        isActive,
        isTrial,
        daysUntilExpiry
      };
    } catch (error) {
      console.error('Erro ao buscar dados do tenant:', error);
      return null;
    }
  };

  // Função para verificar status da organização
  const checkOrganizationStatus = async (subscription: OrganizationSubscription): Promise<boolean> => {
    const now = new Date();
    
    switch (subscription.status) {
      case 'ACTIVE':
        return true;
      case 'TRIAL':
        return new Date(subscription.trial_end_date) > now;
      case 'SUSPENDED':
      case 'BLOCKED':
      default:
        return false;
    }
  };

  // Função para atualizar dados do tenant
  const refreshTenant = async () => {
    // Se não há usuário ou profile, limpar tenant imediatamente
    if (!user || !profile?.organization_id) {
      setTenant(null);
      setError(null);
      setIsLoading(false);
      return;
    }
  
    setIsLoading(true);
    setError(null);
  
    try {
      const tenantData = await fetchTenantData(profile.organization_id);
      
      if (!tenantData) {
        throw new Error('Não foi possível carregar os dados da organização');
      }
  
      setTenant(tenantData);
    } catch (err: any) {
      console.error('Erro ao carregar tenant:', err);
      setError(err.message || 'Erro ao carregar dados da organização');
      // Não mostrar toast se o usuário não está logado
      if (user && profile) {
        toast.error('Erro ao carregar dados da organização');
      }
    } finally {
      setIsLoading(false);
    }
  };

  // Função para trocar de tenant (para super admins)
  const switchTenant = async (organizationId: string) => {
    setIsLoading(true);
    setError(null);

    try {
      // Verificar se o usuário tem permissão (deve ser super admin)
      const { data: superAdminData } = await supabase
        .from('super_admin_users')
        .select('can_access_all_tenants')
        .eq('user_id', user?.id)
        .single();

      if (!superAdminData?.can_access_all_tenants) {
        throw new Error('Você não tem permissão para acessar outras organizações');
      }

      const tenantData = await fetchTenantData(organizationId);
      
      if (!tenantData) {
        throw new Error('Organização não encontrada');
      }

      setTenant(tenantData);
      toast.success(`Alternado para: ${tenantData.organization.name}`);
    } catch (err: any) {
      console.error('Erro ao trocar tenant:', err);
      setError(err.message || 'Erro ao trocar de organização');
      toast.error('Erro ao trocar de organização');
    } finally {
      setIsLoading(false);
    }
  };

  // Carregar dados do tenant quando o usuário mudar
  useEffect(() => {
    refreshTenant();
  }, [user, profile]);

  // Verificar status periodicamente (a cada 5 minutos)
  useEffect(() => {
    if (!tenant) return;

    const interval = setInterval(async () => {
      if (tenant.subscription) {
        const isActive = await checkOrganizationStatus(tenant.subscription);
        
        if (isActive !== tenant.isActive) {
          // Status mudou, recarregar dados
          await refreshTenant();
        }
      }
    }, 5 * 60 * 1000); // 5 minutos

    return () => clearInterval(interval);
  }, [tenant]);

  // Mostrar aviso se trial está expirando
  useEffect(() => {
    if (tenant?.isTrial && tenant.daysUntilExpiry !== undefined) {
      if (tenant.daysUntilExpiry <= 3 && tenant.daysUntilExpiry > 0) {
        toast.warning(
          `Seu período trial expira em ${tenant.daysUntilExpiry} dia(s). Atualize seu plano para continuar usando o sistema.`,
          { duration: 10000 }
        );
      } else if (tenant.daysUntilExpiry <= 0) {
        toast.error(
          'Seu período trial expirou. Entre em contato para ativar sua assinatura.',
          { duration: 15000 }
        );
      }
    }
  }, [tenant?.daysUntilExpiry]);

  return (
    <TenantContext.Provider value={{
      tenant,
      isLoading,
      error,
      refreshTenant,
      switchTenant
    }}>
      {children}
    </TenantContext.Provider>
  );
};

export const useTenant = (): UseTenantReturn => {
  const context = useContext(TenantContext);
  
  if (context === undefined) {
    throw new Error('useTenant deve ser usado dentro de um TenantProvider');
  }
  
  return context;
};

// Hook para verificar se a organização está ativa
export const useOrganizationStatus = () => {
  const { tenant } = useTenant();
  
  return {
    isActive: tenant?.isActive ?? false,
    isTrial: tenant?.isTrial ?? false,
    status: tenant?.subscription?.status,
    daysUntilExpiry: tenant?.daysUntilExpiry,
    isExpired: tenant?.daysUntilExpiry !== undefined && tenant.daysUntilExpiry <= 0,
    isExpiringSoon: tenant?.daysUntilExpiry !== undefined && tenant.daysUntilExpiry <= 3 && tenant.daysUntilExpiry > 0
  };
};