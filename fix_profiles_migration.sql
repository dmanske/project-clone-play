-- Script corrigido para migração de profiles com verificações
-- Execute este script APÓS executar as seções 1 e 2 do update_supabase_types_and_fix_isolation.sql

-- =====================================================
-- VERIFICAR E CORRIGIR ESTRUTURA ANTES DA MIGRAÇÃO
-- =====================================================

-- 1. Verificar se organizations existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'organizations') THEN
        RAISE EXCEPTION 'Tabela organizations não existe. Execute primeiro as seções 1 e 2 do script principal.';
    END IF;
END $$;

-- 2. Verificar se profiles.organization_id existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'organization_id') THEN
        RAISE EXCEPTION 'Coluna organization_id não existe na tabela profiles. Execute primeiro a seção 2 do script principal.';
    END IF;
END $$;

-- =====================================================
-- MIGRAÇÃO DE DADOS - CRIAR ORGANIZAÇÕES PARA USUÁRIOS SEM ORGANIZAÇÃO
-- =====================================================

DO $$
DECLARE
    user_record RECORD;
    new_org_id UUID;
    users_count INTEGER;
BEGIN
    -- Contar usuários sem organização
    SELECT COUNT(*) INTO users_count
    FROM profiles 
    WHERE organization_id IS NULL;
    
    RAISE NOTICE 'Encontrados % usuários sem organização', users_count;
    
    IF users_count > 0 THEN
        FOR user_record IN 
            SELECT id, full_name FROM profiles WHERE organization_id IS NULL
        LOOP
            -- Criar organização para o usuário
            INSERT INTO organizations (name, slug, active)
            VALUES (
                COALESCE(user_record.full_name, 'Organização ' || user_record.id::text),
                'org-' || user_record.id::text,
                true
            )
            RETURNING id INTO new_org_id;
            
            -- Associar usuário à nova organização
            UPDATE profiles 
            SET organization_id = new_org_id 
            WHERE id = user_record.id;
            
            RAISE NOTICE 'Criada organização % para usuário %', new_org_id, user_record.id;
        END LOOP;
        
        RAISE NOTICE 'Migração concluída. % organizações criadas.', users_count;
    ELSE
        RAISE NOTICE 'Nenhum usuário sem organização encontrado.';
    END IF;
END $$;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se todos os usuários têm organização
SELECT 
    COUNT(*) as total_users,
    COUNT(organization_id) as users_with_org,
    COUNT(*) - COUNT(organization_id) as users_without_org
FROM profiles;

-- Mostrar organizações criadas
SELECT 
    o.id,
    o.name,
    o.slug,
    COUNT(p.id) as user_count
FROM organizations o
LEFT JOIN profiles p ON p.organization_id = o.id
GROUP BY o.id, o.name, o.slug
ORDER BY o.created_at DESC;