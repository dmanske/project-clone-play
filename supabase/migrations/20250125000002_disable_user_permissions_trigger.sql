-- Desabilitar temporariamente o trigger que está causando erro no cadastro
-- Este trigger será reabilitado após verificar a estrutura das tabelas

-- Remover o trigger que cria permissões automaticamente
DROP TRIGGER IF EXISTS trigger_create_default_permissions ON profiles;
DROP TRIGGER IF EXISTS create_user_permissions_trigger ON profiles;

-- Comentar a função para referência futura
COMMENT ON FUNCTION create_default_user_permissions() IS 'Função desabilitada temporariamente - estava causando erro no cadastro de usuários';

-- Adicionar comentário explicativo
COMMENT ON TABLE profiles IS 'Tabela de perfis de usuários - trigger de permissões desabilitado temporariamente';