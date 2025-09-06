-- Migração para criar permissões padrão para todos os usuários existentes
-- Esta migração resolve o problema de usuários sem permissões na tabela user_permissions

-- Inserir permissões padrão para todos os usuários que não possuem permissões
INSERT INTO user_permissions (user_id, organization_id, permissions)
SELECT 
    p.id as user_id,
    p.organization_id,
    '{
        "dashboard": {"read": true},
        "viagens": {"read": true, "create": true, "update": true, "delete": false},
        "clientes": {"read": true, "create": true, "update": true, "delete": false},
        "onibus": {"read": true, "create": true, "update": true, "delete": false},
        "financeiro": {"read": true, "create": false, "update": false, "delete": false},
        "relatorios": {"read": true, "create": false, "update": false, "delete": false},
        "configuracoes": {"read": false, "create": false, "update": false, "delete": false},
        "usuarios": {"read": false, "create": false, "update": false, "delete": false}
    }'::jsonb as permissions
FROM profiles p
WHERE p.id NOT IN (
    SELECT user_id 
    FROM user_permissions 
    WHERE user_id IS NOT NULL
)
AND p.organization_id IS NOT NULL;

-- Reabilitar o trigger para novos usuários
CREATE OR REPLACE TRIGGER trigger_create_default_permissions
    AFTER INSERT ON profiles
    FOR EACH ROW
    WHEN (NEW.organization_id IS NOT NULL)
    EXECUTE FUNCTION create_default_user_permissions();

-- Atualizar comentários
COMMENT ON FUNCTION create_default_user_permissions() IS 'Função que cria permissões padrão para novos usuários - reabilitada após correção';
COMMENT ON TABLE profiles IS 'Tabela de perfis de usuários - trigger de permissões reabilitado';

-- Log da migração
DO $$
BEGIN
    RAISE NOTICE 'Migração concluída: Permissões criadas para todos os usuários existentes e trigger reabilitado';
END $$;