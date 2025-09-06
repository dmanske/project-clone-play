-- Script para criar a tabela organizations e configurar o sistema multi-tenant
-- Execute este script PRIMEIRO no SQL Editor do Supabase

-- =====================================================
-- 1. CRIAR TABELA ORGANIZATIONS
-- =====================================================

CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE,
    logo_url TEXT,
    website TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50) DEFAULT 'Brasil',
    zip_code VARCHAR(20),
    
    -- Configurações específicas
    time_casa_padrao VARCHAR(100),
    cor_primaria VARCHAR(7) DEFAULT '#1f2937',
    cor_secundaria VARCHAR(7) DEFAULT '#3b82f6',
    
    -- Status
    active BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_organizations_slug ON organizations(slug);
CREATE INDEX IF NOT EXISTS idx_organizations_active ON organizations(active);

-- =====================================================
-- 2. CRIAR ORGANIZAÇÃO PADRÃO
-- =====================================================

-- Inserir uma organização padrão para começar
INSERT INTO organizations (name, slug, time_casa_padrao)
VALUES (
    'Neto Viagens',
    'neto-viagens',
    'Flamengo'
)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- 3. ATUALIZAR TABELA PROFILES
-- =====================================================

-- Adicionar coluna organization_id se não existir
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL;

-- Criar índice
CREATE INDEX IF NOT EXISTS idx_profiles_organization_id ON profiles(organization_id);

-- =====================================================
-- 4. ASSOCIAR USUÁRIOS EXISTENTES À ORGANIZAÇÃO PADRÃO
-- =====================================================

-- Atualizar todos os usuários existentes para usar a organização padrão
UPDATE profiles 
SET organization_id = (
    SELECT id FROM organizations 
    WHERE slug = 'neto-viagens'
    LIMIT 1
)
WHERE organization_id IS NULL;

-- =====================================================
-- 5. HABILITAR RLS NA TABELA ORGANIZATIONS
-- =====================================================

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- Política para visualização: usuários podem ver sua própria organização
CREATE POLICY "Users can view their organization" ON organizations
FOR SELECT USING (
    id = (
        SELECT organization_id 
        FROM profiles 
        WHERE id = auth.uid()
    )
);

-- Política para administração: apenas admins podem gerenciar
CREATE POLICY "Admins can manage organizations" ON organizations
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() 
        AND organization_id = organizations.id 
        AND role IN ('admin', 'owner')
    )
);

-- =====================================================
-- 6. VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar se a organização foi criada
SELECT 
    'ORGANIZAÇÃO CRIADA' as status,
    id,
    name,
    slug,
    created_at
FROM organizations;

-- Verificar se os usuários foram associados
SELECT 
    'USUÁRIOS ASSOCIADOS' as status,
    COUNT(*) as total_usuarios,
    organization_id
FROM profiles 
GROUP BY organization_id;

-- Verificar o usuário atual
SELECT 
    'USUÁRIO ATUAL' as status,
    p.id,
    p.email,
    p.organization_id,
    o.name as organization_name
FROM profiles p
LEFT JOIN organizations o ON p.organization_id = o.id
WHERE p.id = auth.uid();

-- =====================================================
-- PRÓXIMOS PASSOS:
-- =====================================================
/*
1. Execute este script no SQL Editor do Supabase
2. Verifique se a organização foi criada corretamente
3. Confirme que os usuários foram associados à organização
4. Execute o script inserir_adversarios_multi_tenant.sql novamente
5. Teste a aplicação para ver se os adversários aparecem

Este script resolve:
✅ Cria a tabela organizations
✅ Cria uma organização padrão
✅ Adiciona organization_id aos perfis existentes
✅ Configura políticas RLS básicas
✅ Associa todos os usuários existentes à organização padrão
*/