import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';
import { useOrganization } from '@/hooks/useOrganization';

export interface OrganizationSettings {
  id: string;
  organization_id: string;
  
  // Branding e Visual
  logo_empresa_url?: string;
  logo_time_url?: string;
  cor_primaria: string;
  cor_secundaria: string;
  favicon_url?: string;
  
  // Informações da Empresa
  nome_empresa?: string;
  endereco_completo?: string;
  telefone?: string;
  email_contato?: string;
  site_url?: string;
  cnpj?: string;
  
  // Configurações de Passeios
  passeios_padrao: any[];
  valor_padrao_passeio?: number;
  
  // Configurações Regionais
  timezone: string;
  moeda: string;
  idioma: string;
  formato_data: string;
  
  // Configurações de Notificações
  email_notificacoes: boolean;
  whatsapp_notificacoes: boolean;
  whatsapp_numero?: string;
  
  // Configurações de Pagamento
  aceita_pix: boolean;
  aceita_cartao: boolean;
  aceita_dinheiro: boolean;
  taxa_cartao: number;
  
  // Configurações de Relatórios
  incluir_logo_relatorios: boolean;
  rodape_personalizado?: string;
  
  // Configurações Avançadas
  configuracoes_extras: Record<string, any>;
  
  // Controle
  created_at: string;
  updated_at: string;
}

export interface OrganizationSettingsUpdate {
  logo_empresa_url?: string;
  logo_time_url?: string;
  cor_primaria?: string;
  cor_secundaria?: string;
  favicon_url?: string;
  nome_empresa?: string;
  endereco_completo?: string;
  telefone?: string;
  email_contato?: string;
  site_url?: string;
  cnpj?: string;
  passeios_padrao?: any[];
  valor_padrao_passeio?: number;
  timezone?: string;
  moeda?: string;
  idioma?: string;
  formato_data?: string;
  email_notificacoes?: boolean;
  whatsapp_notificacoes?: boolean;
  whatsapp_numero?: string;
  aceita_pix?: boolean;
  aceita_cartao?: boolean;
  aceita_dinheiro?: boolean;
  taxa_cartao?: number;
  incluir_logo_relatorios?: boolean;
  rodape_personalizado?: string;
  configuracoes_extras?: Record<string, any>;
}

export const useOrganizationSettings = () => {
  const [settings, setSettings] = useState<OrganizationSettings | null>(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const { organization } = useOrganization();

  // Carregar configurações da organização
  const loadSettings = async () => {
    if (!organization?.id) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      
      // Por enquanto, usar dados da tabela organizations até a migração ser aplicada
      const { data, error } = await supabase
        .from('organizations')
        .select('*')
        .eq('id', organization.id)
        .single();

      if (error) {
        throw error;
      } else {
        // Mapear dados da organização para o formato de settings
        const mappedSettings: OrganizationSettings = {
          id: data.id,
          organization_id: data.id,
          logo_empresa_url: data.logo_url || undefined,
          logo_time_url: undefined,
          cor_primaria: data.cor_primaria || '#000000',
          cor_secundaria: data.cor_secundaria || '#ffffff',
          favicon_url: undefined,
          nome_empresa: data.name,
          endereco_completo: data.endereco || undefined,
          telefone: data.telefone || undefined,
          email_contato: undefined,
          site_url: data.website || undefined,
          cnpj: undefined,
          passeios_padrao: [],
          valor_padrao_passeio: undefined,
          timezone: 'America/Sao_Paulo',
          moeda: 'BRL',
          idioma: 'pt-BR',
          formato_data: 'DD/MM/YYYY',
          email_notificacoes: true,
          whatsapp_notificacoes: false,
          whatsapp_numero: data.whatsapp || undefined,
          aceita_pix: true,
          aceita_cartao: true,
          aceita_dinheiro: true,
          taxa_cartao: 0.00,
          incluir_logo_relatorios: true,
          rodape_personalizado: undefined,
          configuracoes_extras: {},
          created_at: data.created_at,
          updated_at: data.updated_at
        };
        setSettings(mappedSettings);
      }
    } catch (error) {
      console.error('Erro ao carregar configurações:', error);
      toast.error('Não foi possível carregar as configurações da organização.');
    } finally {
      setLoading(false);
    }
  };

  // Criar configurações padrão
  const createDefaultSettings = async () => {
    if (!organization?.id) return;

    try {
      // Por enquanto, apenas recarregar as configurações existentes
      await loadSettings();
      toast.success('Configurações padrão carregadas.');
    } catch (error) {
      console.error('Erro ao criar configurações padrão:', error);
      toast.error('Não foi possível criar as configurações padrão.');
    }
  };

  // Atualizar configurações
  const updateSettings = async (updates: OrganizationSettingsUpdate) => {
    if (!settings?.id || !organization?.id) {
      toast.error('Configurações não encontradas.');
      return false;
    }

    try {
      setUpdating(true);
      
      // Mapear updates para campos da tabela organizations
      const organizationUpdates: any = {};
      
      if (updates.nome_empresa) organizationUpdates.name = updates.nome_empresa;
      if (updates.cor_primaria) organizationUpdates.cor_primaria = updates.cor_primaria;
      if (updates.cor_secundaria) organizationUpdates.cor_secundaria = updates.cor_secundaria;
      if (updates.logo_empresa_url) organizationUpdates.logo_url = updates.logo_empresa_url;
      if (updates.endereco_completo) organizationUpdates.endereco = updates.endereco_completo;
      if (updates.telefone) organizationUpdates.telefone = updates.telefone;
      if (updates.site_url) organizationUpdates.website = updates.site_url;
      if (updates.whatsapp_numero) organizationUpdates.whatsapp = updates.whatsapp_numero;
      
      const { data, error } = await supabase
        .from('organizations')
        .update(organizationUpdates)
        .eq('id', organization.id)
        .select()
        .single();

      if (error) throw error;
      
      // Recarregar configurações após atualização
      await loadSettings();
      
      toast.success('Configurações atualizadas com sucesso.');
      
      return true;
    } catch (error) {
      console.error('Erro ao atualizar configurações:', error);
      toast.error('Não foi possível atualizar as configurações.');
      return false;
    } finally {
      setUpdating(false);
    }
  };

  // Upload de arquivo (logo, favicon, etc.)
  const uploadFile = async (file: File, bucket: string = 'organization-assets', folder: string = 'logos') => {
    try {
      const fileExt = file.name.split('.').pop();
      const fileName = `${organization?.id}/${folder}/${Date.now()}.${fileExt}`;
      
      const { data, error } = await supabase.storage
        .from(bucket)
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false
        });

      if (error) throw error;
      
      // Obter URL pública
      const { data: { publicUrl } } = supabase.storage
        .from(bucket)
        .getPublicUrl(fileName);
      
      return publicUrl;
    } catch (error) {
      console.error('Erro ao fazer upload:', error);
      toast.error('Não foi possível fazer upload do arquivo.');
      return null;
    }
  };

  // Remover arquivo
  const removeFile = async (url: string, bucket: string = 'organization-assets') => {
    try {
      // Extrair o caminho do arquivo da URL
      const urlParts = url.split('/');
      const bucketIndex = urlParts.findIndex(part => part === bucket);
      if (bucketIndex === -1) return false;
      
      const filePath = urlParts.slice(bucketIndex + 1).join('/');
      
      const { error } = await supabase.storage
        .from(bucket)
        .remove([filePath]);

      if (error) throw error;
      
      return true;
    } catch (error) {
      console.error('Erro ao remover arquivo:', error);
      return false;
    }
  };

  // Validar configurações
  const validateSettings = (updates: OrganizationSettingsUpdate): string[] => {
    const errors: string[] = [];
    
    // Validar cores
    if (updates.cor_primaria && !/^#[0-9A-Fa-f]{6}$/.test(updates.cor_primaria)) {
      errors.push('Cor primária deve estar no formato hexadecimal (#000000)');
    }
    
    if (updates.cor_secundaria && !/^#[0-9A-Fa-f]{6}$/.test(updates.cor_secundaria)) {
      errors.push('Cor secundária deve estar no formato hexadecimal (#000000)');
    }
    
    // Validar email
    if (updates.email_contato && !/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(updates.email_contato)) {
      errors.push('Email de contato inválido');
    }
    
    // Validar CNPJ
    if (updates.cnpj && !/^[0-9]{2}\.[0-9]{3}\.[0-9]{3}\/[0-9]{4}-[0-9]{2}$/.test(updates.cnpj)) {
      errors.push('CNPJ deve estar no formato 00.000.000/0000-00');
    }
    
    // Validar taxa de cartão
    if (updates.taxa_cartao !== undefined && (updates.taxa_cartao < 0 || updates.taxa_cartao > 100)) {
      errors.push('Taxa de cartão deve estar entre 0% e 100%');
    }
    
    return errors;
  };

  // Carregar configurações quando a organização mudar
  useEffect(() => {
    loadSettings();
  }, [organization?.id]);

  return {
    settings,
    loading,
    updating,
    loadSettings,
    updateSettings,
    uploadFile,
    removeFile,
    validateSettings,
    createDefaultSettings
  };
};