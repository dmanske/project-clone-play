import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import type { SuperAdminUser, UseSuperAdminReturn } from '@/types/multi-tenant';

export const useSuperAdmin = (): UseSuperAdminReturn => {
  const { user } = useAuth();
  const [isSuperAdmin, setIsSuperAdmin] = useState(false);
  const [superAdminData, setSuperAdminData] = useState<SuperAdminUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Verificar se o usuário é super admin
  const checkSuperAdmin = async () => {
    if (!user) {
      setIsSuperAdmin(false);
      setSuperAdminData(null);
      setIsLoading(false);
      return;
    }

    try {
      const { data, error } = await supabase
        .from('super_admin_users')
        .select('*')
        .eq('user_id', user.id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') {
          // Não encontrado - não é super admin
          setIsSuperAdmin(false);
          setSuperAdminData(null);
        } else {
          console.error('Erro ao verificar super admin:', error);
          setIsSuperAdmin(false);
          setSuperAdminData(null);
        }
      } else {
        setIsSuperAdmin(true);
        setSuperAdminData(data);
      }
    } catch (error) {
      console.error('Erro ao verificar super admin:', error);
      setIsSuperAdmin(false);
      setSuperAdminData(null);
    } finally {
      setIsLoading(false);
    }
  };

  // Verificar se pode acessar um tenant específico
  const canAccessTenant = (organizationId: string): boolean => {
    return isSuperAdmin && superAdminData?.can_access_all_tenants === true;
  };

  // Trocar para um tenant específico (apenas super admins)
  const switchToTenant = async (organizationId: string): Promise<void> => {
    if (!canAccessTenant(organizationId)) {
      throw new Error('Você não tem permissão para acessar esta organização');
    }

    // TODO: Implementar lógica de troca de tenant
    // Por enquanto, apenas logamos
    console.log('Switching to tenant:', organizationId);
  };

  useEffect(() => {
    checkSuperAdmin();
  }, [user]);

  return {
    isSuperAdmin,
    superAdminData,
    canAccessTenant,
    switchToTenant,
    isLoading
  };
};