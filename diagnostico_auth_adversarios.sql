-- Script para diagnosticar problemas de autenticação e tabela adversarios
-- Execute este script para entender a configuração atual

-- 1. Verificar estrutura da tabela adversarios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'adversarios' 
ORDER BY ordinal_position;

-- 2. Verificar se a função auth.jwt() está disponível
SELECT 
    routine_name,
    routine_type,
    routine_schema
FROM information_schema.routines 
WHERE routine_name LIKE '%jwt%';

-- 3. Testar auth.jwt() - verificar se retorna dados
SELECT 
    auth.jwt() as jwt_completo,
    auth.jwt() ->> 'organization_id' as organization_id_string,
    (auth.jwt() ->> 'organization_id')::uuid as organization_id_uuid;

-- 4. Verificar usuário atual e seu perfil
SELECT 
    auth.uid() as user_id,
    auth.email() as user_email;

-- 5. Verificar tabela profiles e organization_id dos usuários
SELECT 
    id,
    email,
    organization_id,
    created_at
FROM profiles 
WHERE id = auth.uid();

-- 6. Verificar todas as organizações disponíveis
SELECT 
    id,
    nome,
    created_at
FROM organizations 
ORDER BY created_at;

-- 7. Verificar políticas RLS na tabela adversarios
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'adversarios';

-- 8. Verificar se RLS está habilitado na tabela adversarios
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'adversarios';

-- 9. Contar adversários existentes (sem filtro de organização)
SELECT 
    COUNT(*) as total_adversarios,
    COUNT(CASE WHEN organization_id IS NULL THEN 1 END) as adversarios_sem_org,
    COUNT(CASE WHEN organization_id IS NOT NULL THEN 1 END) as adversarios_com_org
FROM adversarios;

-- 10. Listar alguns adversários existentes
SELECT 
    id,
    nome,
    organization_id,
    created_at
FROM adversarios 
LIMIT 5;