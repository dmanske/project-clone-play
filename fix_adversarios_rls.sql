-- Script para corrigir as políticas RLS da tabela adversarios
-- Execute este script no SQL Editor do Supabase

-- =====================================================
-- 1. VERIFICAR ESTADO ATUAL
-- =====================================================

-- Verificar se RLS está habilitado na tabela adversarios
SELECT 
    'RLS STATUS' as status,
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'adversarios';

-- Verificar políticas existentes
SELECT 
    'POLÍTICAS EXISTENTES' as status,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'adversarios';

-- Verificar dados do usuário atual
SELECT 
    'USUÁRIO ATUAL' as status,
    p.id,
    p.email,
    p.organization_id,
    o.name as organization_name
FROM profiles p
LEFT JOIN organizations o ON p.organization_id = o.id
WHERE p.id = auth.uid();

-- =====================================================
-- 2. REMOVER POLÍTICAS EXISTENTES (SE HOUVER)
-- =====================================================

-- Remover políticas existentes para recriar
DROP POLICY IF EXISTS "Users can view adversarios from their organization" ON adversarios;
DROP POLICY IF EXISTS "Users can manage adversarios from their organization" ON adversarios;
DROP POLICY IF EXISTS "Adversarios are isolated by organization" ON adversarios;

-- =====================================================
-- 3. HABILITAR RLS NA TABELA ADVERSARIOS
-- =====================================================

ALTER TABLE adversarios ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. CRIAR POLÍTICAS RLS CORRETAS
-- =====================================================

-- Política para SELECT: usuários podem ver adversários da sua organização
CREATE POLICY "Users can view adversarios from their organization" ON adversarios
FOR SELECT USING (
    organization_id = (
        SELECT organization_id 
        FROM profiles 
        WHERE id = auth.uid()
    )
);

-- Política para INSERT: usuários podem inserir adversários na sua organização
CREATE POLICY "Users can insert adversarios in their organization" ON adversarios
FOR INSERT WITH CHECK (
    organization_id = (
        SELECT organization_id 
        FROM profiles 
        WHERE id = auth.uid()
    )
);

-- Política para UPDATE: usuários podem atualizar adversários da sua organização
CREATE POLICY "Users can update adversarios from their organization" ON adversarios
FOR UPDATE USING (
    organization_id = (
        SELECT organization_id 
        FROM profiles 
        WHERE id = auth.uid()
    )
) WITH CHECK (
    organization_id = (
        SELECT organization_id 
        FROM profiles 
        WHERE id = auth.uid()
    )
);

-- Política para DELETE: usuários podem deletar adversários da sua organização
CREATE POLICY "Users can delete adversarios from their organization" ON adversarios
FOR DELETE USING (
    organization_id = (
        SELECT organization_id 
        FROM profiles 
        WHERE id = auth.uid()
    )
);

-- =====================================================
-- 5. VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar políticas criadas
SELECT 
    'POLÍTICAS CRIADAS' as status,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename = 'adversarios';

-- Testar acesso aos adversários
SELECT 
    'TESTE ACESSO FINAL' as status,
    COUNT(*) as adversarios_visiveis
FROM adversarios;

-- Listar adversários visíveis
SELECT 
    'ADVERSÁRIOS VISÍVEIS' as status,
    nome,
    ativo,
    organization_id
FROM adversarios
ORDER BY nome
LIMIT 10;

-- Verificar se o usuário tem organização
SELECT 
    'VERIFICAÇÃO ORGANIZAÇÃO' as status,
    CASE 
        WHEN organization_id IS NOT NULL THEN 'Usuário tem organização'
        ELSE 'Usuário SEM organização - PROBLEMA!'
    END as resultado,
    organization_id
FROM profiles 
WHERE id = auth.uid();

-- =====================================================
-- INSTRUÇÕES:
-- =====================================================
/*
Este script:
1. ✅ Remove políticas RLS antigas que podem estar incorretas
2. ✅ Habilita RLS na tabela adversarios
3. ✅ Cria políticas RLS corretas para SELECT, INSERT, UPDATE, DELETE
4. ✅ Testa se o usuário consegue ver os adversários
5. ✅ Verifica se o usuário tem organização associada

Após executar este script:
- Os adversários devem ficar visíveis para o usuário
- O sistema multi-tenant deve funcionar corretamente
- Cada organização verá apenas seus próprios adversários
*/