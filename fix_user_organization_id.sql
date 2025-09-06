-- Script para corrigir o problema de organization_id NULL no perfil do usuário
-- Este script deve ser executado no SQL Editor do Supabase

-- =====================================================
-- 1. DIAGNÓSTICO INICIAL
-- =====================================================

-- Verificar o usuário atual
SELECT 
    'USUÁRIO ATUAL' as tipo,
    id,
    email,
    full_name,
    organization_id,
    role,
    active,
    created_at
FROM profiles 
WHERE id = auth.uid();

-- Verificar organizações disponíveis
SELECT 
    'ORGANIZAÇÕES DISPONÍVEIS' as tipo,
    id,
    name as nome,
    created_at
FROM organizations 
ORDER BY created_at ASC;

-- Verificar quantos usuários estão sem organização
SELECT 
    'USUÁRIOS SEM ORGANIZAÇÃO' as tipo,
    COUNT(*) as total_usuarios_sem_org
FROM profiles 
WHERE organization_id IS NULL;

-- =====================================================
-- 2. CORREÇÃO DO PROBLEMA
-- =====================================================

-- Atualizar o usuário atual com a primeira organização disponível
-- (Execute apenas se o usuário atual não tiver organization_id)
UPDATE profiles 
SET 
    organization_id = (
        SELECT id 
        FROM organizations 
        ORDER BY created_at ASC 
        LIMIT 1
    ),
    updated_at = NOW()
WHERE id = auth.uid() 
    AND organization_id IS NULL;

-- =====================================================
-- 3. VERIFICAÇÃO PÓS-CORREÇÃO
-- =====================================================

-- Verificar se o usuário agora tem organization_id
SELECT 
    'USUÁRIO APÓS CORREÇÃO' as tipo,
    id,
    email,
    full_name,
    organization_id,
    role,
    active
FROM profiles 
WHERE id = auth.uid();

-- Testar se auth.jwt() agora retorna organization_id
SELECT 
    'TESTE JWT' as tipo,
    auth.jwt() ->> 'organization_id' as organization_id_from_jwt,
    (auth.jwt() ->> 'organization_id')::uuid as organization_id_uuid;

-- =====================================================
-- 4. VERIFICAR ADVERSÁRIOS
-- =====================================================

-- Contar adversários por organização
SELECT 
    'ADVERSÁRIOS POR ORGANIZAÇÃO' as tipo,
    organization_id,
    COUNT(*) as total_adversarios
FROM adversarios
GROUP BY organization_id
ORDER BY organization_id;

-- Verificar se agora conseguimos ver adversários da nossa organização
SELECT 
    'ADVERSÁRIOS DA MINHA ORGANIZAÇÃO' as tipo,
    COUNT(*) as total_adversarios_visiveis
FROM adversarios 
WHERE organization_id = (auth.jwt() ->> 'organization_id')::uuid;

-- =====================================================
-- 5. SCRIPT ADICIONAL PARA OUTROS USUÁRIOS SEM ORGANIZAÇÃO
-- =====================================================

-- Se houver outros usuários sem organização, associá-los também
-- (Execute apenas se necessário)
/*
UPDATE profiles 
SET 
    organization_id = (
        SELECT id 
        FROM organizations 
        ORDER BY created_at ASC 
        LIMIT 1
    ),
    updated_at = NOW()
WHERE organization_id IS NULL;
*/

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
/*
1. Execute este script no SQL Editor do Supabase
2. Verifique o diagnóstico inicial
3. A correção será aplicada automaticamente se o usuário não tiver organization_id
4. Verifique os resultados pós-correção
5. Teste a aplicação para ver se os adversários agora aparecem

Este script resolve o problema de:
- Usuários sem organization_id no perfil
- auth.jwt() retornando NULL para organization_id
- Adversários não aparecendo devido ao filtro RLS
- Isolamento multi-tenant não funcionando corretamente
*/