-- Criar função RPC para buscar organization_id do usuário autenticado
-- Esta função será usada como fallback quando a tabela profiles não estiver disponível nos tipos

CREATE OR REPLACE FUNCTION get_user_organization_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    org_id uuid;
BEGIN
    -- Verificar se o usuário está autenticado
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Buscar organization_id do perfil do usuário
    SELECT organization_id INTO org_id
    FROM profiles
    WHERE id = auth.uid();
    
    -- Se não encontrar na tabela profiles, tentar buscar do JWT
    IF org_id IS NULL THEN
        org_id := (auth.jwt() ->> 'organization_id')::uuid;
    END IF;
    
    RETURN org_id;
EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro, retornar NULL
        RETURN NULL;
END;
$$;

-- Dar permissão para usuários autenticados executarem a função
GRANT EXECUTE ON FUNCTION get_user_organization_id() TO authenticated;

-- Testar a função
SELECT 'Testando função get_user_organization_id:' as info;
SELECT get_user_organization_id() as organization_id;