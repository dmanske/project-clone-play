-- Script para atualizar tipos do Supabase e corrigir isolamento multi-tenant
-- Execute este script no SQL Editor do Supabase

-- =====================================================
-- 1. VERIFICAR E CRIAR TABELA ORGANIZATIONS (se não existir)
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

-- =====================================================
-- 2. ADICIONAR ORGANIZATION_ID À TABELA PROFILES
-- =====================================================

-- Adicionar coluna organization_id se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'organization_id') THEN
        ALTER TABLE profiles ADD COLUMN organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL;
    END IF;
END $$;

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_organizations_slug ON organizations(slug);
CREATE INDEX IF NOT EXISTS idx_organizations_active ON organizations(active);
CREATE INDEX IF NOT EXISTS idx_profiles_organization_id ON profiles(organization_id);

-- =====================================================
-- 3. CORRIGIR POLÍTICAS RLS PARA ISOLAMENTO MULTI-TENANT
-- =====================================================

-- Habilitar RLS nas tabelas
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Políticas para organizations
DROP POLICY IF EXISTS "Users can view their organization" ON organizations;
CREATE POLICY "Users can view their organization" ON organizations
    FOR SELECT USING (
        id = (SELECT organization_id FROM profiles WHERE id = auth.uid())
    );

DROP POLICY IF EXISTS "Users can update their organization" ON organizations;
CREATE POLICY "Users can update their organization" ON organizations
    FOR UPDATE USING (
        id = (SELECT organization_id FROM profiles WHERE id = auth.uid())
    );

-- Políticas para profiles
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT USING (id = auth.uid());

DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (id = auth.uid());

-- =====================================================
-- 4. FUNÇÃO PARA CRIAR ORGANIZAÇÃO AUTOMATICAMENTE
-- =====================================================

CREATE OR REPLACE FUNCTION create_organization_for_new_user()
RETURNS TRIGGER AS $$
DECLARE
    new_org_id UUID;
BEGIN
    -- Verificar se o usuário já tem uma organização
    IF NEW.organization_id IS NULL THEN
        -- Criar nova organização
        INSERT INTO organizations (name, slug)
        VALUES (
            COALESCE(NEW.nome, 'Minha Organização'),
            LOWER(REPLACE(COALESCE(NEW.nome, 'org-' || NEW.id::text), ' ', '-'))
        )
        RETURNING id INTO new_org_id;
        
        -- Atualizar o perfil com o organization_id
        NEW.organization_id = new_org_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 5. TRIGGER PARA CRIAÇÃO AUTOMÁTICA DE ORGANIZAÇÃO
-- =====================================================

DROP TRIGGER IF EXISTS trigger_create_organization_for_new_user ON profiles;
CREATE TRIGGER trigger_create_organization_for_new_user
    BEFORE INSERT ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION create_organization_for_new_user();

-- =====================================================
-- 6. CORRIGIR USUÁRIOS EXISTENTES SEM ORGANIZAÇÃO
-- =====================================================

-- Criar organizações para usuários que não têm
DO $$
DECLARE
    user_record RECORD;
    new_org_id UUID;
BEGIN
    FOR user_record IN 
        SELECT id, full_name FROM profiles WHERE organization_id IS NULL
    LOOP
        -- Criar organização para o usuário
        INSERT INTO organizations (name, slug)
        VALUES (
            COALESCE(user_record.full_name, 'Organização ' || user_record.id::text),
            'org-' || user_record.id::text
        )
        RETURNING id INTO new_org_id;
        
        -- Atualizar o perfil
        UPDATE profiles 
        SET organization_id = new_org_id 
        WHERE id = user_record.id;
        
        RAISE NOTICE 'Criada organização % para usuário %', new_org_id, user_record.id;
    END LOOP;
END $$;

-- =====================================================
-- 7. VERIFICAR ISOLAMENTO
-- =====================================================

-- Verificar se todos os usuários têm organização
SELECT 
    COUNT(*) as total_usuarios,
    COUNT(organization_id) as usuarios_com_organizacao,
    COUNT(*) - COUNT(organization_id) as usuarios_sem_organizacao
FROM profiles;

-- Verificar organizações criadas
SELECT 
    o.id,
    o.name,
    o.slug,
    COUNT(p.id) as total_usuarios
FROM organizations o
LEFT JOIN profiles p ON p.organization_id = o.id
GROUP BY o.id, o.name, o.slug
ORDER BY o.created_at;

-- =====================================================
-- 8. ATUALIZAR POLÍTICAS DE OUTRAS TABELAS
-- =====================================================

-- Exemplo para tabela adversarios (ajuste conforme necessário)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'adversarios') THEN
        -- Habilitar RLS
        ALTER TABLE adversarios ENABLE ROW LEVEL SECURITY;
        
        -- Política de isolamento
        DROP POLICY IF EXISTS "Users can access adversarios from their organization" ON adversarios;
        CREATE POLICY "Users can access adversarios from their organization" ON adversarios
            FOR ALL USING (
                organization_id = (SELECT organization_id FROM profiles WHERE id = auth.uid())
            );
    END IF;
END $$;

-- =====================================================
-- INSTRUÇÕES FINAIS
-- =====================================================

/*
APÓS EXECUTAR ESTE SCRIPT:

1. Regenere os tipos do Supabase executando:
   npx supabase gen types typescript --project-id YOUR_PROJECT_ID > src/integrations/supabase/types.ts

2. Teste o isolamento:
   - Crie um novo usuário
   - Verifique se uma organização é criada automaticamente
   - Teste se os dados estão isolados por organização

3. Aplique políticas similares a outras tabelas que precisam de isolamento multi-tenant
*/

SELECT 'Script executado com sucesso! Verifique os resultados acima.' as status;