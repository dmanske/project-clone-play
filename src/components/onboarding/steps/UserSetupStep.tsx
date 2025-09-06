import React, { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent } from '@/components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { User, Shield, Mail, Phone } from 'lucide-react';
import { toast } from 'sonner';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';

const userSchema = z.object({
  full_name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  email: z.string().email('Email inválido'),
  phone: z.string().optional(),
  role: z.enum(['owner', 'admin'], {
    required_error: 'Selecione um papel',
  }),
});

type UserFormData = z.infer<typeof userSchema>;

interface UserSetupStepProps {
  onComplete: (data: any) => void;
  data?: any;
  allData?: any;
}

export const UserSetupStep: React.FC<UserSetupStepProps> = ({ onComplete, data, allData }) => {
  const [isLoading, setIsLoading] = useState(false);
  const { user, profile, refreshProfile } = useAuth();

  const form = useForm<UserFormData>({
    resolver: zodResolver(userSchema),
    defaultValues: {
      full_name: profile?.full_name || '',
      email: profile?.email || user?.email || '',
      phone: '',
      role: 'owner',
    },
  });

  useEffect(() => {
    if (data) {
      Object.keys(data).forEach(key => {
        if (key in form.getValues()) {
          form.setValue(key as keyof UserFormData, data[key]);
        }
      });
    }
  }, [data, form]);

  const onSubmit = async (formData: UserFormData) => {
    if (!user?.id || !profile?.organization_id) {
      toast.error('Usuário ou organização não encontrados');
      return;
    }

    setIsLoading(true);
    try {
      // Atualizar perfil do usuário
      const { error: profileError } = await supabase
        .from('profiles')
        .update({
          full_name: formData.full_name,
          role: formData.role,
        })
        .eq('id', user.id);

      if (profileError) throw profileError;

      // Atualizar o perfil do usuário
      await refreshProfile();

      onComplete({
        ...formData,
        userId: user.id,
        organizationId: profile.organization_id,
      });
      
      toast.success('Perfil configurado com sucesso!');
    } catch (error) {
      console.error('Erro ao configurar perfil:', error);
      toast.error('Erro ao configurar perfil');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Informações Pessoais */}
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center space-x-2 mb-4">
              <User className="w-5 h-5 text-blue-600" />
              <h3 className="text-lg font-semibold">Informações Pessoais</h3>
            </div>
            
            <div className="space-y-4">
              <div>
                <Label htmlFor="full_name">Nome Completo *</Label>
                <Input
                  id="full_name"
                  {...form.register('full_name')}
                  placeholder="Seu nome completo"
                />
                {form.formState.errors.full_name && (
                  <p className="text-sm text-red-600 mt-1">
                    {form.formState.errors.full_name.message}
                  </p>
                )}
              </div>

              <div>
                <Label htmlFor="email">Email *</Label>
                <Input
                  id="email"
                  type="email"
                  {...form.register('email')}
                  disabled
                  className="bg-gray-50"
                />
                <p className="text-xs text-gray-500 mt-1">
                  Email não pode ser alterado
                </p>
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
            </div>
          </CardContent>
        </Card>

        {/* Permissões e Papel */}
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center space-x-2 mb-4">
              <Shield className="w-5 h-5 text-blue-600" />
              <h3 className="text-lg font-semibold">Papel na Organização</h3>
            </div>
            
            <div className="space-y-4">
              <div>
                <Label htmlFor="role">Papel *</Label>
                <Select
                  value={form.watch('role')}
                  onValueChange={(value) => form.setValue('role', value as 'owner' | 'admin')}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione seu papel" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="owner">
                      <div className="flex flex-col">
                        <span className="font-medium">Proprietário</span>
                        <span className="text-xs text-gray-500">
                          Acesso total ao sistema e configurações
                        </span>
                      </div>
                    </SelectItem>
                    <SelectItem value="admin">
                      <div className="flex flex-col">
                        <span className="font-medium">Administrador</span>
                        <span className="text-xs text-gray-500">
                          Gerenciar usuários e configurações básicas
                        </span>
                      </div>
                    </SelectItem>
                  </SelectContent>
                </Select>
                {form.formState.errors.role && (
                  <p className="text-sm text-red-600 mt-1">
                    {form.formState.errors.role.message}
                  </p>
                )}
              </div>

              {/* Informações sobre permissões */}
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <h4 className="font-medium text-blue-900 mb-2">Permissões Incluídas:</h4>
                <ul className="text-sm text-blue-700 space-y-1">
                  <li>• Gerenciar passageiros e viagens</li>
                  <li>• Visualizar relatórios e estatísticas</li>
                  <li>• Configurar organização</li>
                  {form.watch('role') === 'owner' && (
                    <>
                      <li>• Gerenciar usuários e permissões</li>
                      <li>• Configurações avançadas</li>
                      <li>• Gerenciar assinatura e pagamentos</li>
                    </>
                  )}
                </ul>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Resumo da Organização */}
      {allData?.organization && (
        <Card className="bg-gray-50">
          <CardContent className="p-6">
            <h3 className="text-lg font-semibold mb-4">Resumo da Configuração</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              <div>
                <span className="font-medium text-gray-700">Organização:</span>
                <span className="ml-2">{allData.organization.name}</span>
              </div>
              <div>
                <span className="font-medium text-gray-700">Identificador:</span>
                <span className="ml-2">{allData.organization.slug}</span>
              </div>
              <div>
                <span className="font-medium text-gray-700">Seu papel:</span>
                <span className="ml-2">
                  {form.watch('role') === 'owner' ? 'Proprietário' : 'Administrador'}
                </span>
              </div>
              <div>
                <span className="font-medium text-gray-700">Email:</span>
                <span className="ml-2">{form.watch('email')}</span>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      <div className="flex justify-end">
        <Button type="submit" disabled={isLoading} className="px-8">
          {isLoading ? 'Salvando...' : 'Salvar e Continuar'}
        </Button>
      </div>
    </form>
  );
};