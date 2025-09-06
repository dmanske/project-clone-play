-- Consulta para verificar adversários na tabela
-- Execute este SQL no Supabase para verificar os dados

-- 1. Verificar se a tabela adversarios existe
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'adversarios' 
ORDER BY ordinal_position;

-- 2. Contar total de adversários
SELECT COUNT(*) as total_adversarios FROM adversarios;

-- 3. Listar todos os adversários
SELECT 
    id,
    nome,
    logo_url,
    ativo,
    organization_id,
    created_at
FROM adversarios 
ORDER BY nome;

-- 4. Verificar adversários por organização
SELECT 
    organization_id,
    COUNT(*) as quantidade_adversarios
FROM adversarios 
GROUP BY organization_id;

-- 5. Verificar se há adversários ativos
SELECT 
    COUNT(*) as adversarios_ativos
FROM adversarios 
WHERE ativo = true;

-- 6. Verificar políticas RLS da tabela adversarios
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

-- 7. Verificar se RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'adversarios';

-- 8. Testar consulta como usuário autenticado (simular o que o frontend faz)
-- Esta consulta deve retornar apenas adversários da organização do usuário
SELECT 
    id,
    nome,
    logo_url
FROM adversarios 
WHERE ativo = true 
ORDER BY nome;

-- 9. Verificar informações do usuário atual (se autenticado)
SELECT 
    auth.uid() as user_id,
    auth.jwt() ->> 'email' as email;

-- 10. Verificar perfil do usuário e organização
SELECT 
    p.id,
    p.email,
    p.organization_id,
    o.name as organization_name
FROM profiles p
LEFT JOIN organizations o ON p.organization_id = o.id
WHERE p.id = auth.uid();