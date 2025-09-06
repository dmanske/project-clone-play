import React, { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useSuperAdmin } from '@/hooks/useSuperAdmin';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from '@/components/ui/table';
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuTrigger 
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '@/components/ui/tabs';
import { 
  Building2, 
  Users, 
  Calendar, 
  DollarSign, 
  MoreHorizontal, 
  Search,
  Crown,
  AlertTriangle,
  CheckCircle,
  Clock,
  Ban,
  UserSearch,
  Phone,
  Mail,
  MapPin,
  Activity,
  Filter,
  Eye
} from 'lucide-react';
import { 
  ORGANIZATION_STATUS_LABELS, 
  ORGANIZATION_STATUS_COLORS,
  ACTIVITY_ACTION_LABELS,
  ACTIVITY_ACTION_COLORS,
  type OrganizationStatus,
  type OrganizationMetrics,
  type SystemActivityLog,
  type ActivityLogFilters,
  type ActivityActionType 
} from '@/types/multi-tenant';
import { toast } from 'sonner';

const SuperAdminDashboard: React.FC = () => {
  const { isSuperAdmin, isLoading: superAdminLoading } = useSuperAdmin();
  const [organizations, setOrganizations] = useState<OrganizationMetrics[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [stats, setStats] = useState({
    total: 0,
    active: 0,
    trial: 0,
    suspended: 0,
    blocked: 0
  });

  // Estados para o modal de suporte aos clientes
  const [isClientSupportOpen, setIsClientSupportOpen] = useState(false);
  const [selectedOrgForSupport, setSelectedOrgForSupport] = useState<string>('');
  const [clientSearchTerm, setClientSearchTerm] = useState('');
  const [clientsForSupport, setClientsForSupport] = useState<any[]>([]);
  const [isLoadingClients, setIsLoadingClients] = useState(false);

  // Estados para logs de atividades
  const [activityLogs, setActivityLogs] = useState<SystemActivityLog[]>([]);
  const [isLoadingLogs, setIsLoadingLogs] = useState(false);
  const [logFilters, setLogFilters] = useState<ActivityLogFilters>({});
  const [activeTab, setActiveTab] = useState('organizations');

  // Buscar todas as organizações com métricas
  const fetchOrganizations = async () => {
    setIsLoading(true);
    try {
      const { data, error } = await supabase
        .from('organizations')
        .select(`
          id,
          name,
          created_at,
          organization_subscriptions!inner(
            status,
            trial_end_date,
            subscription_end_date
          ),
          profiles(count)
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;

      // Buscar métricas adicionais para cada organização
      const orgsWithMetrics: OrganizationMetrics[] = await Promise.all(
        data.map(async (org) => {
          // Contar viagens
          const { count: viagensCount } = await supabase
            .from('viagens')
            .select('*', { count: 'exact', head: true })
            .eq('organization_id', org.id);

          // Contar clientes
          const { count: clientesCount } = await supabase
            .from('clientes')
            .select('*', { count: 'exact', head: true })
            .eq('organization_id', org.id);

          // Contar ônibus
          const { count: onibusCount } = await supabase
            .from('onibus')
            .select('*', { count: 'exact', head: true })
            .eq('organization_id', org.id);

          // Calcular dias até expirar
          const subscription = org.organization_subscriptions[0];
          let daysUntilExpiry: number | undefined;
          
          if (subscription?.status === 'TRIAL' && subscription.trial_end_date) {
            const trialEnd = new Date(subscription.trial_end_date);
            const now = new Date();
            const diffTime = trialEnd.getTime() - now.getTime();
            daysUntilExpiry = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
          }

          return {
            organization_id: org.id,
            organization_name: org.name,
            total_users: org.profiles?.length || 0,
            total_viagens: viagensCount || 0,
            total_clientes: clientesCount || 0,
            total_onibus: onibusCount || 0,
            last_login: '', // TODO: Implementar tracking de último login
            viagens_this_month: 0, // TODO: Implementar contagem mensal
            revenue_this_month: 0, // TODO: Implementar cálculo de receita
            subscription_status: subscription?.status as OrganizationStatus || 'TRIAL',
            days_until_expiry: daysUntilExpiry,
            created_at: org.created_at,
            trial_end_date: subscription?.trial_end_date
          };
        })
      );

      setOrganizations(orgsWithMetrics);

      // Calcular estatísticas
      const newStats = orgsWithMetrics.reduce((acc, org) => {
        acc.total++;
        switch (org.subscription_status) {
          case 'ACTIVE':
            acc.active++;
            break;
          case 'TRIAL':
            acc.trial++;
            break;
          case 'SUSPENDED':
            acc.suspended++;
            break;
          case 'BLOCKED':
            acc.blocked++;
            break;
        }
        return acc;
      }, { total: 0, active: 0, trial: 0, suspended: 0, blocked: 0 });

      setStats(newStats);
    } catch (error) {
      console.error('Erro ao buscar organizações:', error);
      toast.error('Erro ao carregar dados das organizações');
    } finally {
      setIsLoading(false);
    }
  };

  // Alterar status de uma organização
  const changeOrganizationStatus = async (organizationId: string, newStatus: OrganizationStatus) => {
    try {
      const { error } = await supabase
        .from('organization_subscriptions')
        .update({ status: newStatus })
        .eq('organization_id', organizationId);

      if (error) throw error;

      toast.success('Status da organização atualizado com sucesso');
      fetchOrganizations(); // Recarregar dados
    } catch (error) {
      console.error('Erro ao alterar status:', error);
      toast.error('Erro ao alterar status da organização');
    }
  };

  // Buscar clientes de uma organização para suporte
  const fetchClientsForSupport = async (organizationId: string, searchTerm: string = '') => {
    if (!organizationId) return;
    
    setIsLoadingClients(true);
    try {
      let query = supabase
        .from('clientes')
        .select(`
          id,
          nome,
          email,
          telefone,
          cpf,
          cidade,
          estado,
          created_at,
          organization_id
        `)
        .eq('organization_id', organizationId)
        .order('created_at', { ascending: false })
        .limit(50);

      if (searchTerm) {
        query = query.or(`nome.ilike.%${searchTerm}%,email.ilike.%${searchTerm}%,telefone.ilike.%${searchTerm}%,cpf.ilike.%${searchTerm}%`);
      }

      const { data, error } = await query;

      if (error) throw error;

      setClientsForSupport(data || []);
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      toast.error('Erro ao carregar dados dos clientes');
    } finally {
      setIsLoadingClients(false);
    }
  };

  // Abrir modal de suporte com organização selecionada
  const openClientSupport = (organizationId: string) => {
    setSelectedOrgForSupport(organizationId);
    setClientSearchTerm('');
    setClientsForSupport([]);
    setIsClientSupportOpen(true);
    fetchClientsForSupport(organizationId);
  };

  // Buscar logs de atividades
  const fetchActivityLogs = async (filters: ActivityLogFilters = {}) => {
    setIsLoadingLogs(true);
    try {
      let query = supabase
        .from('system_activity_logs')
        .select(`
          id,
          organization_id,
          user_id,
          action_type,
          resource_type,
          resource_id,
          description,
          metadata,
          ip_address,
          user_agent,
          created_at,
          organizations(name),
          profiles(full_name, email)
        `)
        .order('created_at', { ascending: false })
        .limit(100);

      // Aplicar filtros
      if (filters.organization_id) {
        query = query.eq('organization_id', filters.organization_id);
      }
      if (filters.action_type) {
        query = query.eq('action_type', filters.action_type);
      }
      if (filters.resource_type) {
        query = query.eq('resource_type', filters.resource_type);
      }
      if (filters.date_from) {
        query = query.gte('created_at', filters.date_from);
      }
      if (filters.date_to) {
        query = query.lte('created_at', filters.date_to);
      }
      if (filters.search) {
        query = query.ilike('description', `%${filters.search}%`);
      }

      const { data, error } = await query;

      if (error) throw error;

      // Mapear dados com informações relacionadas
      const logsWithRelations: SystemActivityLog[] = (data || []).map((log: any) => ({
        ...log,
        organization_name: log.organizations?.name,
        user_name: log.profiles?.full_name,
        user_email: log.profiles?.email,
      }));

      setActivityLogs(logsWithRelations);
    } catch (error) {
      console.error('Erro ao buscar logs de atividades:', error);
      toast.error('Erro ao carregar logs de atividades');
    } finally {
      setIsLoadingLogs(false);
    }
  };

  // Filtrar organizações
  const filteredOrganizations = organizations.filter(org =>
    org.organization_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  useEffect(() => {
    if (isSuperAdmin && !superAdminLoading) {
      fetchOrganizations();
      if (activeTab === 'activity-logs') {
        fetchActivityLogs(logFilters);
      }
    }
  }, [isSuperAdmin, superAdminLoading, activeTab]);

  // Carregar logs quando os filtros mudarem
  useEffect(() => {
    if (isSuperAdmin && activeTab === 'activity-logs') {
      fetchActivityLogs(logFilters);
    }
  }, [logFilters, isSuperAdmin, activeTab]);

  // Verificar se é super admin
  if (superAdminLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto mb-2"></div>
          <p className="text-gray-600">Carregando...</p>
        </div>
      </div>
    );
  }

  if (!isSuperAdmin) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <AlertTriangle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Acesso Negado</h2>
          <p className="text-gray-600">Você não tem permissão para acessar esta página.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Crown className="h-8 w-8 text-purple-600" />
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Super Admin Dashboard</h1>
            <p className="text-gray-600">Gerencie todas as organizações do sistema</p>
          </div>
        </div>
        <div className="flex gap-2">
          <Dialog open={isClientSupportOpen} onOpenChange={setIsClientSupportOpen}>
            <DialogTrigger asChild>
              <Button variant="outline" className="flex items-center gap-2">
                <UserSearch className="h-4 w-4" />
                Suporte aos Clientes
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
              <DialogHeader>
                <DialogTitle className="flex items-center gap-2">
                  <UserSearch className="h-5 w-5" />
                  Suporte aos Clientes
                </DialogTitle>
                <DialogDescription>
                  Acesse os dados dos clientes de qualquer organização para suporte técnico
                </DialogDescription>
              </DialogHeader>

              <div className="space-y-4">
                {/* Seletor de Organização */}
                <div className="space-y-2">
                  <label className="text-sm font-medium">Selecionar Organização:</label>
                  <Select 
                    value={selectedOrgForSupport} 
                    onValueChange={(value) => {
                      setSelectedOrgForSupport(value);
                      fetchClientsForSupport(value, clientSearchTerm);
                    }}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Escolha uma organização..." />
                    </SelectTrigger>
                    <SelectContent>
                      {organizations.map((org) => (
                        <SelectItem key={org.organization_id} value={org.organization_id}>
                          {org.organization_name} ({org.total_clientes} clientes)
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* Busca de Clientes */}
                {selectedOrgForSupport && (
                  <div className="space-y-2">
                    <label className="text-sm font-medium">Buscar Cliente:</label>
                    <div className="relative">
                      <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        placeholder="Nome, email, telefone ou CPF..."
                        value={clientSearchTerm}
                        onChange={(e) => {
                          setClientSearchTerm(e.target.value);
                          fetchClientsForSupport(selectedOrgForSupport, e.target.value);
                        }}
                        className="pl-10"
                      />
                    </div>
                  </div>
                )}

                {/* Lista de Clientes */}
                {selectedOrgForSupport && (
                  <div className="border rounded-lg">
                    {isLoadingClients ? (
                      <div className="p-8 text-center">
                        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-gray-900 mx-auto mb-2"></div>
                        <p className="text-gray-600">Carregando clientes...</p>
                      </div>
                    ) : clientsForSupport.length === 0 ? (
                      <div className="p-8 text-center text-gray-500">
                        {clientSearchTerm ? 'Nenhum cliente encontrado com esses critérios' : 'Nenhum cliente cadastrado'}
                      </div>
                    ) : (
                      <div className="divide-y">
                        {clientsForSupport.map((cliente) => (
                          <div key={cliente.id} className="p-4 hover:bg-gray-50">
                            <div className="flex justify-between items-start">
                              <div className="space-y-1">
                                <h4 className="font-medium text-gray-900">{cliente.nome}</h4>
                                <div className="flex flex-wrap gap-4 text-sm text-gray-600">
                                  {cliente.email && (
                                    <div className="flex items-center gap-1">
                                      <Mail className="h-3 w-3" />
                                      {cliente.email}
                                    </div>
                                  )}
                                  {cliente.telefone && (
                                    <div className="flex items-center gap-1">
                                      <Phone className="h-3 w-3" />
                                      {cliente.telefone}
                                    </div>
                                  )}
                                  {(cliente.cidade || cliente.estado) && (
                                    <div className="flex items-center gap-1">
                                      <MapPin className="h-3 w-3" />
                                      {[cliente.cidade, cliente.estado].filter(Boolean).join(', ')}
                                    </div>
                                  )}
                                </div>
                                {cliente.cpf && (
                                  <div className="text-xs text-gray-500">
                                    CPF: {cliente.cpf}
                                  </div>
                                )}
                              </div>
                              <div className="text-xs text-gray-500">
                                Cadastrado em {new Date(cliente.created_at).toLocaleDateString('pt-BR')}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}
              </div>
            </DialogContent>
          </Dialog>

          <Button onClick={fetchOrganizations} disabled={isLoading}>
            {isLoading ? 'Carregando...' : 'Atualizar'}
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total</CardTitle>
            <Building2 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Ativas</CardTitle>
            <CheckCircle className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.active}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Trial</CardTitle>
            <Clock className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">{stats.trial}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Suspensas</CardTitle>
            <AlertTriangle className="h-4 w-4 text-yellow-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">{stats.suspended}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Bloqueadas</CardTitle>
            <Ban className="h-4 w-4 text-red-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{stats.blocked}</div>
          </CardContent>
        </Card>
      </div>

      {/* Tabs Navigation */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="organizations" className="flex items-center gap-2">
            <Building2 className="h-4 w-4" />
            Organizações
          </TabsTrigger>
          <TabsTrigger value="activity-logs" className="flex items-center gap-2">
            <Activity className="h-4 w-4" />
            Logs de Atividades
          </TabsTrigger>
        </TabsList>

        {/* Aba de Organizações */}
        <TabsContent value="organizations">
          <Card>
            <CardHeader>
              <CardTitle>Organizações</CardTitle>
              <CardDescription>
                Gerencie todas as organizações cadastradas no sistema
              </CardDescription>
            </CardHeader>
            <CardContent>
          <div className="flex items-center gap-4 mb-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input
                placeholder="Buscar organizações..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          {/* Organizations Table */}
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Organização</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Usuários</TableHead>
                  <TableHead>Viagens</TableHead>
                  <TableHead>Clientes</TableHead>
                  <TableHead>Criada em</TableHead>
                  <TableHead>Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  <TableRow>
                    <TableCell colSpan={7} className="text-center py-8">
                      <div className="flex items-center justify-center">
                        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-gray-900 mr-2"></div>
                        Carregando organizações...
                      </div>
                    </TableCell>
                  </TableRow>
                ) : filteredOrganizations.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7} className="text-center py-8 text-gray-500">
                      Nenhuma organização encontrada
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredOrganizations.map((org) => (
                    <TableRow key={org.organization_id}>
                      <TableCell className="font-medium">
                        {org.organization_name}
                      </TableCell>
                      <TableCell>
                        <Badge className={ORGANIZATION_STATUS_COLORS[org.subscription_status]}>
                          {ORGANIZATION_STATUS_LABELS[org.subscription_status]}
                        </Badge>
                        {org.days_until_expiry !== undefined && org.days_until_expiry <= 3 && (
                          <div className="text-xs text-red-600 mt-1">
                            {org.days_until_expiry <= 0 ? 'Expirado' : `${org.days_until_expiry} dias restantes`}
                          </div>
                        )}
                      </TableCell>
                      <TableCell>{org.total_users}</TableCell>
                      <TableCell>{org.total_viagens}</TableCell>
                      <TableCell>{org.total_clientes}</TableCell>
                      <TableCell>
                        {new Date(org.created_at).toLocaleDateString('pt-BR')}
                      </TableCell>
                      <TableCell>
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuItem
                              onClick={() => openClientSupport(org.organization_id)}
                              className="flex items-center gap-2"
                            >
                              <UserSearch className="h-4 w-4" />
                              Ver Clientes
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => changeOrganizationStatus(org.organization_id, 'ACTIVE')}
                              disabled={org.subscription_status === 'ACTIVE'}
                            >
                              Ativar
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => changeOrganizationStatus(org.organization_id, 'SUSPENDED')}
                              disabled={org.subscription_status === 'SUSPENDED'}
                            >
                              Suspender
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => changeOrganizationStatus(org.organization_id, 'BLOCKED')}
                              disabled={org.subscription_status === 'BLOCKED'}
                              className="text-red-600"
                            >
                              Bloquear
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </TabsContent>

    {/* Aba de Logs de Atividades */}
    <TabsContent value="activity-logs">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="h-5 w-5" />
            Logs de Atividades do Sistema
          </CardTitle>
          <CardDescription>
            Monitore todas as atividades realizadas no sistema
          </CardDescription>
        </CardHeader>
        <CardContent>
          {/* Filtros dos Logs */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div className="space-y-2">
              <label className="text-sm font-medium">Organização:</label>
              <Select 
                value={logFilters.organization_id || ''} 
                onValueChange={(value) => setLogFilters(prev => ({ ...prev, organization_id: value || undefined }))}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Todas as organizações" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">Todas as organizações</SelectItem>
                  {organizations.map((org) => (
                    <SelectItem key={org.organization_id} value={org.organization_id}>
                      {org.organization_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Tipo de Ação:</label>
              <Select 
                value={logFilters.action_type || ''} 
                onValueChange={(value) => setLogFilters(prev => ({ ...prev, action_type: value as ActivityActionType || undefined }))}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Todas as ações" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">Todas as ações</SelectItem>
                  {Object.entries(ACTIVITY_ACTION_LABELS).map(([key, label]) => (
                    <SelectItem key={key} value={key}>
                      {label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Data Inicial:</label>
              <Input
                type="date"
                value={logFilters.date_from || ''}
                onChange={(e) => setLogFilters(prev => ({ ...prev, date_from: e.target.value || undefined }))}
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Data Final:</label>
              <Input
                type="date"
                value={logFilters.date_to || ''}
                onChange={(e) => setLogFilters(prev => ({ ...prev, date_to: e.target.value || undefined }))}
              />
            </div>
          </div>

          <div className="flex items-center gap-4 mb-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input
                placeholder="Buscar na descrição..."
                value={logFilters.search || ''}
                onChange={(e) => setLogFilters(prev => ({ ...prev, search: e.target.value || undefined }))}
                className="pl-10"
              />
            </div>
            <Button 
              variant="outline" 
              onClick={() => setLogFilters({})}
              className="flex items-center gap-2"
            >
              <Filter className="h-4 w-4" />
              Limpar Filtros
            </Button>
          </div>

          {/* Tabela de Logs */}
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Data/Hora</TableHead>
                  <TableHead>Organização</TableHead>
                  <TableHead>Usuário</TableHead>
                  <TableHead>Ação</TableHead>
                  <TableHead>Descrição</TableHead>
                  <TableHead>IP</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoadingLogs ? (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center py-8">
                      <div className="flex items-center justify-center">
                        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-gray-900 mr-2"></div>
                        Carregando logs...
                      </div>
                    </TableCell>
                  </TableRow>
                ) : activityLogs.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center py-8 text-gray-500">
                      Nenhum log encontrado
                    </TableCell>
                  </TableRow>
                ) : (
                  activityLogs.map((log) => (
                    <TableRow key={log.id}>
                      <TableCell className="font-mono text-sm">
                        {new Date(log.created_at).toLocaleString('pt-BR')}
                      </TableCell>
                      <TableCell>
                        {log.organization_name || 'Sistema'}
                      </TableCell>
                      <TableCell>
                        {log.user_name || log.user_email || 'Sistema'}
                      </TableCell>
                      <TableCell>
                        <Badge className={ACTIVITY_ACTION_COLORS[log.action_type]}>
                          {ACTIVITY_ACTION_LABELS[log.action_type]}
                        </Badge>
                      </TableCell>
                      <TableCell className="max-w-md">
                        <div className="truncate" title={log.description}>
                          {log.description}
                        </div>
                        {log.metadata && (
                          <div className="text-xs text-gray-500 mt-1">
                            {log.resource_type && `Recurso: ${log.resource_type}`}
                          </div>
                        )}
                      </TableCell>
                      <TableCell className="font-mono text-xs">
                        {log.ip_address || '-'}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </TabsContent>
  </Tabs>
    </div>
  );
};

export default SuperAdminDashboard;