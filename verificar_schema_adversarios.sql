-- Script para verificar o schema atual da tabela adversarios
-- Execute este SQL no banco de dados atual

-- 1. Verificar se a tabela adversarios existe
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name = 'adversarios';

-- 2. Verificar estrutura completa da tabela adversarios
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default,
    ordinal_position
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'adversarios'
ORDER BY ordinal_position;

-- 3. Verificar constraints da tabela adversarios
SELECT 
    constraint_name,
    constraint_type,
    column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public' 
    AND tc.table_name = 'adversarios';

-- 4. Verificar foreign keys da tabela adversarios
SELECT 
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_schema = 'public'
    AND tc.table_name = 'adversarios';

-- 5. Verificar políticas RLS da tabela adversarios
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'adversarios';

-- 6. Verificar dados existentes (apenas contagem)
SELECT COUNT(*) as total_adversarios FROM adversarios;

-- 7. Verificar se há dados com logo_url
SELECT 
    COUNT(*) as total_com_logo,
    COUNT(*) FILTER (WHERE logo_url IS NOT NULL AND logo_url != '') as total_logo_preenchido
FROM adversarios;