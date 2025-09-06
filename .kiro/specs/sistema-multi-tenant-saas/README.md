# Sistema Multi-Tenant SaaS - Caravanas

## 🎯 Objetivo
Transformar o sistema atual em um SaaS multi-tenant para empresas de caravanas/excursões, permitindo que diferentes organizações usem o sistema com isolamento completo de dados.

## 📋 Requisitos Funcionais

### 1. **Estrutura Multi-Tenant**
- ✅ Isolamento completo de dados por organização
- ✅ Sistema de organizações já existe (tabela `organizations`)
- 🔄 Controle de acesso baseado em `organization_id`
- 🔄 Super Admin para gerenciar todos os tenants

### 2. **Sistema de Pagamentos & Controle**
- 🆕 Integração com Stripe
- 🆕 Período trial de 7 dias
- 🆕 Controle de status: TRIAL, ACTIVE, SUSPENDED, BLOCKED
- 🆕 Bloqueio automático por falta de pagamento

### 3. **Gestão de Usuários**
- ✅ Admin da organização (já existe)
- 🔄 Usuários normais com permissões configuráveis
- 🆕 Sistema de convites por email
- 🆕 Controle de permissões granular

### 4. **Configurações por Tenant**
- 🆕 Logo da empresa
- 🆕 Logo do time principal
- 🆕 Cores/tema personalizado
- 🆕 Passeios padrão inclusos
- 🆕 Informações para relatórios
- 🆕 Dados de contato

### 5. **Super Admin Dashboard**
- 🆕 Lista de todas as organizações
- 🆕 Controle de status/bloqueios
- 🆕 Métricas de uso
- 🆕 Acesso aos dados dos clientes (suporte)

## 🏗️ Arquitetura Técnica

### Estrutura de Dados
```
Super Admin (Você)
├── Acesso global a todos os tenants
├── Controle de pagamentos/status
└── Métricas e suporte

Organization Admin
├── Gerencia a organização
├── Convida usuários
├── Configura sistema
└── Dados isolados

Organization Users
├── Acesso conforme permissões
├── Não vê outras organizações
└── Funcionalidades limitadas
```

### Status de Organizações
- **TRIAL**: 7 dias grátis
- **ACTIVE**: Pagamento em dia
- **SUSPENDED**: Pagamento atrasado
- **BLOCKED**: Bloqueado pelo super admin

## 📊 Estrutura do Banco de Dados

### Tabelas Existentes (a serem adaptadas)
- ✅ `organizations` - Já existe
- ✅ `profiles` - Já existe com `organization_id`
- 🔄 Todas as tabelas principais precisam de filtros por `organization_id`

### Novas Tabelas Necessárias
- 🆕 `organization_subscriptions` - Controle de pagamentos
- 🆕 `organization_settings` - Configurações personalizáveis
- 🆕 `user_invitations` - Sistema de convites
- 🆕 `user_permissions` - Permissões granulares
- 🆕 `super_admin_users` - Super administradores

## 🚀 Plano de Implementação

### **FASE 1: Fundação Multi-Tenant** (Tasks 1-4)
1. **Estrutura Base de Tenants**
2. **Autenticação Multi-Tenant**
3. **Super Admin Dashboard**
4. **Sistema de Permissões**

### **FASE 2: Migração Core** (Tasks 5-8)
5. **Hooks Multi-Tenant**
6. **Páginas Principais**
7. **Sistema de Configurações**
8. **Isolamento de Dados**

### **FASE 3: UX & Onboarding** (Tasks 9-12)
9. **Onboarding de Novos Tenants**
10. **Branding Dinâmico**
11. **Gestão de Usuários**
12. **Interface de Configurações**

### **FASE 4: Controle & Monetização** (Tasks 13-16)
13. **Sistema de Pagamentos Stripe**
14. **Controle de Status/Bloqueios**
15. **Métricas & Analytics**
16. **Testes & Refinamentos**

## 🔧 Tecnologias

### Frontend
- ✅ React + TypeScript (mantido)
- ✅ shadcn/ui + Tailwind (mantido)
- 🆕 Context para tenant ativo
- 🆕 Middleware de proteção

### Backend
- ✅ Supabase (mantido)
- 🔄 RLS policies adaptadas
- 🆕 Functions para controle de acesso
- 🆕 Webhooks do Stripe

### Pagamentos
- 🆕 Stripe para cobrança
- 🆕 Webhooks para status
- 🆕 Controle automático de bloqueios

## 📈 Benefícios Esperados

1. **Escalabilidade**: Sistema preparado para múltiplos clientes
2. **Isolamento**: Dados completamente separados
3. **Monetização**: Receita recorrente via SaaS
4. **Flexibilidade**: Configurações por tenant
5. **Controle**: Dashboard super admin completo

## 🎯 Próximos Passos

1. ✅ Criar especificação detalhada
2. 🔄 Implementar Task 1: Estrutura Base
3. 🔄 Configurar novas tabelas no Supabase
4. 🔄 Adaptar AuthContext para multi-tenant
5. 🔄 Criar Super Admin Dashboard

---

**Status**: 🚀 Iniciando implementação
**Prioridade**: Alta
**Estimativa**: 4-6 semanas