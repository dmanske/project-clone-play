-- Script para investigar processos que associam automaticamente usuários a organizações
-- Execute este script no SQL Editor do Supabase para diagnosticar o problema

-- =====================================================
-- 1. VERIFICAR TRIGGERS EXISTENTES
-- =====================================================

-- =====================================================
-- 2. VERIFICAR FUNÇÕES RELACIONADAS A SIGNUP/USUÁRIOS
-- =====================================================

-- Listar todas as funções que podem estar relacionadas ao signup
SELECT 
    'FUNÇÕES RELACIONADAS A USUÁRIOS' as tipo,
    routine_name,
    routine_type,
    routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public' 
    AND (
        routine_name ILIKE '%user%' 
        OR routine_name ILIKE '%signup%' 
        OR routine_name ILIKE '%organization%'
        OR routine_name ILIKE '%handle%'
        OR routine_name ILIKE '%create%'
    )
ORDER BY routine_name;

-- =====================================================
-- 3. VERIFICAR POLÍTICAS RLS QUE PODEM AFETAR INSERÇÃO
-- =====================================================

-- Verificar políticas na tabela profiles
SELECT 
    'POLÍTICAS RLS - PROFILES' as tipo,
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'profiles'
ORDER BY policyname;

-- =====================================================
-- 4. VERIFICAR USUÁRIOS SEM ORGANIZAÇÃO
-- =====================================================

-- Contar usuários sem organization_id
SELECT 
    'USUÁRIOS SEM ORGANIZAÇÃO' as tipo,
    COUNT(*) as total_usuarios_sem_org
FROM profiles 
WHERE organization_id IS NULL;

-- Listar usuários sem organização (últimos 10)
SELECT 
    'ÚLTIMOS USUÁRIOS SEM ORGANIZAÇÃO' as tipo,
    id,
    email,
    full_name,
    organization_id,
    role,
    created_at
FROM profiles 
WHERE organization_id IS NULL
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- 5. VERIFICAR ORGANIZAÇÕES EXISTENTES
-- =====================================================

-- Listar todas as organizações
SELECT 
    'ORGANIZAÇÕES EXISTENTES' as tipo,
    id,
    name,
    slug,
    created_at,
    (
        SELECT COUNT(*) 
        FROM profiles p 
        WHERE p.organization_id = o.id
    ) as total_usuarios
FROM organizations o
ORDER BY created_at ASC;

-- =====================================================
-- 6. VERIFICAR SCRIPTS DE MIGRAÇÃO AUTOMÁTICA
-- =====================================================

-- Verificar se há jobs ou processos agendados
SELECT 
    'JOBS AGENDADOS' as tipo,
    *
FROM pg_stat_activity 
WHERE query ILIKE '%UPDATE%profiles%organization_id%'
   OR query ILIKE '%INSERT%organization%'
ORDER BY query_start DESC;

-- =====================================================
-- 7. VERIFICAR LOGS DE ATIVIDADE RECENTE
-- =====================================================

-- Verificar atividade recente na tabela profiles
SELECT 
    'ATIVIDADE RECENTE - PROFILES' as tipo,
    COUNT(*) as total_updates_recentes
FROM profiles 
WHERE updated_at > NOW() - INTERVAL '1 hour';

-- =====================================================
-- 8. VERIFICAR FUNÇÃO handle_new_user (SE EXISTIR)
-- =====================================================

-- Tentar encontrar a função handle_new_user
SELECT 
    'FUNÇÃO HANDLE_NEW_USER' as tipo,
    routine_name,
    routine_definition
FROM information_schema.routines 
WHERE routine_name = 'handle_new_user'
   OR routine_name ILIKE '%handle%new%user%';

-- =====================================================
-- INSTRUÇÕES PARA ANÁLISE
-- =====================================================
/*
APÓS EXECUTAR ESTE SCRIPT, ANALISE:

1. TRIGGERS: Verifique se há triggers que executam após INSERT em profiles
2. FUNÇÕES: Procure por funções que fazem UPDATE em organization_id
3. POLÍTICAS: Verifique se há políticas que forçam association
4. USUÁRIOS: Confirme quantos usuários estão sem organização
5. JOBS: Verifique se há processos automáticos rodando

SE ENCONTRAR PROCESSOS AUTOMÁTICOS:
- Desabilite temporariamente os triggers problemáticos
- Modifique as funções para não fazer associação automática
- Implemente validação adequada no processo de signup

PRÓXIMOS PASSOS:
1. Execute este script
2. Analise os resultados
3. Identifique o processo que está causando a associação automática
4. Execute os scripts de correção que serão fornecidos
*/