-- Script para adicionar validações de isolamento multi-tenant
-- Execute este script no SQL Editor do Supabase

-- =====================================================
-- 1. FUNÇÃO PARA VALIDAR ISOLAMENTO DE ORGANIZAÇÃO
-- =====================================================

CREATE OR REPLACE FUNCTION validate_organization_isolation()
RETURNS TRIGGER AS $$
DECLARE
    user_org_id UUID;
BEGIN
    -- Obter organization_id do usuário atual
    SELECT organization_id INTO user_org_id
    FROM profiles
    WHERE id = auth.uid();
    
    -- Se o usuário não tem organização, bloquear operação
    IF user_org_id IS NULL THEN
        RAISE EXCEPTION 'Usuário deve pertencer a uma organização para realizar esta operação';
    END IF;
    
    -- Para INSERT/UPDATE, garantir que organization_id corresponde ao do usuário
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        IF NEW.organization_id IS NULL THEN
            NEW.organization_id := user_org_id;
        ELSIF NEW.organization_id != user_org_id THEN
            RAISE EXCEPTION 'Não é possível criar/modificar dados de outra organização';
        END IF;
    END IF;
    
    -- Para DELETE, verificar se o registro pertence à organização do usuário
    IF TG_OP = 'DELETE' THEN
        IF OLD.organization_id != user_org_id THEN
            RAISE EXCEPTION 'Não é possível deletar dados de outra organização';
        END IF;
        RETURN OLD;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 2. FUNÇÃO PARA VERIFICAR INTEGRIDADE DO ISOLAMENTO
-- =====================================================

CREATE OR REPLACE FUNCTION check_tenant_isolation()
RETURNS TABLE(
    table_name TEXT,
    total_records BIGINT,
    records_without_org BIGINT,
    isolation_status TEXT
) AS $$
DECLARE
    table_record RECORD;
    query_text TEXT;
BEGIN
    -- Verificar todas as tabelas que têm organization_id
    FOR table_record IN
        SELECT t.table_name
        FROM information_schema.tables t
        JOIN information_schema.columns c ON t.table_name = c.table_name
        WHERE t.table_schema = 'public'
        AND c.column_name = 'organization_id'
        AND t.table_type = 'BASE TABLE'
    LOOP
        -- Construir query dinâmica
        query_text := format('
            SELECT 
                ''%s'' as table_name,
                COUNT(*) as total_records,
                COUNT(*) FILTER (WHERE organization_id IS NULL) as records_without_org,
                CASE 
                    WHEN COUNT(*) FILTER (WHERE organization_id IS NULL) = 0 THEN ''OK''
                    ELSE ''PROBLEMA: '' || COUNT(*) FILTER (WHERE organization_id IS NULL) || '' registros sem organização''
                END as isolation_status
            FROM %I',
            table_record.table_name,
            table_record.table_name
        );
        
        -- Executar query e retornar resultado
        RETURN QUERY EXECUTE query_text;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. APLICAR TRIGGERS DE VALIDAÇÃO EM TABELAS EXISTENTES
-- =====================================================

-- Aplicar em adversarios
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'adversarios') THEN
        DROP TRIGGER IF EXISTS trigger_validate_adversarios_isolation ON adversarios;
        CREATE TRIGGER trigger_validate_adversarios_isolation
            BEFORE INSERT OR UPDATE OR DELETE ON adversarios
            FOR EACH ROW
            EXECUTE FUNCTION validate_organization_isolation();
    END IF;
END $$;

-- Aplicar em clientes
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'clientes') THEN
        -- Adicionar organization_id se não existir
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'clientes' AND column_name = 'organization_id') THEN
            ALTER TABLE clientes ADD COLUMN organization_id UUID REFERENCES organizations(id);
            CREATE INDEX idx_clientes_organization_id ON clientes(organization_id);
        END IF;
        
        DROP TRIGGER IF EXISTS trigger_validate_clientes_isolation ON clientes;
        CREATE TRIGGER trigger_validate_clientes_isolation
            BEFORE INSERT OR UPDATE OR DELETE ON clientes
            FOR EACH ROW
            EXECUTE FUNCTION validate_organization_isolation();
    END IF;
END $$;

-- Aplicar em viagens
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'viagens') THEN
        -- Adicionar organization_id se não existir
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'viagens' AND column_name = 'organization_id') THEN
            ALTER TABLE viagens ADD COLUMN organization_id UUID REFERENCES organizations(id);
            CREATE INDEX idx_viagens_organization_id ON viagens(organization_id);
        END IF;
        
        DROP TRIGGER IF EXISTS trigger_validate_viagens_isolation ON viagens;
        CREATE TRIGGER trigger_validate_viagens_isolation
            BEFORE INSERT OR UPDATE OR DELETE ON viagens
            FOR EACH ROW
            EXECUTE FUNCTION validate_organization_isolation();
    END IF;
END $$;

-- Aplicar em ingressos
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ingressos') THEN
        -- Adicionar organization_id se não existir
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'ingressos' AND column_name = 'organization_id') THEN
            ALTER TABLE ingressos ADD COLUMN organization_id UUID REFERENCES organizations(id);
            CREATE INDEX idx_ingressos_organization_id ON ingressos(organization_id);
        END IF;
        
        DROP TRIGGER IF EXISTS trigger_validate_ingressos_isolation ON ingressos;
        CREATE TRIGGER trigger_validate_ingressos_isolation
            BEFORE INSERT OR UPDATE OR DELETE ON ingressos
            FOR EACH ROW
            EXECUTE FUNCTION validate_organization_isolation();
    END IF;
END $$;

-- =====================================================
-- 4. FUNÇÃO PARA MIGRAR DADOS EXISTENTES
-- =====================================================

CREATE OR REPLACE FUNCTION migrate_existing_data_to_organizations()
RETURNS TEXT AS $$
DECLARE
    default_org_id UUID;
    affected_rows INTEGER := 0;
    table_record RECORD;
    query_text TEXT;
BEGIN
    -- Obter ou criar organização padrão
    SELECT id INTO default_org_id
    FROM organizations
    WHERE slug = 'neto-viagens'
    LIMIT 1;
    
    IF default_org_id IS NULL THEN
        INSERT INTO organizations (name, slug)
        VALUES ('Neto Viagens', 'neto-viagens')
        RETURNING id INTO default_org_id;
    END IF;
    
    -- Migrar dados de todas as tabelas com organization_id
    FOR table_record IN
        SELECT t.table_name
        FROM information_schema.tables t
        JOIN information_schema.columns c ON t.table_name = c.table_name
        WHERE t.table_schema = 'public'
        AND c.column_name = 'organization_id'
        AND t.table_type = 'BASE TABLE'
        AND t.table_name != 'organizations'
        AND t.table_name != 'profiles'
    LOOP
        -- Atualizar registros sem organization_id
        query_text := format('
            UPDATE %I 
            SET organization_id = $1 
            WHERE organization_id IS NULL',
            table_record.table_name
        );
        
        EXECUTE query_text USING default_org_id;
        GET DIAGNOSTICS affected_rows = ROW_COUNT;
        
        IF affected_rows > 0 THEN
            RAISE NOTICE 'Migrados % registros na tabela %', affected_rows, table_record.table_name;
        END IF;
    END LOOP;
    
    -- Migrar usuários sem organização
    UPDATE profiles 
    SET organization_id = default_org_id 
    WHERE organization_id IS NULL;
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    
    IF affected_rows > 0 THEN
        RAISE NOTICE 'Migrados % usuários para organização padrão', affected_rows;
    END IF;
    
    RETURN 'Migração concluída com sucesso!';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 5. EXECUTAR VERIFICAÇÕES E MIGRAÇÕES
-- =====================================================

-- Verificar estado atual do isolamento
SELECT * FROM check_tenant_isolation();

-- Executar migração de dados existentes
SELECT migrate_existing_data_to_organizations();

-- Verificar novamente após migração
SELECT * FROM check_tenant_isolation();

-- =====================================================
-- 6. CRIAR FUNÇÃO DE MONITORAMENTO
-- =====================================================

CREATE OR REPLACE FUNCTION monitor_tenant_isolation()
RETURNS TABLE(
    check_name TEXT,
    status TEXT,
    details TEXT
) AS $$
BEGIN
    -- Verificar se todos os usuários têm organização
    RETURN QUERY
    SELECT 
        'Usuários sem organização'::TEXT,
        CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'PROBLEMA' END::TEXT,
        CASE WHEN COUNT(*) = 0 
             THEN 'Todos os usuários têm organização'
             ELSE COUNT(*)::TEXT || ' usuários sem organização'
        END::TEXT
    FROM profiles
    WHERE organization_id IS NULL;
    
    -- Verificar se todas as organizações têm pelo menos um usuário
    RETURN QUERY
    SELECT 
        'Organizações órfãs'::TEXT,
        CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'AVISO' END::TEXT,
        CASE WHEN COUNT(*) = 0 
             THEN 'Todas as organizações têm usuários'
             ELSE COUNT(*)::TEXT || ' organizações sem usuários'
        END::TEXT
    FROM organizations o
    LEFT JOIN profiles p ON p.organization_id = o.id
    WHERE p.id IS NULL;
    
    -- Verificar políticas RLS ativas
    RETURN QUERY
    SELECT 
        'Políticas RLS'::TEXT,
        'INFO'::TEXT,
        COUNT(*)::TEXT || ' políticas RLS ativas'
    FROM pg_policies
    WHERE schemaname = 'public';
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Executar monitoramento
SELECT * FROM monitor_tenant_isolation();

-- =====================================================
-- INSTRUÇÕES FINAIS
-- =====================================================

/*
VALIDAÇÕES IMPLEMENTADAS:

1. ✅ Trigger de validação em tabelas principais
2. ✅ Função de verificação de integridade
3. ✅ Migração automática de dados existentes
4. ✅ Monitoramento contínuo do isolamento
5. ✅ Prevenção de operações cross-tenant

PRÓXIMOS PASSOS:
1. Execute os scripts SQL criados no Supabase
2. Teste a criação de novos registros
3. Verifique se o isolamento está funcionando
4. Execute testes de isolamento multi-tenant
*/

SELECT 'Validações de isolamento implementadas com sucesso!' as status;