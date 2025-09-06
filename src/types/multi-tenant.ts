// =====================================================
// TIPOS TYPESCRIPT - SISTEMA MULTI-TENANT
// =====================================================

// Status das organizações
export type OrganizationStatus = 'TRIAL' | 'ACTIVE' | 'SUSPENDED' | 'BLOCKED';

// Status dos convites
export type InvitationStatus = 'PENDING' | 'ACCEPTED' | 'EXPIRED' | 'CANCELLED';

// Roles dos usuários
export type UserRole = 'owner' | 'admin' | 'user';

// =====================================================
// ASSINATURAS DAS ORGANIZAÇÕES
// =====================================================
export interface OrganizationSubscription {
  id: string;
  organization_id: string;
  
  // Status
  status: OrganizationStatus;
  
  // Datas
  trial_start_date: string;
  trial_end_date: string;
  subscription_start_date?: string;
  subscription_end_date?: string;
  
  // Stripe
  stripe_customer_id?: string;
  stripe_subscription_id?: string;
  stripe_price_id?: string;
  
  // Controle
  created_at: string;
  updated_at: string;
}

// =====================================================
// CONFIGURAÇÕES DAS ORGANIZAÇÕES
// =====================================================
export interface PasseioPadrao {
  id: string;
  nome: string;
  descricao?: string;
  valor?: number;
  incluido: boolean;
}

export interface OrganizationSettings {
  id: string;
  organization_id: string;
  
  // Branding
  logo_empresa_url?: string;
  logo_time_url?: string;
  cor_primaria: string;
  cor_secundaria: string;
  
  // Informações para relatórios
  endereco_completo?: string;
  telefone?: string;
  email_contato?: string;
  site_url?: string;
  
  // Configurações
  passeios_padrao: PasseioPadrao[];
  timezone: string;
  moeda: string;
  
  // Controle
  created_at: string;
  updated_at: string;
}

// =====================================================
// CONVITES DE USUÁRIOS
// =====================================================
export interface UserInvitation {
  id: string;
  organization_id: string;
  
  // Dados do convite
  email: string;
  role: UserRole;
  permissions: UserPermissions;
  
  // Controle
  invited_by?: string;
  token: string;
  status: InvitationStatus;
  
  // Datas
  expires_at: string;
  accepted_at?: string;
  
  // Controle
  created_at: string;
  updated_at: string;
  
  // Relacionamentos
  invited_by_profile?: {
    full_name: string;
    email: string;
  };
}

// =====================================================
// PERMISSÕES DOS USUÁRIOS
// =====================================================
export interface ModulePermission {
  read: boolean;
  write: boolean;
  delete: boolean;
}

export interface UserPermissions {
  viagens: ModulePermission;
  clientes: ModulePermission;
  onibus: ModulePermission;
  financeiro: ModulePermission;
  relatorios: ModulePermission;
  configuracoes: ModulePermission;
  usuarios: ModulePermission;
}

export interface UserPermissionRecord {
  id: string;
  user_id: string;
  organization_id: string;
  permissions: UserPermissions;
  created_at: string;
  updated_at: string;
}

// =====================================================
// SUPER ADMINISTRADORES
// =====================================================
export interface SuperAdminUser {
  id: string;
  user_id: string;
  
  // Permissões
  can_access_all_tenants: boolean;
  can_manage_subscriptions: boolean;
  can_block_organizations: boolean;
  can_view_analytics: boolean;
  
  // Controle
  created_by?: string;
  created_at: string;
  updated_at: string;
}

// =====================================================
// CONTEXTO DO TENANT
// =====================================================
export interface TenantContext {
  organization: {
    id: string;
    name: string;
    slug: string;
    logo_url?: string;
  };
  subscription: OrganizationSubscription;
  settings: OrganizationSettings;
  permissions: UserPermissions;
  isActive: boolean;
  isTrial: boolean;
  daysUntilExpiry?: number;
}

// =====================================================
// MÉTRICAS E ANALYTICS
// =====================================================
export interface OrganizationMetrics {
  organization_id: string;
  organization_name: string;
  
  // Contadores
  total_users: number;
  total_viagens: number;
  total_clientes: number;
  total_onibus: number;
  
  // Atividade
  last_login: string;
  viagens_this_month: number;
  revenue_this_month: number;
  
  // Status
  subscription_status: OrganizationStatus;
  days_until_expiry?: number;
  
  // Datas
  created_at: string;
  trial_end_date?: string;
}

// =====================================================
// FORMULÁRIOS E INPUTS
// =====================================================
export interface CreateOrganizationForm {
  name: string;
  slug: string;
  admin_name: string;
  admin_email: string;
  admin_password: string;
}

export interface InviteUserForm {
  email: string;
  role: UserRole;
  permissions?: Partial<UserPermissions>;
}

export interface UpdateOrganizationSettingsForm {
  // Branding
  logo_empresa_url?: string;
  logo_time_url?: string;
  cor_primaria?: string;
  cor_secundaria?: string;
  
  // Informações
  endereco_completo?: string;
  telefone?: string;
  email_contato?: string;
  site_url?: string;
  
  // Configurações
  passeios_padrao?: PasseioPadrao[];
  timezone?: string;
  moeda?: string;
}

// =====================================================
// UTILITÁRIOS
// =====================================================
export interface TenantGuard {
  canRead: (module: keyof UserPermissions) => boolean;
  canWrite: (module: keyof UserPermissions) => boolean;
  canDelete: (module: keyof UserPermissions) => boolean;
  isAdmin: () => boolean;
  isOwner: () => boolean;
  isSuperAdmin: () => boolean;
}

// =====================================================
// RESPONSES DA API
// =====================================================
export interface CreateOrganizationResponse {
  organization: {
    id: string;
    name: string;
    slug: string;
  };
  admin_user: {
    id: string;
    email: string;
  };
  subscription: OrganizationSubscription;
}

export interface InviteUserResponse {
  invitation: UserInvitation;
  invitation_url: string;
}

// =====================================================
// HOOKS E CONTEXTOS
// =====================================================
export interface UseTenantReturn {
  tenant: TenantContext | null;
  isLoading: boolean;
  error: string | null;
  refreshTenant: () => Promise<void>;
  switchTenant: (organizationId: string) => Promise<void>;
}

export interface UsePermissionsReturn {
  permissions: UserPermissions | null;
  guard: TenantGuard;
  isLoading: boolean;
  canAccess: (module: keyof UserPermissions, action: 'read' | 'write' | 'delete') => boolean;
}

export interface UseSuperAdminReturn {
  isSuperAdmin: boolean;
  superAdminData: SuperAdminUser | null;
  canAccessTenant: (organizationId: string) => boolean;
  switchToTenant: (organizationId: string) => Promise<void>;
  isLoading: boolean;
}

// =====================================================
// CONSTANTES
// =====================================================
export const DEFAULT_PERMISSIONS: UserPermissions = {
  viagens: { read: true, write: false, delete: false },
  clientes: { read: true, write: false, delete: false },
  onibus: { read: true, write: false, delete: false },
  financeiro: { read: false, write: false, delete: false },
  relatorios: { read: true, write: false, delete: false },
  configuracoes: { read: false, write: false, delete: false },
  usuarios: { read: false, write: false, delete: false },
};

export const ADMIN_PERMISSIONS: UserPermissions = {
  viagens: { read: true, write: true, delete: true },
  clientes: { read: true, write: true, delete: true },
  onibus: { read: true, write: true, delete: true },
  financeiro: { read: true, write: true, delete: true },
  relatorios: { read: true, write: true, delete: false },
  configuracoes: { read: true, write: true, delete: false },
  usuarios: { read: true, write: true, delete: true },
};

export const OWNER_PERMISSIONS: UserPermissions = {
  viagens: { read: true, write: true, delete: true },
  clientes: { read: true, write: true, delete: true },
  onibus: { read: true, write: true, delete: true },
  financeiro: { read: true, write: true, delete: true },
  relatorios: { read: true, write: true, delete: true },
  configuracoes: { read: true, write: true, delete: true },
  usuarios: { read: true, write: true, delete: true },
};

export const ORGANIZATION_STATUS_LABELS: Record<OrganizationStatus, string> = {
  TRIAL: 'Período Trial',
  ACTIVE: 'Ativo',
  SUSPENDED: 'Suspenso',
  BLOCKED: 'Bloqueado',
};

export const ORGANIZATION_STATUS_COLORS: Record<OrganizationStatus, string> = {
  TRIAL: 'bg-blue-100 text-blue-800',
  ACTIVE: 'bg-green-100 text-green-800',
  SUSPENDED: 'bg-yellow-100 text-yellow-800',
  BLOCKED: 'bg-red-100 text-red-800',
};

// =====================================================
// LOGS DE ATIVIDADES DO SISTEMA
// =====================================================
export type ActivityActionType = 
  | 'LOGIN' 
  | 'LOGOUT' 
  | 'CREATE' 
  | 'UPDATE' 
  | 'DELETE' 
  | 'STATUS_CHANGE'
  | 'SYSTEM_START'
  | 'SYSTEM_ERROR'
  | 'DATA_EXPORT'
  | 'BACKUP'
  | 'RESTORE';

export type ActivityResourceType = 
  | 'VIAGEM' 
  | 'CLIENTE' 
  | 'ONIBUS' 
  | 'ORGANIZATION' 
  | 'USER'
  | 'SYSTEM'
  | 'INGRESSO'
  | 'PAGAMENTO';

export interface SystemActivityLog {
  id: string;
  organization_id?: string;
  user_id?: string;
  action_type: ActivityActionType;
  resource_type?: ActivityResourceType;
  resource_id?: string;
  description: string;
  metadata?: Record<string, any>;
  ip_address?: string;
  user_agent?: string;
  created_at: string;
  // Dados relacionados (joins)
  organization_name?: string;
  user_email?: string;
  user_name?: string;
}

export interface ActivityLogFilters {
  organization_id?: string;
  user_id?: string;
  action_type?: ActivityActionType;
  resource_type?: ActivityResourceType;
  date_from?: string;
  date_to?: string;
  search?: string;
}

export const ACTIVITY_ACTION_LABELS: Record<ActivityActionType, string> = {
  LOGIN: 'Login',
  LOGOUT: 'Logout',
  CREATE: 'Criação',
  UPDATE: 'Atualização',
  DELETE: 'Exclusão',
  STATUS_CHANGE: 'Mudança de Status',
  SYSTEM_START: 'Início do Sistema',
  SYSTEM_ERROR: 'Erro do Sistema',
  DATA_EXPORT: 'Exportação de Dados',
  BACKUP: 'Backup',
  RESTORE: 'Restauração',
};

export const ACTIVITY_ACTION_COLORS: Record<ActivityActionType, string> = {
  LOGIN: 'bg-green-100 text-green-800',
  LOGOUT: 'bg-gray-100 text-gray-800',
  CREATE: 'bg-blue-100 text-blue-800',
  UPDATE: 'bg-yellow-100 text-yellow-800',
  DELETE: 'bg-red-100 text-red-800',
  STATUS_CHANGE: 'bg-purple-100 text-purple-800',
  SYSTEM_START: 'bg-indigo-100 text-indigo-800',
  SYSTEM_ERROR: 'bg-red-100 text-red-800',
  DATA_EXPORT: 'bg-cyan-100 text-cyan-800',
  BACKUP: 'bg-teal-100 text-teal-800',
  RESTORE: 'bg-orange-100 text-orange-800',
};