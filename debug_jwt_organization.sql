-- Script para debugar problemas com JWT e organization_id
-- Execute no SQL Editor do Supabase para entender o problema

-- =====================================================
-- 1. VERIFICAR CONFIGURAÇÃO DO JWT
-- =====================================================

-- Verificar se auth.jwt() funciona
SELECT 
    'TESTE AUTH.JWT()' as teste,
    auth.jwt() as jwt_completo;

-- Verificar campos específicos do JWT
SELECT 
    'CAMPOS DO JWT' as teste,
    auth.jwt() ->> 'sub' as user_id,
    auth.jwt() ->> 'email' as email,
    auth.jwt() ->> 'role' as role,
    auth.jwt() ->> 'organization_id' as organization_id;

-- =====================================================
-- 2. VERIFICAR PERFIL DO USUÁRIO
-- =====================================================

-- Dados do perfil atual
SELECT 
    'PERFIL ATUAL' as teste,
    p.id,
    p.email,
    p.organization_id,
    p.role,
    o.name as organization_name
FROM profiles p
LEFT JOIN organizations o ON p.organization_id = o.id
WHERE p.id = auth.uid();

-- =====================================================
-- 3. VERIFICAR SE O PROBLEMA É NO JWT CLAIMS
-- =====================================================

-- O Supabase pode não estar incluindo organization_id no JWT automaticamente
-- Vamos verificar se existe uma função ou trigger para isso

SELECT 
    'FUNÇÕES AUTH' as teste,
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_schema = 'auth' 
    AND routine_name LIKE '%jwt%'
ORDER BY routine_name;

-- Verificar triggers na tabela profiles
SELECT 
    'TRIGGERS PROFILES' as teste,
    trigger_name,
    event_manipulation,
    action_timing
FROM information_schema.triggers 
WHERE event_object_table = 'profiles'
ORDER BY trigger_name;

-- =====================================================
-- 4. VERIFICAR POLÍTICAS RLS QUE DEPENDEM DO JWT
-- =====================================================

-- Políticas da tabela adversarios
SELECT 
    'POLÍTICAS ADVERSARIOS' as teste,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'adversarios'
ORDER BY policyname;

-- =====================================================
-- 5. TESTE DIRETO DE ACESSO AOS ADVERSÁRIOS
-- =====================================================

-- Tentar acessar adversários sem filtro (como super admin)
SELECT 
    'TODOS OS ADVERSÁRIOS' as teste,
    COUNT(*) as total
FROM adversarios;

-- Tentar acessar com filtro usando o perfil diretamente
SELECT 
    'ADVERSÁRIOS POR PERFIL' as teste,
    COUNT(*) as total
FROM adversarios a
INNER JOIN profiles p ON a.organization_id = p.organization_id
WHERE p.id = auth.uid();

-- =====================================================
-- 6. VERIFICAR SE PRECISA CRIAR FUNÇÃO PARA JWT CLAIMS
-- =====================================================

-- Verificar se existe função para adicionar claims customizados
SELECT 
    'FUNÇÕES CUSTOMIZADAS' as teste,
    routine_name,
    routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public' 
    AND (routine_name LIKE '%jwt%' OR routine_name LIKE '%claims%')
ORDER BY routine_name;

-- =====================================================
-- 7. SOLUÇÃO ALTERNATIVA - USAR PERFIL EM VEZ DE JWT
-- =====================================================

-- Se o JWT não incluir organization_id, podemos modificar as políticas
-- para usar o perfil diretamente em vez de auth.jwt()

-- Exemplo de como seria a política corrigida:
/*
CREATE OR REPLACE POLICY "Users can view organization adversarios" ON adversarios
FOR SELECT USING (
    organization_id = (
        SELECT organization_id 
        FROM profiles 
        WHERE id = auth.uid()
    )
    OR EXISTS (
        SELECT 1 FROM super_admin_users 
        WHERE user_id = auth.uid()
    )
);
*/

SELECT 'DIAGNÓSTICO COMPLETO' as resultado, 'Execute todas as consultas acima para identificar o problema' as instrucao;

-- =====================================================
-- POSSÍVEIS PROBLEMAS E SOLUÇÕES:
-- =====================================================
/*
PROBLEMA 1: organization_id não está no JWT
SOLUÇÃO: Criar função para adicionar claims customizados ou usar perfil nas políticas

PROBLEMA 2: Usuário não tem organization_id no perfil
SOLUÇÃO: Executar fix_user_organization_id.sql

PROBLEMA 3: Políticas RLS estão incorretas
SOLUÇÃO: Modificar políticas para usar profiles em vez de JWT

PROBLEMA 4: RLS não está habilitado
SOLUÇÃO: Habilitar RLS na tabela adversarios
*/