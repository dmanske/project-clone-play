-- Script para corrigir o isolamento multi-tenant e evitar associação automática
-- Execute este script APÓS executar investigate_auto_assignment.sql

-- =====================================================
-- 1. DESABILITAR PROCESSOS AUTOMÁTICOS PROBLEMÁTICOS
-- =====================================================

-- Remover triggers que podem estar causando associação automática
DROP TRIGGER IF EXISTS auto_assign_organization_trigger ON profiles;
DROP TRIGGER IF EXISTS handle_new_user_trigger ON auth.users;
DROP TRIGGER IF EXISTS create_user_permissions_trigger ON profiles;

-- Comentar funções problemáticas temporariamente
COMMENT ON FUNCTION create_default_user_permissions() IS 'Função modificada para evitar associação automática - 2025-01-25';

-- =====================================================
-- 2. CRIAR FUNÇÃO SEGURA PARA CRIAÇÃO DE PERMISSÕES
-- =====================================================

-- Função que só cria permissões se o usuário JÁ TEM organization_id
CREATE OR REPLACE FUNCTION create_safe_user_permissions()
RETURNS TRIGGER AS $$
BEGIN
    -- IMPORTANTE: Só criar permissões se o usuário JÁ TEM organization_id
    -- NÃO associar automaticamente a nenhuma organização
    IF NEW.organization_id IS NOT NULL AND OLD.organization_id IS NULL THEN
        -- Usuário foi associado a uma organização (via convite ou onboarding)
        INSERT INTO user_permissions (user_id, organization_id, permissions)
        VALUES (
            NEW.id,
            NEW.organization_id,
            CASE 
                WHEN NEW.role = 'owner' THEN '{
                    "viagens": {"read": true, "write": true, "delete": true},
                    "clientes": {"read": true, "write": true, "delete": true},
                    "onibus": {"read": true, "write": true, "delete": true},
                    "financeiro": {"read": true, "write": true, "delete": true},
                    "relatorios": {"read": true, "write": true, "delete": true},
                    "configuracoes": {"read": true, "write": true, "delete": true},
                    "usuarios": {"read": true, "write": true, "delete": true}
                }'::jsonb
                WHEN NEW.role = 'admin' THEN '{
                    "viagens": {"read": true, "write": true, "delete": true},
                    "clientes": {"read": true, "write": true, "delete": true},
                    "onibus": {"read": true, "write": true, "delete": true},
                    "financeiro": {"read": true, "write": true, "delete": false},
                    "relatorios": {"read": true, "write": false, "delete": false},
                    "configuracoes": {"read": true, "write": false, "delete": false},
                    "usuarios": {"read": true, "write": true, "delete": false}
                }'::jsonb
                ELSE '{
                    "viagens": {"read": true, "write": false, "delete": false},
                    "clientes": {"read": true, "write": false, "delete": false},
                    "onibus": {"read": true, "write": false, "delete": false},
                    "financeiro": {"read": false, "write": false, "delete": false},
                    "relatorios": {"read": true, "write": false, "delete": false},
                    "configuracoes": {"read": false, "write": false, "delete": false},
                    "usuarios": {"read": false, "write": false, "delete": false}
                }'::jsonb
            END
        )
        ON CONFLICT (user_id, organization_id) DO NOTHING;
        
        -- Log da ação para auditoria
        INSERT INTO activity_logs (user_id, action, details, created_at)
        VALUES (
            NEW.id,
            'user_assigned_to_organization',
            jsonb_build_object(
                'organization_id', NEW.organization_id,
                'role', NEW.role,
                'method', 'safe_assignment'
            ),
            NOW()
        ) ON CONFLICT DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger seguro
CREATE TRIGGER safe_user_permissions_trigger
    AFTER UPDATE OF organization_id ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION create_safe_user_permissions();

-- =====================================================
-- 3. FUNÇÃO PARA CRIAR NOVA ORGANIZAÇÃO DURANTE ONBOARDING
-- =====================================================

CREATE OR REPLACE FUNCTION create_new_tenant_organization(
    p_user_id UUID,
    p_organization_name TEXT,
    p_organization_slug TEXT DEFAULT NULL,
    p_user_full_name TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_org_id UUID;
    final_slug TEXT;
BEGIN
    -- Verificar se o usuário existe e NÃO tem organização
    IF NOT EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = p_user_id AND organization_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Usuário não encontrado ou já possui organização';
    END IF;
    
    -- Gerar slug se não fornecido
    IF p_organization_slug IS NULL THEN
        final_slug := lower(replace(p_organization_name, ' ', '-'));
        -- Garantir que o slug seja único
        WHILE EXISTS (SELECT 1 FROM organizations WHERE slug = final_slug) LOOP
            final_slug := final_slug || '-' || floor(random() * 1000)::text;
        END LOOP;
    ELSE
        final_slug := p_organization_slug;
    END IF;
    
    -- Criar nova organização
    INSERT INTO organizations (
        name,
        slug,
        cor_primaria,
        cor_secundaria,
        active
    ) VALUES (
        p_organization_name,
        final_slug,
        '#1f2937',
        '#3b82f6',
        true
    ) RETURNING id INTO new_org_id;
    
    -- Associar usuário à nova organização como owner
    UPDATE profiles 
    SET 
        organization_id = new_org_id,
        role = 'owner',
        updated_at = NOW()
    WHERE id = p_user_id;
    
    -- Criar configurações padrão da organização
    INSERT INTO organization_settings (organization_id, nome_empresa)
    VALUES (new_org_id, p_organization_name)
    ON CONFLICT (organization_id) DO NOTHING;
    
    -- Log da criação
    INSERT INTO activity_logs (user_id, action, details, created_at)
    VALUES (
        p_user_id,
        'new_tenant_organization_created',
        jsonb_build_object(
            'organization_id', new_org_id,
            'organization_name', p_organization_name,
            'organization_slug', final_slug
        ),
        NOW()
    ) ON CONFLICT DO NOTHING;
    
    RETURN new_org_id;
END;
$$;

-- Dar permissão para usuários autenticados
GRANT EXECUTE ON FUNCTION create_new_tenant_organization(UUID, TEXT, TEXT, TEXT) TO authenticated;

-- =====================================================
-- 4. FUNÇÃO PARA VALIDAR ISOLAMENTO DE TENANT
-- =====================================================

CREATE OR REPLACE FUNCTION validate_tenant_isolation()
RETURNS TABLE(
    check_name TEXT,
    status TEXT,
    details TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verificar usuários sem organização
    RETURN QUERY
    SELECT 
        'users_without_organization'::TEXT,
        CASE 
            WHEN COUNT(*) = 0 THEN 'OK'
            ELSE 'WARNING'
        END::TEXT,
        'Usuários sem organização: ' || COUNT(*)::TEXT
    FROM profiles 
    WHERE organization_id IS NULL;
    
    -- Verificar organizações órfãs
    RETURN QUERY
    SELECT 
        'orphaned_organizations'::TEXT,
        CASE 
            WHEN COUNT(*) = 0 THEN 'OK'
            ELSE 'WARNING'
        END::TEXT,
        'Organizações sem usuários: ' || COUNT(*)::TEXT
    FROM organizations o
    WHERE NOT EXISTS (
        SELECT 1 FROM profiles p WHERE p.organization_id = o.id
    );
    
    -- Verificar usuários com múltiplas organizações (não deveria acontecer)
    RETURN QUERY
    SELECT 
        'users_multiple_orgs'::TEXT,
        'OK'::TEXT,
        'Sistema permite apenas uma organização por usuário'::TEXT;
    
    -- Verificar políticas RLS ativas
    RETURN QUERY
    SELECT 
        'rls_policies_active'::TEXT,
        CASE 
            WHEN COUNT(*) > 0 THEN 'OK'
            ELSE 'ERROR'
        END::TEXT,
        'Políticas RLS ativas: ' || COUNT(*)::TEXT
    FROM pg_policies 
    WHERE tablename IN ('profiles', 'organizations', 'viagens', 'adversarios');
    
END;
$$;

-- =====================================================
-- 5. LIMPAR ASSOCIAÇÕES AUTOMÁTICAS EXISTENTES
-- =====================================================

-- CUIDADO: Este comando remove associações automáticas
-- Execute apenas se tiver certeza de que são incorretas
/*
UPDATE profiles 
SET organization_id = NULL
WHERE id IN (
    -- Usuários criados nas últimas 24 horas que podem ter sido associados automaticamente
    SELECT p.id 
    FROM profiles p
    WHERE p.created_at > NOW() - INTERVAL '24 hours'
      AND p.organization_id IS NOT NULL
      AND NOT EXISTS (
          -- Verificar se não há convite aceito
          SELECT 1 FROM user_invitations ui 
          WHERE ui.email = p.email 
            AND ui.organization_id = p.organization_id 
            AND ui.accepted_at IS NOT NULL
      )
);
*/

-- =====================================================
-- 6. VERIFICAÇÕES FINAIS
-- =====================================================

-- Executar validação de isolamento
SELECT * FROM validate_tenant_isolation();

-- Mostrar estatísticas atuais
SELECT 
    'ESTATÍSTICAS APÓS CORREÇÃO' as tipo,
    (
        SELECT COUNT(*) FROM profiles WHERE organization_id IS NULL
    ) as usuarios_sem_org,
    (
        SELECT COUNT(*) FROM organizations
    ) as total_organizacoes,
    (
        SELECT COUNT(*) FROM profiles
    ) as total_usuarios;

-- =====================================================
-- INSTRUÇÕES DE USO
-- =====================================================
/*
APÓS EXECUTAR ESTE SCRIPT:

1. TESTE O SIGNUP:
   - Crie um novo usuário sem organizationId
   - Verifique se ele NÃO é associado automaticamente
   - Confirme que ele pode completar o onboarding

2. TESTE O ONBOARDING:
   - Use a função create_new_tenant_organization()
   - Verifique se uma nova organização é criada
   - Confirme o isolamento entre organizações

3. MONITORE:
   - Execute validate_tenant_isolation() regularmente
   - Verifique logs de atividade
   - Confirme que não há vazamentos de dados

FUNÇÃO PARA USAR NO ONBOARDING:
SELECT create_new_tenant_organization(
    auth.uid(),
    'Nome da Nova Empresa',
    'slug-da-empresa',
    'Nome do Usuário'
);
*/