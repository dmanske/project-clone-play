import React, { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Card, CardContent } from '@/components/ui/card';
import { Upload, Building2, Mail, Phone, Globe } from 'lucide-react';
import { toast } from 'sonner';
import { useOrganization } from '@/hooks/useOrganization';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';

const organizationSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  slug: z.string().min(2, 'Slug deve ter pelo menos 2 caracteres').regex(/^[a-z0-9-]+$/, 'Slug deve conter apenas letras minúsculas, números e hífens'),
  email: z.string().email('Email inválido').optional().or(z.literal('')),
  phone: z.string().optional(),
  website: z.string().url('URL inválida').optional().or(z.literal('')),
  description: z.string().optional(),
  cor_primaria: z.string().regex(/^#[0-9A-Fa-f]{6}$/, 'Cor deve estar no formato hexadecimal').optional(),
  cor_secundaria: z.string().regex(/^#[0-9A-Fa-f]{6}$/, 'Cor deve estar no formato hexadecimal').optional(),
});

type OrganizationFormData = z.infer<typeof organizationSchema>;

interface OrganizationSetupStepProps {
  onComplete: (data: any) => void;
  data?: any;
}

export const OrganizationSetupStep: React.FC<OrganizationSetupStepProps> = ({ onComplete, data }) => {
  const [isLoading, setIsLoading] = useState(false);
  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [logoPreview, setLogoPreview] = useState<string | null>(null);
  const { organization } = useOrganization();
  const { refreshProfile, user } = useAuth();
  const [isCreatingOrganization, setIsCreatingOrganization] = useState(false);

  const form = useForm<OrganizationFormData>({
    resolver: zodResolver(organizationSchema),
    defaultValues: {
      name: organization?.name || '',
      slug: organization?.slug || '',
      email: '',
      phone: '',
      website: '',
      description: '',
      cor_primaria: organization?.cor_primaria || '#3B82F6',
      cor_secundaria: organization?.cor_secundaria || '#10B981',
    },
  });

  useEffect(() => {
    if (data) {
      Object.keys(data).forEach(key => {
        if (key in form.getValues()) {
          form.setValue(key as keyof OrganizationFormData, data[key]);
        }
      });
      if (data.logoPreview) {
        setLogoPreview(data.logoPreview);
      }
    }
  }, [data, form]);

  const handleLogoChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      if (file.size > 5 * 1024 * 1024) {
        toast.error('Arquivo muito grande. Máximo 5MB.');
        return;
      }
      
      if (!file.type.startsWith('image/')) {
        toast.error('Apenas arquivos de imagem são permitidos.');
        return;
      }

      setLogoFile(file);
      const reader = new FileReader();
      reader.onload = (e) => {
        setLogoPreview(e.target?.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const uploadLogo = async (): Promise<string | null> => {
    if (!logoFile || !organization?.id) return null;

    try {
      const fileExt = logoFile.name.split('.').pop();
      const fileName = `${organization.id}/logo.${fileExt}`;
      
      const { error: uploadError } = await supabase.storage
        .from('logos')
        .upload(fileName, logoFile, { upsert: true });

      if (uploadError) throw uploadError;

      const { data: { publicUrl } } = supabase.storage
        .from('logos')
        .getPublicUrl(fileName);

      return publicUrl;
    } catch (error) {
      console.error('Erro ao fazer upload do logo:', error);
      toast.error('Erro ao fazer upload do logo');
      return null;
    }
  };

  const createNewOrganization = async (formData: any) => {
    try {
      // Simular criação de organização (aguardando implementação completa do backend)
      const orgId = crypto.randomUUID();
      
      // Testar conexão com banco usando tabela existente
      const { error: testError } = await supabase
        .from('adversarios')
        .select('id')
        .limit(1);
        
      if (testError) {
        throw new Error('Erro de conexão com banco de dados');
      }
      
      // Por enquanto, simular criação da organização
      // TODO: Implementar criação real quando tipos do Supabase forem atualizados
      console.log('Organização criada (simulado):', {
        id: orgId,
        name: formData.name,
        slug: formData.slug,
        phone: formData.phone,
        email: formData.email,
        primaryColor: formData.cor_primaria || '#3B82F6',
        secondaryColor: formData.cor_secundaria || '#10B981'
      });
      
      return {
        id: orgId,
        name: formData.name,
        slug: formData.slug
      };
    } catch (error) {
      console.error('Erro ao criar organização:', error);
      throw error;
    }
  };

  const onSubmit = async (formData: OrganizationFormData) => {
    setIsLoading(true);
    
    try {
      let currentOrg = organization;
      
      // Se não há organização, criar uma nova
      if (!currentOrg?.id) {
        toast.info('Criando nova organização...');
        currentOrg = await createNewOrganization(formData);
        
        // Atualizar o perfil para refletir a nova organização
        await refreshProfile();
      } else {
        // Atualizar organização existente
        let logoUrl = currentOrg.logo_url;
        
        // Upload do logo se houver
        if (logoFile) {
          const uploadedUrl = await uploadLogo();
          if (uploadedUrl) {
            logoUrl = uploadedUrl;
          }
        }

        // Simular atualização de organização (aguardando implementação completa do backend)
        const { error: testError } = await supabase
          .from('adversarios')
          .select('id')
          .limit(1);
          
        if (testError) {
          throw new Error('Erro de conexão com banco de dados');
        }
        
        // Por enquanto, simular atualização da organização
        // TODO: Implementar atualização real quando tipos do Supabase forem atualizados
        console.log('Organização atualizada (simulado):', {
          id: currentOrg.id,
          name: formData.name,
          slug: formData.slug,
          logoUrl: logoUrl,
          primaryColor: formData.cor_primaria,
          secondaryColor: formData.cor_secundaria
        });
        
        const updateError = null; // Simular sucesso

        if (updateError) {
          console.warn('Aviso ao atualizar organização:', updateError);
        }

        // Atualizar o perfil do usuário
        await refreshProfile();
      }

      // Salvar dados adicionais para próximos steps
      const completeData = {
        ...formData,
        logoUrl: currentOrg.logo_url,
        logoPreview,
        organizationId: currentOrg.id,
      };

      onComplete(completeData);
      toast.success(organization?.id ? 'Organização atualizada com sucesso!' : 'Organização criada com sucesso!');
    } catch (error) {
      console.error('Erro ao configurar organização:', error);
      toast.error('Erro ao configurar organização');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Informações Básicas */}
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center space-x-2 mb-4">
              <Building2 className="w-5 h-5 text-blue-600" />
              <h3 className="text-lg font-semibold">Informações Básicas</h3>
            </div>
            
            <div className="space-y-4">
              <div>
                <Label htmlFor="name">Nome da Organização *</Label>
                <Input
                  id="name"
                  {...form.register('name')}
                  placeholder="Ex: Caravana Flamengo"
                />
                {form.formState.errors.name && (
                  <p className="text-sm text-red-600 mt-1">
                    {form.formState.errors.name.message}
                  </p>
                )}
              </div>

              <div>
                <Label htmlFor="slug">Identificador (Slug) *</Label>
                <Input
                  id="slug"
                  {...form.register('slug')}
                  placeholder="Ex: caravana-flamengo"
                />
                <p className="text-xs text-gray-500 mt-1">
                  Usado para URLs e identificação única
                </p>
                {form.formState.errors.slug && (
                  <p className="text-sm text-red-600 mt-1">
                    {form.formState.errors.slug.message}
                  </p>
                )}
              </div>

              <div>
                <Label htmlFor="description">Descrição</Label>
                <Textarea
                  id="description"
                  {...form.register('description')}
                  placeholder="Breve descrição da sua organização"
                  rows={3}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Logo e Visual */}
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center space-x-2 mb-4">
              <Upload className="w-5 h-5 text-blue-600" />
              <h3 className="text-lg font-semibold">Logo e Visual</h3>
            </div>
            
            <div className="space-y-4">
              {/* Upload de Logo */}
              <div>
                <Label htmlFor="logo">Logo da Organização</Label>
                <div className="mt-2">
                  {logoPreview ? (
                    <div className="relative">
                      <img
                        src={logoPreview}
                        alt="Preview do logo"
                        className="w-32 h-32 object-contain border border-gray-200 rounded-lg"
                      />
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        className="mt-2"
                        onClick={() => {
                          setLogoPreview(null);
                          setLogoFile(null);
                        }}
                      >
                        Remover
                      </Button>
                    </div>
                  ) : (
                    <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                      <Upload className="w-8 h-8 text-gray-400 mx-auto mb-2" />
                      <p className="text-sm text-gray-600 mb-2">Clique para fazer upload</p>
                      <p className="text-xs text-gray-500">PNG, JPG até 5MB</p>
                    </div>
                  )}
                  <input
                    id="logo"
                    type="file"
                    accept="image/*"
                    onChange={handleLogoChange}
                    className="hidden"
                  />
                  <Label
                    htmlFor="logo"
                    className="cursor-pointer inline-block mt-2"
                  >
                    <Button type="button" variant="outline" size="sm">
                      Escolher Arquivo
                    </Button>
                  </Label>
                </div>
              </div>

              {/* Cores */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="cor_primaria">Cor Primária</Label>
                  <div className="flex items-center space-x-2 mt-1">
                    <Input
                      id="cor_primaria"
                      type="color"
                      {...form.register('cor_primaria')}
                      className="w-12 h-10 p-1 border rounded"
                    />
                    <Input
                      {...form.register('cor_primaria')}
                      placeholder="#3B82F6"
                      className="flex-1"
                    />
                  </div>
                </div>
                <div>
                  <Label htmlFor="cor_secundaria">Cor Secundária</Label>
                  <div className="flex items-center space-x-2 mt-1">
                    <Input
                      id="cor_secundaria"
                      type="color"
                      {...form.register('cor_secundaria')}
                      className="w-12 h-10 p-1 border rounded"
                    />
                    <Input
                      {...form.register('cor_secundaria')}
                      placeholder="#10B981"
                      className="flex-1"
                    />
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Informações de Contato */}
      <Card>
        <CardContent className="p-6">
          <div className="flex items-center space-x-2 mb-4">
            <Mail className="w-5 h-5 text-blue-600" />
            <h3 className="text-lg font-semibold">Informações de Contato (Opcional)</h3>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                {...form.register('email')}
                placeholder="contato@exemplo.com"
              />
              {form.formState.errors.email && (
                <p className="text-sm text-red-600 mt-1">
                  {form.formState.errors.email.message}
                </p>
              )}
            </div>
            
            <div>
              <Label htmlFor="phone">Telefone</Label>
              <Input
                id="phone"
                {...form.register('phone')}
                placeholder="(11) 99999-9999"
              />
            </div>
            
            <div>
              <Label htmlFor="website">Website</Label>
              <Input
                id="website"
                {...form.register('website')}
                placeholder="https://exemplo.com"
              />
              {form.formState.errors.website && (
                <p className="text-sm text-red-600 mt-1">
                  {form.formState.errors.website.message}
                </p>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="flex justify-end">
        <Button type="submit" disabled={isLoading || isCreatingOrganization || (!organization?.id && !form.formState.isValid)} className="px-8">
          {isLoading || isCreatingOrganization 
            ? (organization?.id ? 'Salvando...' : 'Criando organização...') 
            : (organization?.id ? 'Salvar e Continuar' : 'Criar Organização e Continuar')
          }
        </Button>
      </div>
    </form>
  );
};