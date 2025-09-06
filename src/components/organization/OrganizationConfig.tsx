import React, { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Building2, Save, Upload, Palette } from 'lucide-react';
import { toast } from 'sonner';

import { Button } from '@/components/ui/button';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { useAuth } from '@/contexts/AuthContext';
import { useOrganization } from '@/hooks/useOrganization';
import { supabase } from '@/integrations/supabase/client';

const organizationConfigSchema = z.object({
  name: z.string().min(3, 'O nome deve ter pelo menos 3 caracteres'),
  descricao: z.string().optional(),
  telefone: z.string().optional(),
  whatsapp: z.string().optional(),
  endereco: z.string().optional(),
  cidade: z.string().optional(),
  estado: z.string().optional(),
  cep: z.string().optional(),
  website: z.string().optional(),
  time_casa_padrao: z.string().optional(),
  cor_primaria: z.string().optional(),
  cor_secundaria: z.string().optional(),
  logo_url: z.string().optional(),
});

type OrganizationConfigFormValues = z.infer<typeof organizationConfigSchema>;

interface OrganizationConfigProps {
  className?: string;
}

export const OrganizationConfig: React.FC<OrganizationConfigProps> = ({ className }) => {
  const { profile } = useAuth();
  const { organization, hasOrganization } = useOrganization();
  const [isLoading, setIsLoading] = useState(false);
  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [logoPreview, setLogoPreview] = useState<string | null>(null);

  const form = useForm<OrganizationConfigFormValues>({
    resolver: zodResolver(organizationConfigSchema),
    defaultValues: {
      name: '',
      descricao: '',
      telefone: '',
      whatsapp: '',
      endereco: '',
      cidade: '',
      estado: '',
      cep: '',
      website: '',
      time_casa_padrao: '',
      cor_primaria: '',
      cor_secundaria: '',
      logo_url: '',
    },
  });

  // Carregar dados da organização quando disponível
  useEffect(() => {
    if (organization) {
      form.reset({
        name: organization.name || '',
        descricao: '', // Não está no tipo atual, mas pode ser adicionado
        telefone: '', // Não está no tipo atual, mas pode ser adicionado
        whatsapp: '', // Não está no tipo atual, mas pode ser adicionado
        endereco: '', // Não está no tipo atual, mas pode ser adicionado
        cidade: '', // Não está no tipo atual, mas pode ser adicionado
        estado: '', // Não está no tipo atual, mas pode ser adicionado
        cep: '', // Não está no tipo atual, mas pode ser adicionado
        website: '', // Não está no tipo atual, mas pode ser adicionado
        time_casa_padrao: organization.time_casa_padrao || '',
        cor_primaria: organization.cor_primaria || '',
        cor_secundaria: organization.cor_secundaria || '',
        logo_url: organization.logo_url || '',
      });
      setLogoPreview(organization.logo_url || null);
    }
  }, [organization, form]);

  const handleLogoChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      setLogoFile(file);
      const reader = new FileReader();
      reader.onload = (e) => {
        setLogoPreview(e.target?.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const uploadLogo = async (): Promise<string | null> => {
    if (!logoFile || !organization) return null;

    try {
      const fileExt = logoFile.name.split('.').pop();
      const fileName = `${organization.id}/logo.${fileExt}`;
      const filePath = `organization-logos/${fileName}`;

      const { error: uploadError } = await supabase.storage
        .from('organization-assets')
        .upload(filePath, logoFile, {
          cacheControl: '3600',
          upsert: true,
        });

      if (uploadError) {
        console.error('Erro no upload:', uploadError);
        throw uploadError;
      }

      const { data: { publicUrl } } = supabase.storage
        .from('organization-assets')
        .getPublicUrl(filePath);

      return publicUrl;
    } catch (error) {
      console.error('Erro ao fazer upload do logo:', error);
      toast.error('Erro ao fazer upload do logo');
      return null;
    }
  };

  const onSubmit = async (data: OrganizationConfigFormValues) => {
    if (!organization) {
      toast.error('Organização não encontrada');
      return;
    }

    setIsLoading(true);
    try {
      let logoUrl = data.logo_url;

      // Upload do logo se houver um novo arquivo
      if (logoFile) {
        const uploadedUrl = await uploadLogo();
        if (uploadedUrl) {
          logoUrl = uploadedUrl;
        }
      }

      const updateData = {
        ...data,
        logo_url: logoUrl,
      };

      const { error } = await supabase
        .from('organizations')
        .update(updateData)
        .eq('id', organization.id);

      if (error) throw error;

      toast.success('Configurações da organização atualizadas com sucesso!');
      
      // Recarregar o perfil para atualizar as informações da organização
      window.location.reload();
    } catch (error) {
      console.error('Erro ao atualizar configurações:', error);
      toast.error('Erro ao atualizar configurações da organização');
    } finally {
      setIsLoading(false);
    }
  };

  if (!hasOrganization) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle className="text-center text-red-600">Organização não encontrada</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-center text-gray-600">
            Não foi possível carregar as informações da organização.
          </p>
        </CardContent>
      </Card>
    );
  }

  // Verificar se o usuário tem permissão para editar (admin ou super_admin)
  const canEdit = profile?.role === 'admin' || profile?.role === 'super_admin';

  if (!canEdit) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle className="text-center text-red-600">Acesso Negado</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-center text-gray-600">
            Apenas administradores podem editar as configurações da organização.
          </p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Building2 className="h-6 w-6" />
          Configurações da Organização
        </CardTitle>
        <CardDescription>
          Personalize as configurações da sua organização
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            {/* Logo */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium flex items-center gap-2">
                <Upload className="h-5 w-5" />
                Logo da Organização
              </h3>
              <div className="flex items-center gap-4">
                {logoPreview && (
                  <img
                    src={logoPreview}
                    alt="Logo preview"
                    className="h-16 w-16 rounded-lg object-cover border"
                  />
                )}
                <div className="flex-1">
                  <Input
                    type="file"
                    accept="image/*"
                    onChange={handleLogoChange}
                    className="mb-2"
                  />
                  <FormField
                    control={form.control}
                    name="logo_url"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>URL do Logo (alternativo)</FormLabel>
                        <FormControl>
                          <Input placeholder="https://exemplo.com/logo.png" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>
              </div>
            </div>

            {/* Informações Básicas */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium">Informações Básicas</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <FormField
                  control={form.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Nome da Organização *</FormLabel>
                      <FormControl>
                        <Input placeholder="Nome da empresa" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="time_casa_padrao"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Time da Casa Padrão</FormLabel>
                      <FormControl>
                        <Input placeholder="Ex: Flamengo" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <FormField
                control={form.control}
                name="descricao"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Descrição</FormLabel>
                    <FormControl>
                      <Textarea
                        placeholder="Descrição da organização"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            {/* Personalização Visual */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium flex items-center gap-2">
                <Palette className="h-5 w-5" />
                Personalização Visual
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <FormField
                  control={form.control}
                  name="cor_primaria"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Cor Primária</FormLabel>
                      <FormControl>
                        <div className="flex gap-2">
                          <Input
                            type="color"
                            className="w-16 h-10 p-1 border rounded"
                            {...field}
                          />
                          <Input placeholder="#000000" {...field} />
                        </div>
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="cor_secundaria"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Cor Secundária</FormLabel>
                      <FormControl>
                        <div className="flex gap-2">
                          <Input
                            type="color"
                            className="w-16 h-10 p-1 border rounded"
                            {...field}
                          />
                          <Input placeholder="#000000" {...field} />
                        </div>
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
            </div>

            {/* Contato */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium">Informações de Contato</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <FormField
                  control={form.control}
                  name="telefone"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Telefone</FormLabel>
                      <FormControl>
                        <Input placeholder="(11) 99999-9999" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="whatsapp"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>WhatsApp</FormLabel>
                      <FormControl>
                        <Input placeholder="(11) 99999-9999" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="website"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Website</FormLabel>
                      <FormControl>
                        <Input placeholder="https://www.exemplo.com" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
            </div>

            {/* Endereço */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium">Endereço</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <FormField
                  control={form.control}
                  name="endereco"
                  render={({ field }) => (
                    <FormItem className="md:col-span-2">
                      <FormLabel>Endereço</FormLabel>
                      <FormControl>
                        <Input placeholder="Rua, número" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="cidade"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Cidade</FormLabel>
                      <FormControl>
                        <Input placeholder="São Paulo" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="estado"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Estado</FormLabel>
                      <FormControl>
                        <Input placeholder="SP" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="cep"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>CEP</FormLabel>
                      <FormControl>
                        <Input placeholder="00000-000" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
            </div>

            <div className="flex justify-end">
              <Button type="submit" disabled={isLoading} className="flex items-center gap-2">
                <Save className="h-4 w-4" />
                {isLoading ? 'Salvando...' : 'Salvar Configurações'}
              </Button>
            </div>
          </form>
        </Form>
      </CardContent>
    </Card>
  );
};

export default OrganizationConfig;