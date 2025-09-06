-- Script para debugar o problema dos adversários não aparecerem
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar se o usuário está autenticado
SELECT 
    'USUÁRIO AUTENTICADO' as status,
    auth.uid() as user_id,
    CASE 
        WHEN auth.uid() IS NOT NULL THEN 'Usuário logado'
        ELSE 'Usuário NÃO logado - PROBLEMA!'
    END as resultado;

-- 2. Verificar se o usuário tem perfil
SELECT 
    'PERFIL DO USUÁRIO' as status,
    p.id,
    p.email,
    p.organization_id,
    CASE 
        WHEN p.organization_id IS NOT NULL THEN 'Usuário tem organização'
        ELSE 'Usuário SEM organização - PROBLEMA!'
    END as resultado
FROM profiles p
WHERE p.id = auth.uid();

-- 3. Verificar se a organização existe
SELECT 
    'ORGANIZAÇÃO' as status,
    o.id,
    o.name,
    o.created_at
FROM organizations o
WHERE o.id = (
    SELECT organization_id 
    FROM profiles 
    WHERE id = auth.uid()
);

-- 4. Verificar se RLS está habilitado na tabela adversarios
SELECT 
    'RLS STATUS' as status,
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'adversarios';

-- 5. Verificar políticas RLS da tabela adversarios
SELECT 
    'POLÍTICAS RLS' as status,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'adversarios';

-- 6. Contar total de adversários na tabela (sem RLS)
SELECT 
    'TOTAL ADVERSÁRIOS (SEM RLS)' as status,
    COUNT(*) as total
FROM adversarios;

-- 7. Contar adversários visíveis para o usuário (com RLS)
SELECT 
    'ADVERSÁRIOS VISÍVEIS (COM RLS)' as status,
    COUNT(*) as total_visiveis
FROM adversarios
WHERE organization_id = (
    SELECT organization_id 
    FROM profiles 
    WHERE id = auth.uid()
);

-- 8. Listar adversários da organização do usuário
SELECT 
    'ADVERSÁRIOS DA ORGANIZAÇÃO' as status,
    a.nome,
    a.logo_url,
    a.ativo,
    a.organization_id
FROM adversarios a
WHERE a.organization_id = (
    SELECT organization_id 
    FROM profiles 
    WHERE id = auth.uid()
)
ORDER BY a.nome
LIMIT 10;

-- 9. Verificar se há adversários sem organization_id
SELECT 
    'ADVERSÁRIOS SEM ORGANIZAÇÃO' as status,
    COUNT(*) as total_sem_org
FROM adversarios
WHERE organization_id IS NULL;

-- 10. Teste direto da consulta que o frontend faz
SELECT 
    'TESTE CONSULTA FRONTEND' as status,
    a.*
FROM adversarios a
WHERE a.nome != 'Flamengo'
ORDER BY a.nome
LIMIT 5;