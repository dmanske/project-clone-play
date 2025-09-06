import React, { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useSuperAdmin } from '@/hooks/useSuperAdmin';
import { useTenant } from '@/contexts/TenantContext';
import { Button } from '@/components/ui/button';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Building2, Crown, Loader2 } from 'lucide-react';
import { ORGANIZATION_STATUS_COLORS, ORGANIZATION_STATUS_LABELS } from '@/types/multi-tenant';
import type { OrganizationStatus } from '@/types/multi-tenant';

interface Organization {
  id: string;
  name: string;
  slug: string;
  subscription_status: OrganizationStatus;
  trial_end_date?: string;
}

export const TenantSelector: React.FC = () => {
  const { isSuperAdmin, isLoading: superAdminLoading } = useSuperAdmin();
  const { tenant, switchTenant } = useTenant();
  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isSwitching, setIsSwitching] = useState(false);

  // Buscar todas as organizações (apenas para super admins)
  const fetchOrganizations = async () => {
    if (!isSuperAdmin) return;

    setIsLoading(true);
    try {
      const { data, error } = await supabase
        .from('organizations')
        .select(`
          id,
          name,
          slug,
          organization_subscriptions!inner(
            status,
            trial_end_date
          )
        `)
        .order('name');

      if (error) throw error;

      const orgs: Organization[] = data.map(org => ({
        id: org.id,
        name: org.name,
        slug: org.slug,
        subscription_status: org.organization_subscriptions[0]?.status || 'TRIAL',
        trial_end_date: org.organization_subscriptions[0]?.trial_end_date
      }));

      setOrganizations(orgs);
    } catch (error) {
      console.error('Erro ao buscar organizações:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Trocar de tenant
  const handleTenantSwitch = async (organizationId: string) => {
    setIsSwitching(true);
    try {
      await switchTenant(organizationId);
    } catch (error) {
      console.error('Erro ao trocar tenant:', error);
    } finally {
      setIsSwitching(false);
    }
  };

  useEffect(() => {
    if (isSuperAdmin && !superAdminLoading) {
      fetchOrganizations();
    }
  }, [isSuperAdmin, superAdminLoading]);

  // Não mostrar se não for super admin
  if (!isSuperAdmin || superAdminLoading) {
    return null;
  }

  return (
    <div className="flex items-center gap-3 p-3 bg-gradient-to-r from-purple-50 to-blue-50 border border-purple-200 rounded-lg">
      <div className="flex items-center gap-2">
        <Crown className="h-4 w-4 text-purple-600" />
        <span className="text-sm font-medium text-purple-700">Super Admin</span>
      </div>

      <div className="flex items-center gap-2">
        <Building2 className="h-4 w-4 text-gray-600" />
        <span className="text-sm text-gray-600">Organização:</span>
      </div>

      <Select
        value={tenant?.organization.id || ''}
        onValueChange={handleTenantSwitch}
        disabled={isLoading || isSwitching}
      >
        <SelectTrigger className="w-64">
          <SelectValue placeholder="Selecione uma organização">
            {tenant && (
              <div className="flex items-center gap-2">
                <span>{tenant.organization.name}</span>
                <Badge 
                  variant="secondary" 
                  className={ORGANIZATION_STATUS_COLORS[tenant.subscription.status]}
                >
                  {ORGANIZATION_STATUS_LABELS[tenant.subscription.status]}
                </Badge>
              </div>
            )}
          </SelectValue>
        </SelectTrigger>
        <SelectContent>
          {isLoading ? (
            <div className="flex items-center justify-center p-4">
              <Loader2 className="h-4 w-4 animate-spin" />
              <span className="ml-2 text-sm">Carregando...</span>
            </div>
          ) : (
            organizations.map((org) => (
              <SelectItem key={org.id} value={org.id}>
                <div className="flex items-center justify-between w-full">
                  <span>{org.name}</span>
                  <Badge 
                    variant="secondary" 
                    className={`ml-2 ${ORGANIZATION_STATUS_COLORS[org.subscription_status]}`}
                  >
                    {ORGANIZATION_STATUS_LABELS[org.subscription_status]}
                  </Badge>
                </div>
              </SelectItem>
            ))
          )}
        </SelectContent>
      </Select>

      {isSwitching && (
        <div className="flex items-center gap-1 text-sm text-gray-600">
          <Loader2 className="h-3 w-3 animate-spin" />
          <span>Alternando...</span>
        </div>
      )}
    </div>
  );
};

// Componente menor para mostrar apenas o tenant atual
export const CurrentTenantBadge: React.FC = () => {
  const { tenant } = useTenant();
  const { isSuperAdmin } = useSuperAdmin();

  if (!tenant) return null;

  return (
    <div className="flex items-center gap-2">
      <Building2 className="h-4 w-4 text-gray-600" />
      <span className="text-sm font-medium">{tenant.organization.name}</span>
      <Badge 
        variant="secondary" 
        className={ORGANIZATION_STATUS_COLORS[tenant.subscription.status]}
      >
        {ORGANIZATION_STATUS_LABELS[tenant.subscription.status]}
      </Badge>
      {isSuperAdmin && (
        <Badge variant="outline" className="text-purple-600 border-purple-300">
          Super Admin
        </Badge>
      )}
    </div>
  );
};