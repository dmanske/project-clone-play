-- =====================================================
-- CORRIGIR RECURSÃO INFINITA NAS POLÍTICAS DA TABELA PROFILES
-- Execute este SQL diretamente no Supabase SQL Editor
-- =====================================================

-- Remover TODAS as políticas existentes da tabela profiles (incluindo as que podem já ter sido criadas)
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view profiles in same organization" ON profiles;
DROP POLICY IF EXISTS "Admins can manage profiles in organization" ON profiles;
DROP POLICY IF EXISTS "Super admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can manage own profile" ON profiles;
DROP POLICY IF EXISTS "Super admins can manage all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can manage organization profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view organization profiles" ON profiles;
DROP POLICY IF EXISTS "Organization admins can manage profiles in their organization" ON profiles;
DROP POLICY IF EXISTS "Super admins can create profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view and update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view profiles from their organization" ON profiles;
-- Remover as políticas que podem ter sido criadas anteriormente
DROP POLICY IF EXISTS "Service role can manage all profiles" ON profiles;
DROP POLICY IF EXISTS "Super admins can manage all profiles" ON profiles;

-- Criar políticas seguras sem recursão
-- Política 1: Usuários podem ver e editar apenas seu próprio perfil
CREATE POLICY "Users can manage own profile" ON profiles
FOR ALL USING (auth.uid() = id);

-- Política 2: Service role pode gerenciar todos os perfis (para operações administrativas)
CREATE POLICY "Service role can manage all profiles" ON profiles
FOR ALL USING (auth.role() = 'service_role');

-- Política 3: Super admins podem gerenciar todos os perfis
-- Esta política usa uma verificação direta na tabela super_admin_users sem recursão
CREATE POLICY "Super admins can manage all profiles" ON profiles
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM super_admin_users sau 
        WHERE sau.user_id = auth.uid()
    )
);

-- =====================================================
-- VERIFICAR SE AS POLÍTICAS FORAM APLICADAS CORRETAMENTE
-- =====================================================

-- Listar todas as políticas da tabela profiles
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
WHERE tablename = 'profiles'
ORDER BY policyname;

-- =====================================================
-- COMENTÁRIOS IMPORTANTES
-- =====================================================

/*
PROBLEMA IDENTIFICADO:
As políticas anteriores causavam recursão infinita porque:

1. Políticas em outras tabelas (user_invitations, user_permissions, etc.) faziam:
   SELECT organization_id FROM profiles WHERE id = auth.uid()

2. A tabela profiles tinha suas próprias políticas RLS que também consultavam a tabela profiles

3. Isso criava um loop infinito:
   Política A consulta profiles -> profiles tem política B -> política B consulta profiles -> loop infinito

SOLUÇÃO IMPLEMENTADA:
1. Simplificar as políticas da tabela profiles para evitar consultas complexas
2. Usar auth.uid() = id para acesso próprio (sem consultas adicionais)
3. Usar auth.role() = 'service_role' para operações administrativas
4. Para super admins, fazer consulta direta na tabela super_admin_users (que já tem políticas corretas)

Esta solução quebra o ciclo de recursão mantendo a segurança do sistema.
*/