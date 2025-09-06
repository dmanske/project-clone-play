# Análise das Tabelas - Projeto Multi-Tenant

## Tabelas do Projeto Original (que precisam de organization_id)

Estas são as tabelas principais do seu projeto original que foram adaptadas para multi-tenant:

### ✅ TABELAS PRINCIPAIS (ESSENCIAIS)
1. **clientes** - Cadastro de clientes
2. **viagens** - Viagens organizadas
3. **viagem_passageiros** - Passageiros por viagem
4. **onibus** - Frota de ônibus
5. **ingressos** - Ingressos dos jogos
6. **empresa_config** - Configurações da empresa

### ✅ TABELAS FINANCEIRAS (ESSENCIAIS)
7. **creditos_clientes** - Créditos dos clientes
8. **viagem_receitas** - Receitas das viagens
9. **viagem_despesas** - Despesas das viagens
10. **viagem_cobranca_historico** - Histórico de cobranças
11. **viagem_orcamento** - Orçamentos das viagens
12. **viagem_passageiros_parcelas** - Parcelamento dos passageiros

## Tabelas Novas do Multi-Tenant

Estas são tabelas que criamos especificamente para o sistema multi-tenant:

### ✅ TABELAS MULTI-TENANT (NECESSÁRIAS)
1. **organizations** - Organizações/empresas
2. **profiles** - Perfis dos usuários
3. **super_admin_users** - Super administradores
4. **user_invitations** - Convites de usuários
5. **user_permissions** - Permissões dos usuários
6. **organization_subscriptions** - Assinaturas das organizações

## Tabelas que Podem Estar Faltando

Baseado no arquivo `database_schema_output.txt`, estas tabelas podem existir no projeto original:

### ❓ TABELAS A VERIFICAR
- **adversarios** - Times adversários
- **categorias_financeiras** - Categorias para finanças
- **categorias_produtos** - Categorias de produtos
- **cliente_creditos** - Histórico de créditos
- **contas_pagar** - Contas a pagar
- **credito_historico** - Histórico de créditos
- **credito_logs** - Logs de créditos
- **despesas** - Despesas gerais
- **estadios** - Cadastro de estádios
- **passeios** - Passeios/atividades
- **passageiro_passeios** - Relação passageiro-passeio
- **setores_maracana** - Setores do Maracanã
- **viagem_ingressos** - Ingressos por viagem
- **viagem_parcelamento_config** - Configuração de parcelamento
- **viagem_passeios** - Passeios por viagem

## Recomendações

### 1. Execute os SQLs que criei:
```bash
# Para verificar estrutura da empresa_config
psql -d seu_banco -f check_empresa_config_original.sql

# Para comparar todas as tabelas
psql -d seu_banco -f compare_tables_structure.sql
```

### 2. Decisões sobre tabelas:
- **MANTER**: Todas as tabelas que têm dados importantes
- **REMOVER**: Tabelas vazias ou não utilizadas
- **ADAPTAR**: Adicionar organization_id nas que faltam

### 3. Próximos passos:
1. Verificar quais tabelas realmente existem no seu projeto
2. Identificar quais têm dados importantes
3. Criar migrações para adicionar organization_id nas que faltam
4. Configurar políticas RLS para todas

## Estrutura da Tabela `empresa_config`

### Projeto Original
Baseado no arquivo `database/create_empresa_table.sql` e dados fornecidos:

```sql
CREATE TABLE empresa_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    cnpj VARCHAR(18),
    email VARCHAR(255),
    telefone VARCHAR(20),
    whatsapp VARCHAR(20), -- ✅ COLUNA JÁ EXISTE
    endereco TEXT,
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    logo_url TEXT,
    logo_bucket_path TEXT,
    site VARCHAR(255),
    instagram VARCHAR(100),
    facebook VARCHAR(100),
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Dados de Exemplo do Projeto Original

**⚠️ IMPORTANTE:** Estes dados são apenas um exemplo do projeto original. No sistema multi-tenant, cada organização/cliente terá seus próprios dados de empresa que poderão ser editados através da interface de configurações.

**Exemplo de registro (Neto Tours Viagens):**
- **ID:** `1903ed1a-21c5-42d8-aad4-d24e84ea9744`
- **Nome:** Neto Tours Viagens
- **Nome Fantasia:** Neto Tours Viagens
- **CNPJ:** null
- **Email:** contato@suaempresa.com
- **Telefone:** (11) 99999-9999
- **WhatsApp:** 11999999999
- **Endereço:** Rua das Viagens, 123
- **Cidade:** Blumenau
- **Estado:** SC
- **CEP:** 89042030
- **Logo URL:** https://uroukakmvanyeqxicuzw.supabase.co/storage/v1/object/public/logos/empresa/logo-empresa-1753323935506.png
- **Logo Bucket Path:** empresa/logo-empresa-1753323935506.png
- **Site:** www.netotours.com.br
- **Instagram:** @netotours
- **Facebook:** null
- **Descrição:** Realizando sonhos, criando histórias.
- **Ativo:** true
- **Created At:** 2025-07-23 22:54:14.87954
- **Updated At:** 2025-07-23 23:25:36.384139

### ✅ Funcionalidades JÁ IMPLEMENTADAS no Multi-Tenant

O sistema já possui uma estrutura completa para configurações organizacionais:

1. **✅ Interface de Configurações Avançada**
   - `OrganizationSettingsForm.tsx` - Formulário completo para configurações
   - `OrganizationConfig.tsx` - Interface para dados básicos da organização
   - `EmpresaConfig.tsx` - Componente legado que pode ser adaptado
   - Upload de logo com preview e validações
   - Máscaras e validações para CNPJ, telefone, email

2. **✅ Tabela `organization_settings` Completa**
   - Branding (logos, cores, favicon)
   - Informações da empresa (nome, CNPJ, endereço, contatos)
   - Configurações regionais (timezone, moeda, idioma)
   - Configurações de pagamento e notificações
   - Configurações de relatórios personalizados

3. **✅ Sistema Multi-Tenant Robusto**
   - Hook `useOrganizationSettings` para gerenciar configurações
   - Isolamento por `organization_id`
   - Políticas RLS implementadas
   - Upload de arquivos para storage do Supabase

4. **✅ Permissões e Segurança**
   - Sistema de roles (admin, user, viewer)
   - Permissões granulares por módulo
   - Controle de acesso às configurações

### 🔄 Migração Necessária

Para integrar completamente, é necessário:

1. **Migrar dados de `empresa_config` para `organization_settings`**
2. **Adaptar componentes legados para usar a nova estrutura**
3. **Garantir que cada organização tenha suas configurações isoladas**

### Versão Multi-Tenant
Para o sistema multi-tenant, adicionar:

```sql
ALTER TABLE empresa_config 
ADD COLUMN organization_id UUID REFERENCES organizations(id);
```

**Resposta à sua dúvida**: A coluna `whatsapp` JÁ EXISTE na tabela empresa_config original!