-- =====================================================
-- EXTRAÇÃO COMPLETA DO ESQUEMA DO BANCO DE DADOS
-- Execute este SQL no projeto ORIGINAL (não multi-tenant)
-- =====================================================

-- =====================================================
-- 1. LISTAR TODAS AS TABELAS
-- =====================================================


-- =====================================================
-- 2. ESTRUTURA COMPLETA DE TODAS AS TABELAS
-- =====================================================
SELECT 
    '=== ESTRUTURA DAS TABELAS ===' as info,
    '' as table_name,
    '' as column_name,
    '' as data_type,
    '' as is_nullable,
    '' as column_default
UNION ALL
SELECT 
    'COLUNA' as info,
    table_name,
    column_name,
    data_type || CASE 
        WHEN character_maximum_length IS NOT NULL 
        THEN '(' || character_maximum_length || ')'
        WHEN numeric_precision IS NOT NULL AND numeric_scale IS NOT NULL
        THEN '(' || numeric_precision || ',' || numeric_scale || ')'
        ELSE ''
    END as data_type,
    is_nullable,
    COALESCE(column_default, 'NULL') as column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
AND table_name IN (
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
)
ORDER BY info DESC, table_name, column_name;

-- =====================================================
-- 3. CHAVES PRIMÁRIAS
-- =====================================================
SELECT 
    '=== CHAVES PRIMÁRIAS ===' as info,
    '' as table_name,
    '' as column_name,
    '' as constraint_name
UNION ALL
SELECT 
    'PRIMARY_KEY' as info,
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'PRIMARY KEY'
AND tc.table_schema = 'public'
ORDER BY info DESC, table_name;

-- =====================================================
-- 4. CHAVES ESTRANGEIRAS
-- =====================================================
    SELECT 
        '=== CHAVES ESTRANGEIRAS ===' as info,
        '' as table_name,
        '' as column_name,
        '' as foreign_table_name,
        '' as foreign_column_name
    UNION ALL
    SELECT 
        'FOREIGN_KEY' as info,
        tc.table_name,
        kcu.column_name,
        ccu.table_name as foreign_table_name,
        ccu.column_name as foreign_column_name
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu 
        ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage ccu 
        ON ccu.constraint_name = tc.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
    ORDER BY info DESC, table_name;

-- =====================================================
-- 5. ÍNDICES
-- =====================================================
SELECT 
    '=== ÍNDICES ===' as info,
    '' as table_name,
    '' as index_name,
    '' as column_name,
    '' as is_unique
UNION ALL
SELECT 
    'INDEX' as info,
    t.relname as table_name,
    i.relname as index_name,
    a.attname as column_name,
    CASE WHEN ix.indisunique THEN 'YES' ELSE 'NO' END as is_unique
FROM pg_class t
JOIN pg_index ix ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
WHERE t.relkind = 'r'
AND t.relname NOT LIKE 'pg_%'
AND i.relname NOT LIKE 'pg_%'
ORDER BY info DESC, table_name, index_name;

-- =====================================================
-- 6. VIEWS
-- =====================================================
SELECT 
    '=== VIEWS ===' as info,
    '' as view_name,
    '' as definition
UNION ALL
SELECT 
    'VIEW' as info,
    table_name as view_name,
    SUBSTRING(view_definition, 1, 200) as definition
FROM information_schema.views 
WHERE table_schema = 'public'
ORDER BY info DESC, view_name;

-- =====================================================
-- 7. TRIGGERS
-- =====================================================
SELECT 
    '=== TRIGGERS ===' as info,
    '' as table_name,
    '' as trigger_name,
    '' as event_manipulation
UNION ALL
SELECT 
    'TRIGGER' as info,
    event_object_table as table_name,
    trigger_name,
    event_manipulation
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
ORDER BY info DESC, table_name;

-- =====================================================
-- 8. FUNÇÕES PERSONALIZADAS
-- =====================================================
SELECT 
    '=== FUNÇÕES ===' as info,
    '' as function_name,
    '' as return_type
UNION ALL
SELECT 
    'FUNCTION' as info,
    routine_name as function_name,
    data_type as return_type
FROM information_schema.routines 
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION'
ORDER BY info DESC, function_name;

-- =====================================================
-- 9. POLÍTICAS RLS (se existirem)
-- =====================================================
SELECT 
    '=== POLÍTICAS RLS ===' as info,
    '' as table_name,
    '' as policy_name,
    '' as cmd,
    '' as permissive
UNION ALL
SELECT 
    'RLS_POLICY' as info,
    tablename as table_name,
    policyname as policy_name,
    cmd,
    CASE WHEN permissive = 'PERMISSIVE' THEN 'YES' ELSE 'NO' END as permissive
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY info DESC, table_name;

-- =====================================================
-- 10. CONSTRAINTS CHECK
-- =====================================================
SELECT 
    '=== CONSTRAINTS CHECK ===' as info,
    '' as table_name,
    '' as constraint_name,
    '' as check_clause
UNION ALL
SELECT 
    'CHECK_CONSTRAINT' as info,
    tc.table_name,
    tc.constraint_name,
    cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc 
    ON tc.constraint_name = cc.constraint_name
WHERE tc.constraint_type = 'CHECK'
AND tc.table_schema = 'public'
ORDER BY info DESC, table_name;

-- =====================================================
-- 11. SEQUÊNCIAS
-- =====================================================
SELECT 
    '=== SEQUÊNCIAS ===' as info,
    '' as sequence_name,
    '' as data_type,
    '' as start_value,
    '' as increment
UNION ALL
SELECT 
    'SEQUENCE' as info,
    sequence_name,
    data_type,
    start_value::text,
    increment::text
FROM information_schema.sequences 
WHERE sequence_schema = 'public'
ORDER BY info DESC, sequence_name;

-- =====================================================
-- INSTRUÇÕES
-- =====================================================
/*
INSTRUÇÕES PARA USO:

1. Execute este SQL no seu projeto ORIGINAL (não multi-tenant)
2. Copie TODO o resultado e me envie
3. Com base no resultado, vou:
   - Identificar todas as tabelas que existiam
   - Verificar quais colunas estão faltando
   - Criar um script completo para sincronizar o schema
   - Corrigir todas as views e relacionamentos

4. O resultado vai mostrar:
   - Todas as tabelas e suas colunas
   - Tipos de dados completos
   - Chaves primárias e estrangeiras
   - Índices existentes
   - Views definidas
   - Triggers e funções
   - Políticas RLS (se houver)
   - Constraints de validação

Este é o método mais eficiente para garantir que
o schema multi-tenant tenha EXATAMENTE a mesma
estrutura do projeto original.
*/