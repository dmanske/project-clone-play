-- Função SQL para criar organização e associar ao usuário
-- Execute este script no SQL Editor do Supabase

CREATE OR REPLACE FUNCTION create_organization_with_user(
    org_name TEXT,
    org_slug TEXT,
    org_phone TEXT DEFAULT NULL,
    org_email TEXT DEFAULT NULL,
    time_casa TEXT DEFAULT NULL,
    cor_prim TEXT DEFAULT '#3B82F6',
    cor_sec TEXT DEFAULT '#10B981',
    user_id UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    new_org_id UUID;
    result JSON;
BEGIN
    -- Usar o user_id fornecido ou o usuário autenticado
    IF user_id IS NULL THEN
        user_id := auth.uid();
    END IF;
    
    -- Verificar se o usuário está autenticado
    IF user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Criar nova organização
    INSERT INTO organizations (
        name,
        slug,
        phone,
        email,
        time_casa_padrao,
        cor_primaria,
        cor_secundaria
    )
    VALUES (
        org_name,
        org_slug,
        org_phone,
        org_email,
        time_casa,
        cor_prim,
        cor_sec
    )
    RETURNING id INTO new_org_id;
    
    -- Atualizar perfil do usuário com a nova organização
    UPDATE profiles 
    SET organization_id = new_org_id
    WHERE id = user_id;
    
    -- Retornar dados da organização criada
    SELECT json_build_object(
        'id', o.id,
        'name', o.name,
        'slug', o.slug,
        'phone', o.phone,
        'email', o.email,
        'time_casa_padrao', o.time_casa_padrao,
        'cor_primaria', o.cor_primaria,
        'cor_secundaria', o.cor_secundaria,
        'created_at', o.created_at
    ) INTO result
    FROM organizations o
    WHERE o.id = new_org_id;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dar permissões para usuários autenticados
GRANT EXECUTE ON FUNCTION create_organization_with_user TO authenticated;

-- Comentário da função
COMMENT ON FUNCTION create_organization_with_user IS 'Cria uma nova organização e associa ao usuário atual';

