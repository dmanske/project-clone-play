import React, { useState, useRef } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  Settings,
  Save,
  Upload,
  Palette,
  Building2,
  Globe,
  Phone,
  Mail,
  CreditCard,
  Bell,
  FileText,
  Trash2,
  Eye
} from 'lucide-react';
import { toast } from 'sonner';

import { Button } from '@/components/ui/button';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
  FormDescription,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '@/components/ui/tabs';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { useOrganizationSettings, OrganizationSettingsUpdate } from '@/hooks/useOrganizationSettings';

const organizationSettingsSchema = z.object({
  // Branding
  nome_empresa: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres').optional(),
  cor_primaria: z.string().regex(/^#[0-9A-Fa-f]{6}$/, 'Cor deve estar no formato #000000').optional(),
  cor_secundaria: z.string().regex(/^#[0-9A-Fa-f]{6}$/, 'Cor deve estar no formato #000000').optional(),
  
  // Informações da Empresa
  endereco_completo: z.string().optional(),
  telefone: z.string().optional(),
  email_contato: z.string().email('Email inválido').optional().or(z.literal('')),
  site_url: z.string().url('URL inválida').optional().or(z.literal('')),
  cnpj: z.string().regex(/^[0-9]{2}\.[0-9]{3}\.[0-9]{3}\/[0-9]{4}-[0-9]{2}$/, 'CNPJ deve estar no formato 00.000.000/0000-00').optional().or(z.literal('')),
  
  // Configurações Regionais
  timezone: z.string().optional(),
  moeda: z.string().optional(),
  idioma: z.string().optional(),
  formato_data: z.string().optional(),
  
  // Configurações de Notificações
  email_notificacoes: z.boolean().optional(),
  whatsapp_notificacoes: z.boolean().optional(),
  whatsapp_numero: z.string().optional(),
  
  // Configurações de Pagamento
  aceita_pix: z.boolean().optional(),
  aceita_cartao: z.boolean().optional(),
  aceita_dinheiro: z.boolean().optional(),
  taxa_cartao: z.number().min(0).max(100).optional(),
  
  // Configurações de Relatórios
  incluir_logo_relatorios: z.boolean().optional(),
  rodape_personalizado: z.string().optional(),
});

type OrganizationSettingsFormValues = z.infer<typeof organizationSettingsSchema>;

interface OrganizationSettingsFormProps {
  className?: string;
}

export const OrganizationSettingsForm: React.FC<OrganizationSettingsFormProps> = ({ className }) => {
  const {
    settings,
    loading,
    updating,
    updateSettings,
    uploadFile,
    removeFile,
    validateSettings
  } = useOrganizationSettings();
  
  const [logoPreview, setLogoPreview] = useState<string | null>(null);
  const [faviconPreview, setFaviconPreview] = useState<string | null>(null);
  const logoInputRef = useRef<HTMLInputElement>(null);
  const faviconInputRef = useRef<HTMLInputElement>(null);

  const form = useForm<OrganizationSettingsFormValues>({
    resolver: zodResolver(organizationSettingsSchema),
    defaultValues: {
      nome_empresa: '',
      cor_primaria: '#000000',
      cor_secundaria: '#ffffff',
      endereco_completo: '',
      telefone: '',
      email_contato: '',
      site_url: '',
      cnpj: '',
      timezone: 'America/Sao_Paulo',
      moeda: 'BRL',
      idioma: 'pt-BR',
      formato_data: 'DD/MM/YYYY',
      email_notificacoes: true,
      whatsapp_notificacoes: false,
      whatsapp_numero: '',
      aceita_pix: true,
      aceita_cartao: true,
      aceita_dinheiro: true,
      taxa_cartao: 0,
      incluir_logo_relatorios: true,
      rodape_personalizado: '',
    },
  });

  // Carregar dados quando as configurações estiverem disponíveis
  React.useEffect(() => {
    if (settings) {
      form.reset({
        nome_empresa: settings.nome_empresa || '',
        cor_primaria: settings.cor_primaria || '#000000',
        cor_secundaria: settings.cor_secundaria || '#ffffff',
        endereco_completo: settings.endereco_completo || '',
        telefone: settings.telefone || '',
        email_contato: settings.email_contato || '',
        site_url: settings.site_url || '',
        cnpj: settings.cnpj || '',
        timezone: settings.timezone || 'America/Sao_Paulo',
        moeda: settings.moeda || 'BRL',
        idioma: settings.idioma || 'pt-BR',
        formato_data: settings.formato_data || 'DD/MM/YYYY',
        email_notificacoes: settings.email_notificacoes ?? true,
        whatsapp_notificacoes: settings.whatsapp_notificacoes ?? false,
        whatsapp_numero: settings.whatsapp_numero || '',
        aceita_pix: settings.aceita_pix ?? true,
        aceita_cartao: settings.aceita_cartao ?? true,
        aceita_dinheiro: settings.aceita_dinheiro ?? true,
        taxa_cartao: settings.taxa_cartao || 0,
        incluir_logo_relatorios: settings.incluir_logo_relatorios ?? true,
        rodape_personalizado: settings.rodape_personalizado || '',
      });
      
      setLogoPreview(settings.logo_empresa_url || null);
      setFaviconPreview(settings.favicon_url || null);
    }
  }, [settings, form]);

  const onSubmit = async (values: OrganizationSettingsFormValues) => {
    // Validar configurações
    const errors = validateSettings(values);
    if (errors.length > 0) {
      errors.forEach(error => toast.error(error));
      return;
    }

    const success = await updateSettings(values);
    if (success) {
      toast.success('Configurações salvas com sucesso!');
    }
  };

  const handleLogoUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    // Validar tipo de arquivo
    if (!file.type.startsWith('image/')) {
      toast.error('Por favor, selecione um arquivo de imagem.');
      return;
    }

    // Validar tamanho (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      toast.error('A imagem deve ter no máximo 5MB.');
      return;
    }

    try {
      const url = await uploadFile(file, 'organization-assets', 'logos');
      if (url) {
        setLogoPreview(url);
        await updateSettings({ logo_empresa_url: url });
        toast.success('Logo atualizado com sucesso!');
      }
    } catch (error) {
      console.error('Erro ao fazer upload do logo:', error);
      toast.error('Erro ao fazer upload do logo.');
    }
  };

  const handleFaviconUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    // Validar tipo de arquivo
    if (!file.type.startsWith('image/')) {
      toast.error('Por favor, selecione um arquivo de imagem.');
      return;
    }

    // Validar tamanho (max 1MB para favicon)
    if (file.size > 1024 * 1024) {
      toast.error('O favicon deve ter no máximo 1MB.');
      return;
    }

    try {
      const url = await uploadFile(file, 'organization-assets', 'favicons');
      if (url) {
        setFaviconPreview(url);
        await updateSettings({ favicon_url: url });
        toast.success('Favicon atualizado com sucesso!');
      }
    } catch (error) {
      console.error('Erro ao fazer upload do favicon:', error);
      toast.error('Erro ao fazer upload do favicon.');
    }
  };

  const handleRemoveLogo = async () => {
    if (settings?.logo_empresa_url) {
      const removed = await removeFile(settings.logo_empresa_url);
      if (removed) {
        setLogoPreview(null);
        await updateSettings({ logo_empresa_url: undefined });
        toast.success('Logo removido com sucesso!');
      }
    }
  };

  const handleRemoveFavicon = async () => {
    if (settings?.favicon_url) {
      const removed = await removeFile(settings.favicon_url);
      if (removed) {
        setFaviconPreview(null);
        await updateSettings({ favicon_url: undefined });
        toast.success('Favicon removido com sucesso!');
      }
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-lg">Carregando configurações...</div>
      </div>
    );
  }

  return (
    <div className={className}>
      <div className="flex items-center gap-2 mb-6">
        <Settings className="h-6 w-6" />
        <h1 className="text-2xl font-bold">Configurações da Organização</h1>
      </div>

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          <Tabs defaultValue="branding" className="w-full">
            <TabsList className="grid w-full grid-cols-5">
              <TabsTrigger value="branding">Branding</TabsTrigger>
              <TabsTrigger value="empresa">Empresa</TabsTrigger>
              <TabsTrigger value="regional">Regional</TabsTrigger>
              <TabsTrigger value="pagamento">Pagamento</TabsTrigger>
              <TabsTrigger value="relatorios">Relatórios</TabsTrigger>
            </TabsList>

            {/* Tab Branding */}
            <TabsContent value="branding">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Palette className="h-5 w-5" />
                    Identidade Visual
                  </CardTitle>
                  <CardDescription>
                    Configure a aparência e identidade visual da sua organização
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  {/* Logo da Empresa */}
                  <div className="space-y-2">
                    <label className="text-sm font-medium">Logo da Empresa</label>
                    <div className="flex items-center gap-4">
                      {logoPreview && (
                        <div className="relative">
                          <img
                            src={logoPreview}
                            alt="Logo preview"
                            className="w-20 h-20 object-contain border rounded-lg"
                          />
                          <Button
                            type="button"
                            variant="destructive"
                            size="sm"
                            className="absolute -top-2 -right-2 h-6 w-6 rounded-full p-0"
                            onClick={handleRemoveLogo}
                          >
                            <Trash2 className="h-3 w-3" />
                          </Button>
                        </div>
                      )}
                      <div className="space-y-2">
                        <Button
                          type="button"
                          variant="outline"
                          onClick={() => logoInputRef.current?.click()}
                          className="flex items-center gap-2"
                        >
                          <Upload className="h-4 w-4" />
                          {logoPreview ? 'Alterar Logo' : 'Upload Logo'}
                        </Button>
                        <p className="text-xs text-muted-foreground">
                          PNG, JPG ou SVG. Máximo 5MB.
                        </p>
                      </div>
                      <input
                        ref={logoInputRef}
                        type="file"
                        accept="image/*"
                        onChange={handleLogoUpload}
                        className="hidden"
                      />
                    </div>
                  </div>

                  {/* Favicon */}
                  <div className="space-y-2">
                    <label className="text-sm font-medium">Favicon</label>
                    <div className="flex items-center gap-4">
                      {faviconPreview && (
                        <div className="relative">
                          <img
                            src={faviconPreview}
                            alt="Favicon preview"
                            className="w-8 h-8 object-contain border rounded"
                          />
                          <Button
                            type="button"
                            variant="destructive"
                            size="sm"
                            className="absolute -top-2 -right-2 h-4 w-4 rounded-full p-0"
                            onClick={handleRemoveFavicon}
                          >
                            <Trash2 className="h-2 w-2" />
                          </Button>
                        </div>
                      )}
                      <div className="space-y-2">
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => faviconInputRef.current?.click()}
                          className="flex items-center gap-2"
                        >
                          <Upload className="h-3 w-3" />
                          {faviconPreview ? 'Alterar' : 'Upload'}
                        </Button>
                        <p className="text-xs text-muted-foreground">
                          ICO, PNG. Máximo 1MB.
                        </p>
                      </div>
                      <input
                        ref={faviconInputRef}
                        type="file"
                        accept="image/*,.ico"
                        onChange={handleFaviconUpload}
                        className="hidden"
                      />
                    </div>
                  </div>

                  {/* Cores */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <FormField
                      control={form.control}
                      name="cor_primaria"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Cor Primária</FormLabel>
                          <div className="flex items-center gap-2">
                            <FormControl>
                              <Input
                                type="color"
                                {...field}
                                className="w-16 h-10 p-1 border rounded"
                              />
                            </FormControl>
                            <FormControl>
                              <Input
                                {...field}
                                placeholder="#000000"
                                className="flex-1"
                              />
                            </FormControl>
                          </div>
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
                          <div className="flex items-center gap-2">
                            <FormControl>
                              <Input
                                type="color"
                                {...field}
                                className="w-16 h-10 p-1 border rounded"
                              />
                            </FormControl>
                            <FormControl>
                              <Input
                                {...field}
                                placeholder="#ffffff"
                                className="flex-1"
                              />
                            </FormControl>
                          </div>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Tab Empresa */}
            <TabsContent value="empresa">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Building2 className="h-5 w-5" />
                    Informações da Empresa
                  </CardTitle>
                  <CardDescription>
                    Configure as informações básicas da sua empresa
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <FormField
                    control={form.control}
                    name="nome_empresa"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Nome da Empresa</FormLabel>
                        <FormControl>
                          <Input {...field} placeholder="Nome da sua empresa" />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="cnpj"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>CNPJ</FormLabel>
                        <FormControl>
                          <Input {...field} placeholder="00.000.000/0000-00" />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="endereco_completo"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Endereço Completo</FormLabel>
                        <FormControl>
                          <Textarea
                            {...field}
                            placeholder="Rua, número, bairro, cidade, estado, CEP"
                            rows={3}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <FormField
                      control={form.control}
                      name="telefone"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel className="flex items-center gap-2">
                            <Phone className="h-4 w-4" />
                            Telefone
                          </FormLabel>
                          <FormControl>
                            <Input {...field} placeholder="(11) 99999-9999" />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />

                    <FormField
                      control={form.control}
                      name="email_contato"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel className="flex items-center gap-2">
                            <Mail className="h-4 w-4" />
                            Email de Contato
                          </FormLabel>
                          <FormControl>
                            <Input {...field} type="email" placeholder="contato@empresa.com" />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>

                  <FormField
                    control={form.control}
                    name="site_url"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="flex items-center gap-2">
                          <Globe className="h-4 w-4" />
                          Website
                        </FormLabel>
                        <FormControl>
                          <Input {...field} placeholder="https://www.empresa.com" />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </CardContent>
              </Card>
            </TabsContent>

            {/* Tab Regional */}
            <TabsContent value="regional">
              <Card>
                <CardHeader>
                  <CardTitle>Configurações Regionais</CardTitle>
                  <CardDescription>
                    Configure timezone, moeda e formato de dados
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <FormField
                      control={form.control}
                      name="timezone"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Timezone</FormLabel>
                          <Select onValueChange={field.onChange} defaultValue={field.value}>
                            <FormControl>
                              <SelectTrigger>
                                <SelectValue placeholder="Selecione o timezone" />
                              </SelectTrigger>
                            </FormControl>
                            <SelectContent>
                              <SelectItem value="America/Sao_Paulo">São Paulo (UTC-3)</SelectItem>
                              <SelectItem value="America/Manaus">Manaus (UTC-4)</SelectItem>
                              <SelectItem value="America/Rio_Branco">Rio Branco (UTC-5)</SelectItem>
                            </SelectContent>
                          </Select>
                          <FormMessage />
                        </FormItem>
                      )}
                    />

                    <FormField
                      control={form.control}
                      name="moeda"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Moeda</FormLabel>
                          <Select onValueChange={field.onChange} defaultValue={field.value}>
                            <FormControl>
                              <SelectTrigger>
                                <SelectValue placeholder="Selecione a moeda" />
                              </SelectTrigger>
                            </FormControl>
                            <SelectContent>
                              <SelectItem value="BRL">Real Brasileiro (R$)</SelectItem>
                              <SelectItem value="USD">Dólar Americano ($)</SelectItem>
                              <SelectItem value="EUR">Euro (€)</SelectItem>
                            </SelectContent>
                          </Select>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <FormField
                      control={form.control}
                      name="idioma"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Idioma</FormLabel>
                          <Select onValueChange={field.onChange} defaultValue={field.value}>
                            <FormControl>
                              <SelectTrigger>
                                <SelectValue placeholder="Selecione o idioma" />
                              </SelectTrigger>
                            </FormControl>
                            <SelectContent>
                              <SelectItem value="pt-BR">Português (Brasil)</SelectItem>
                              <SelectItem value="en-US">English (US)</SelectItem>
                              <SelectItem value="es-ES">Español</SelectItem>
                            </SelectContent>
                          </Select>
                          <FormMessage />
                        </FormItem>
                      )}
                    />

                    <FormField
                      control={form.control}
                      name="formato_data"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Formato de Data</FormLabel>
                          <Select onValueChange={field.onChange} defaultValue={field.value}>
                            <FormControl>
                              <SelectTrigger>
                                <SelectValue placeholder="Selecione o formato" />
                              </SelectTrigger>
                            </FormControl>
                            <SelectContent>
                              <SelectItem value="DD/MM/YYYY">DD/MM/YYYY</SelectItem>
                              <SelectItem value="MM/DD/YYYY">MM/DD/YYYY</SelectItem>
                              <SelectItem value="YYYY-MM-DD">YYYY-MM-DD</SelectItem>
                            </SelectContent>
                          </Select>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>

                  {/* Notificações */}
                  <div className="space-y-4 pt-4 border-t">
                    <h3 className="text-lg font-medium flex items-center gap-2">
                      <Bell className="h-5 w-5" />
                      Notificações
                    </h3>

                    <div className="space-y-4">
                      <FormField
                        control={form.control}
                        name="email_notificacoes"
                        render={({ field }) => (
                          <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                            <div className="space-y-0.5">
                              <FormLabel className="text-base">Notificações por Email</FormLabel>
                              <FormDescription>
                                Receber notificações importantes por email
                              </FormDescription>
                            </div>
                            <FormControl>
                              <Switch
                                checked={field.value}
                                onCheckedChange={field.onChange}
                              />
                            </FormControl>
                          </FormItem>
                        )}
                      />

                      <FormField
                        control={form.control}
                        name="whatsapp_notificacoes"
                        render={({ field }) => (
                          <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                            <div className="space-y-0.5">
                              <FormLabel className="text-base">Notificações por WhatsApp</FormLabel>
                              <FormDescription>
                                Receber notificações via WhatsApp
                              </FormDescription>
                            </div>
                            <FormControl>
                              <Switch
                                checked={field.value}
                                onCheckedChange={field.onChange}
                              />
                            </FormControl>
                          </FormItem>
                        )}
                      />

                      {form.watch('whatsapp_notificacoes') && (
                        <FormField
                          control={form.control}
                          name="whatsapp_numero"
                          render={({ field }) => (
                            <FormItem>
                              <FormLabel>Número do WhatsApp</FormLabel>
                              <FormControl>
                                <Input {...field} placeholder="(11) 99999-9999" />
                              </FormControl>
                              <FormDescription>
                                Número para receber notificações do WhatsApp
                              </FormDescription>
                              <FormMessage />
                            </FormItem>
                          )}
                        />
                      )}
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Tab Pagamento */}
            <TabsContent value="pagamento">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <CreditCard className="h-5 w-5" />
                    Configurações de Pagamento
                  </CardTitle>
                  <CardDescription>
                    Configure os métodos de pagamento aceitos
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-4">
                    <FormField
                      control={form.control}
                      name="aceita_pix"
                      render={({ field }) => (
                        <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                          <div className="space-y-0.5">
                            <FormLabel className="text-base">PIX</FormLabel>
                            <FormDescription>
                              Aceitar pagamentos via PIX
                            </FormDescription>
                          </div>
                          <FormControl>
                            <Switch
                              checked={field.value}
                              onCheckedChange={field.onChange}
                            />
                          </FormControl>
                        </FormItem>
                      )}
                    />

                    <FormField
                      control={form.control}
                      name="aceita_cartao"
                      render={({ field }) => (
                        <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                          <div className="space-y-0.5">
                            <FormLabel className="text-base">Cartão de Crédito/Débito</FormLabel>
                            <FormDescription>
                              Aceitar pagamentos com cartão
                            </FormDescription>
                          </div>
                          <FormControl>
                            <Switch
                              checked={field.value}
                              onCheckedChange={field.onChange}
                            />
                          </FormControl>
                        </FormItem>
                      )}
                    />

                    {form.watch('aceita_cartao') && (
                      <FormField
                        control={form.control}
                        name="taxa_cartao"
                        render={({ field }) => (
                          <FormItem>
                            <FormLabel>Taxa do Cartão (%)</FormLabel>
                            <FormControl>
                              <Input
                                type="number"
                                step="0.01"
                                min="0"
                                max="100"
                                {...field}
                                onChange={(e) => field.onChange(parseFloat(e.target.value) || 0)}
                                placeholder="0.00"
                              />
                            </FormControl>
                            <FormDescription>
                              Taxa cobrada pelas operadoras de cartão
                            </FormDescription>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                    )}

                    <FormField
                      control={form.control}
                      name="aceita_dinheiro"
                      render={({ field }) => (
                        <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                          <div className="space-y-0.5">
                            <FormLabel className="text-base">Dinheiro</FormLabel>
                            <FormDescription>
                              Aceitar pagamentos em dinheiro
                            </FormDescription>
                          </div>
                          <FormControl>
                            <Switch
                              checked={field.value}
                              onCheckedChange={field.onChange}
                            />
                          </FormControl>
                        </FormItem>
                      )}
                    />
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Tab Relatórios */}
            <TabsContent value="relatorios">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <FileText className="h-5 w-5" />
                    Configurações de Relatórios
                  </CardTitle>
                  <CardDescription>
                    Configure a aparência dos relatórios gerados
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <FormField
                    control={form.control}
                    name="incluir_logo_relatorios"
                    render={({ field }) => (
                      <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                        <div className="space-y-0.5">
                          <FormLabel className="text-base">Incluir Logo nos Relatórios</FormLabel>
                          <FormDescription>
                            Adicionar o logo da empresa nos relatórios PDF
                          </FormDescription>
                        </div>
                        <FormControl>
                          <Switch
                            checked={field.value}
                            onCheckedChange={field.onChange}
                          />
                        </FormControl>
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="rodape_personalizado"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Rodapé Personalizado</FormLabel>
                        <FormControl>
                          <Textarea
                            {...field}
                            placeholder="Texto que aparecerá no rodapé dos relatórios"
                            rows={3}
                          />
                        </FormControl>
                        <FormDescription>
                          Texto personalizado para o rodapé dos relatórios (opcional)
                        </FormDescription>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>

          {/* Botões de Ação */}
          <div className="flex justify-end gap-4 pt-6 border-t">
            <Button
              type="button"
              variant="outline"
              onClick={() => form.reset()}
              disabled={updating}
            >
              Cancelar
            </Button>
            <Button type="submit" disabled={updating} className="flex items-center gap-2">
              {updating ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white" />
                  Salvando...
                </>
              ) : (
                <>
                  <Save className="h-4 w-4" />
                  Salvar Configurações
                </>
              )}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
};