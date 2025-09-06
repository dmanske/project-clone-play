-- Script para verificar a estrutura atual da tabela organizations
-- Execute este script no SQL Editor do Supabase

-- =====================================================
-- 1. VERIFICAR SE A TABELA ORGANIZATIONS EXISTE
-- =====================================================

SELECT 
    'TABELA ORGANIZATIONS' as status,
    table_name,
    table_schema
FROM information_schema.tables 
WHERE table_name = 'organizations';

-- =====================================================
-- 2. VERIFICAR ESTRUTURA DA TABELA ORGANIZATIONS
-- =====================================================

SELECT 
    'COLUNAS DA TABELA ORGANIZATIONS' as status,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'organizations'
ORDER BY ordinal_position;

-- =====================================================
-- 3. VERIFICAR DADOS EXISTENTES (SE HOUVER)
-- =====================================================

SELECT 
    'DADOS EXISTENTES' as status,
    COUNT(*) as total_organizations
FROM organizations;

-- Se existir dados, mostrar alguns
SELECT 
    'ORGANIZAÇÕES EXISTENTES' as status,
    *
FROM organizations
LIMIT 5;

-- =====================================================
-- 4. VERIFICAR CONSTRAINTS E ÍNDICES
-- =====================================================

SELECT 
    'CONSTRAINTS' as status,
    constraint_name,
    constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'organizations';

SELECT 
    'ÍNDICES' as status,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'organizations';

-- =====================================================
-- INSTRUÇÕES:
-- =====================================================
/*
Este script vai mostrar:
1. Se a tabela organizations existe
2. Quais colunas ela tem atualmente
3. Se há dados existentes
4. Quais constraints e índices existem

Com essas informações, posso corrigir o script de inserção.
*/