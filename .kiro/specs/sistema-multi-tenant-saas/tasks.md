# Tasks - Sistema Multi-Tenant SaaS

## 📋 Lista de Tasks

### **FASE 1: Fundação Multi-Tenant** 🏗️

#### **Task 1: Estrutura Base de Tenants**
- [x] 1.1 Criar tabela `organization_subscriptions`
- [x] 1.2 Criar tabela `organization_settings`
- [x] 1.3 Criar tabela `user_invitations`
- [x] 1.4 Criar tabela `user_permissions`
- [x] 1.5 Criar tabela `super_admin_users`
- [x] 1.6 Configurar RLS policies para novas tabelas
- [x] 1.7 Criar functions auxiliares no Supabase
- [x] 1.8 Criar tipos TypeScript
- [x] 1.9 Criar TenantContext
- [x] 1.10 Criar hooks de permissões
- [x] 1.11 Criar componentes de proteção
- [x] 1.12 Integrar no App.tsx

**Status**: ✅ Concluída
**Estimativa**: 2 dias

---

#### **Task 2: Autenticação Multi-Tenant**
- [x] 2.1 Adaptar AuthContext para multi-tenant
- [x] 2.2 Criar TenantContext para tenant ativo
- [x] 2.3 Implementar middleware de proteção por tenant
- [x] 2.4 Adaptar ProtectedRoute para verificar tenant
- [x] 2.5 Sistema de seleção de tenant após login
- [x] 2.6 Controle de acesso baseado em permissões
- [x] 2.7 Hook useSuperAdmin
- [x] 2.8 Componentes de proteção (TenantProtection, ProtectedNavItem)
- [x] 2.9 TenantSelector para super admins
- [x] 2.10 Integração no MainLayout

**Status**: ✅ Concluída
**Estimativa**: 3 dias

---

#### **Task 3: Super Admin Dashboard**
- [x] 3.1 Criar página SuperAdminDashboard
- [x] 3.2 Lista de todas as organizações
- [x] 3.3 Controle de status (TRIAL/ACTIVE/SUSPENDED/BLOCKED)
- [x] 3.4 Métricas de uso por organização
- [x] 3.5 Acesso aos dados dos clientes (suporte)
- [x] 3.6 Logs de atividades do sistema
- [x] 3.7 Cards de estatísticas
- [x] 3.8 Busca e filtros
- [x] 3.9 Ações de gerenciamento
- [x] 3.10 Integração no menu (apenas super admins)

**Status**: ✅ Concluída
**Estimativa**: 3 dias

---

#### **Task 4: Sistema de Permissões**
- [ ] 4.1 Definir estrutura de permissões
- [ ] 4.2 Hook usePermissions
- [ ] 4.3 Componente de proteção por permissão
- [ ] 4.4 Interface para gerenciar permissões
- [ ] 4.5 Permissões padrão por role
- [ ] 4.6 Validação no backend

**Status**: ⏳ Pendente
**Estimativa**: 2 dias

---

### **FASE 2: Migração Core** 🔄

#### **Task 5: Hooks Multi-Tenant**
- [ ] 5.1 Adaptar useViagens com filtro por tenant
- [ ] 5.2 Adaptar usePasseios com configurações por tenant
- [ ] 5.3 Adaptar useClientes isolado por tenant
- [ ] 5.4 Adaptar todos os hooks existentes
- [ ] 5.5 Criar useTenantData hook genérico
- [ ] 5.6 Otimizar queries com tenant_id

**Status**: ⏳ Pendente
**Estimativa**: 3 dias

---

#### **Task 6: Páginas Principais**
- [ ] 6.1 Adaptar Dashboard com dados do tenant
- [ ] 6.2 Adaptar Viagens isoladas por tenant
- [ ] 6.3 Adaptar Clientes isolados por tenant
- [ ] 6.4 Adaptar Relatórios por tenant
- [ ] 6.5 Adaptar todas as páginas principais
- [ ] 6.6 Breadcrumbs com nome da organização

**Status**: ⏳ Pendente
**Estimativa**: 4 dias

---

#### **Task 7: Sistema de Configurações**
- [ ] 7.1 Página OrganizationSettings
- [ ] 7.2 Upload de logos (empresa + time)
- [ ] 7.3 Configuração de cores/tema
- [ ] 7.4 Configuração de passeios padrão
- [ ] 7.5 Informações para relatórios
- [ ] 7.6 Hook useOrganizationSettings

**Status**: ⏳ Pendente
**Estimativa**: 3 dias

---

#### **Task 8: Isolamento de Dados**
- [ ] 8.1 Adicionar tenant_id em todas as queries
- [ ] 8.2 Atualizar RLS policies existentes
- [ ] 8.3 Middleware de validação no backend
- [ ] 8.4 Testes de isolamento
- [ ] 8.5 Auditoria de segurança
- [ ] 8.6 Logs de acesso por tenant

**Status**: ⏳ Pendente
**Estimativa**: 3 dias

---

### **FASE 3: UX & Onboarding** 🎨

#### **Task 9: Onboarding de Novos Tenants**
- [ ] 9.1 Página de cadastro de organização
- [ ] 9.2 Período trial automático (7 dias)
- [ ] 9.3 Setup inicial guiado
- [ ] 9.4 Primeiro usuário admin automático
- [ ] 9.5 Email de boas-vindas
- [ ] 9.6 Tutorial interativo

**Status**: ⏳ Pendente
**Estimativa**: 4 dias

---

#### **Task 10: Branding Dinâmico**
- [ ] 10.1 Logo nos relatórios por tenant
- [ ] 10.2 Cores personalizadas por tenant
- [ ] 10.3 Informações da empresa nos documentos
- [ ] 10.4 Templates personalizáveis
- [ ] 10.5 Preview das configurações
- [ ] 10.6 Cache de configurações

**Status**: ⏳ Pendente
**Estimativa**: 3 dias

---

#### **Task 11: Gestão de Usuários**
- [ ] 11.1 Página de usuários da organização
- [ ] 11.2 Sistema de convites por email
- [ ] 11.3 Definição de permissões por usuário
- [ ] 11.4 Ativação/desativação de usuários
- [ ] 11.5 Histórico de atividades
- [ ] 11.6 Notificações de convites

**Status**: ⏳ Pendente
**Estimativa**: 4 dias

---

#### **Task 12: Interface de Configurações**
- [ ] 12.1 Menu de configurações por tenant
- [ ] 12.2 Wizard de configuração inicial
- [ ] 12.3 Validações em tempo real
- [ ] 12.4 Preview das mudanças
- [ ] 12.5 Histórico de alterações
- [ ] 12.6 Backup/restore de configurações

**Status**: ⏳ Pendente
**Estimativa**: 3 dias

---

### **FASE 4: Controle & Monetização** 💰

#### **Task 13: Sistema de Pagamentos Stripe**
- [ ] 13.1 Configuração do Stripe
- [ ] 13.2 Criação de produtos/preços
- [ ] 13.3 Checkout de assinatura
- [ ] 13.4 Webhooks do Stripe
- [ ] 13.5 Gerenciamento de assinaturas
- [ ] 13.6 Faturas e cobrança

**Status**: ⏳ Pendente
**Estimativa**: 5 dias

---

#### **Task 14: Controle de Status/Bloqueios**
- [ ] 14.1 Middleware de verificação de status
- [ ] 14.2 Bloqueio automático por falta de pagamento
- [ ] 14.3 Notificações de vencimento
- [ ] 14.4 Página de status da conta
- [ ] 14.5 Reativação de contas
- [ ] 14.6 Logs de bloqueios/desbloqueios

**Status**: ⏳ Pendente
**Estimativa**: 3 dias

---

#### **Task 15: Métricas & Analytics**
- [ ] 15.1 Dashboard de métricas super admin
- [ ] 15.2 Uso por tenant (usuários, viagens, etc.)
- [ ] 15.3 Relatórios financeiros
- [ ] 15.4 Alertas de sistema
- [ ] 15.5 Exportação de dados
- [ ] 15.6 Gráficos e visualizações

**Status**: ⏳ Pendente
**Estimativa**: 4 dias

---

#### **Task 16: Testes & Refinamentos**
- [ ] 16.1 Testes de isolamento de dados
- [ ] 16.2 Testes de performance
- [ ] 16.3 Testes de segurança
- [ ] 16.4 Testes de pagamentos
- [ ] 16.5 Documentação técnica
- [ ] 16.6 Treinamento para suporte

**Status**: ⏳ Pendente
**Estimativa**: 3 dias

---

## 📊 Resumo

**Total de Tasks**: 16
**Estimativa Total**: 52 dias
**Status Geral**: 🚀 Iniciando

### Por Fase:
- **Fase 1**: 4 tasks (10 dias)
- **Fase 2**: 4 tasks (13 dias)
- **Fase 3**: 4 tasks (14 dias)
- **Fase 4**: 4 tasks (15 dias)

### Próxima Task:
🎯 **Task 1: Estrutura Base de Tenants**