import { useMemo } from 'react';
import { useAuth } from '@/contexts/AuthContext';

/**
 * Hook para acessar as configurações da organização atual do usuário logado
 */
export const useOrganization = () => {
  const { profile } = useAuth();

  const organization = useMemo(() => {
    return profile?.organization || null;
  }, [profile?.organization]);

  const organizationConfig = useMemo(() => {
    if (!organization) return null;

    return {
      id: organization.id,
      name: organization.name,
      slug: organization.slug,
      logoUrl: organization.logo_url,
      timeCasaPadrao: organization.time_casa_padrao,
      corPrimaria: organization.cor_primaria,
      corSecundaria: organization.cor_secundaria,
    };
  }, [organization]);

  const hasOrganization = useMemo(() => {
    return !!organization;
  }, [organization]);

  const isOrganizationLoaded = useMemo(() => {
    return profile !== null;
  }, [profile]);

  return {
    organization,
    organizationConfig,
    hasOrganization,
    isOrganizationLoaded,
    // Funções de conveniência para acessar configurações específicas
    getLogoUrl: () => organization?.logo_url || null,
    getTimeCasaPadrao: () => organization?.time_casa_padrao || null,
    getCorPrimaria: () => organization?.cor_primaria || null,
    getCorSecundaria: () => organization?.cor_secundaria || null,
    getName: () => organization?.name || null,
    getId: () => organization?.id || null,
  };
};