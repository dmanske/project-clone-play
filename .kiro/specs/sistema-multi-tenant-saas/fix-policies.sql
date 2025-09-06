-- =====================================================
-- CORREÇÃO DAS POLICIES RLS - RECURSÃO INFINITA
-- =====================================================

-- O erro "infinite recursion detected in policy" acontece quando
-- uma policy faz referência à própria tabela de forma circular.
-- Vamos corrigir isso.

-- 1. REMOVER POLICIES PROBLEMÁTICAS DA TABELA PROFILES
-- =====================================================

-- Primeiro, vamos ver quais policies existem
-- (execute o diagnostic.sql primeiro para ver)

-- Remover todas as policies da tabela profiles para recriá-las
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view profiles in same organization" ON profiles;
DROP POLICY IF EXISTS "Admins can manage profiles in organization" ON profiles;
DROP POLICY IF EXISTS "Super admins can view all profiles" ON profiles;

-- 2. RECRIAR POLICIES CORRETAS PARA PROFILES
-- =====================================================

-- Policy básica: usuários podem ver e editar seu próprio perfil
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (id = auth.uid());

-- Policy para super admins verem todos os perfis
CREATE POLICY "Super admins can view all profiles" ON profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users 
            WHERE user_id = auth.uid()
        )
    );

-- Policy para usuários verem perfis da mesma organização
-- (SEM fazer join com profiles para evitar recursão)
CREATE POLICY "Users can view organization profiles" ON profiles
    FOR SELECT USING (
        organization_id IN (
            -- Buscar organization_id do usuário atual diretamente
            SELECT p.organization_id 
            FROM profiles p 
            WHERE p.id = auth.uid()
        )
    );

-- 3. VERIFICAR E CORRIGIR OUTRAS POLICIES PROBLEMÁTICAS
-- =====================================================

-- Remover e recriar policies das novas tabelas se necessário
DROP POLICY IF EXISTS "Users can view their organization subscription" ON organization_subscriptions;
DROP POLICY IF EXISTS "Super admins can view all subscriptions" ON organization_subscriptions;

CREATE POLICY "Users can view their organization subscription" ON organization_subscriptions
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM profiles WHERE id = auth.uid()
        )
    );

CREATE POLICY "Super admins can manage all subscriptions" ON organization_subscriptions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- 4. POLICIES PARA ORGANIZATION_SETTINGS
-- =====================================================
DROP POLICY IF EXISTS "Users can view their organization settings" ON organization_settings;
DROP POLICY IF EXISTS "Admins can update their organization settings" ON organization_settings;

CREATE POLICY "Users can view their organization settings" ON organization_settings
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM profiles WHERE id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage their organization settings" ON organization_settings
    FOR ALL USING (
        organization_id IN (
            SELECT organization_id FROM profiles 
            WHERE id = auth.uid() AND role IN ('admin', 'owner')
        )
    );

CREATE POLICY "Super admins can manage all organization settings" ON organization_settings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- 5. POLICIES PARA USER_PERMISSIONS
-- =====================================================
DROP POLICY IF EXISTS "Users can view their own permissions" ON user_permissions;
DROP POLICY IF EXISTS "Admins can manage permissions in their organization" ON user_permissions;

CREATE POLICY "Users can view their own permissions" ON user_permissions
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Admins can manage permissions in their organization" ON user_permissions
    FOR ALL USING (
        organization_id IN (
            SELECT organization_id FROM profiles 
            WHERE id = auth.uid() AND role IN ('admin', 'owner')
        )
    );

CREATE POLICY "Super admins can manage all permissions" ON user_permissions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- 6. POLICIES PARA USER_INVITATIONS
-- =====================================================
DROP POLICY IF EXISTS "Users can view invitations for their organization" ON user_invitations;
DROP POLICY IF EXISTS "Admins can manage invitations for their organization" ON user_invitations;

CREATE POLICY "Users can view invitations for their organization" ON user_invitations
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM profiles WHERE id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage invitations for their organization" ON user_invitations
    FOR ALL USING (
        organization_id IN (
            SELECT organization_id FROM profiles 
            WHERE id = auth.uid() AND role IN ('admin', 'owner')
        )
    );

CREATE POLICY "Super admins can manage all invitations" ON user_invitations
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- 7. POLICIES PARA SUPER_ADMIN_USERS
-- =====================================================
DROP POLICY IF EXISTS "Only super admins can view super admin table" ON super_admin_users;

CREATE POLICY "Only super admins can view super admin table" ON super_admin_users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- 8. ADICIONAR VOCÊ COMO SUPER ADMIN
-- =====================================================
-- Substitua pelo seu user_id real (01e58a5e-d3f7-462c-8621-3ea65fc267c0)
INSERT INTO super_admin_users (
    user_id, 
    can_access_all_tenants, 
    can_manage_subscriptions, 
    can_block_organizations, 
    can_view_analytics
) VALUES (
    '01e58a5e-d3f7-462c-8621-3ea65fc267c0', 
    true, 
    true, 
    true, 
    true
) ON CONFLICT (user_id) DO NOTHING;

-- 9. VERIFICAR SE TUDO ESTÁ FUNCIONANDO
-- =====================================================
-- Teste básico para ver se as policies estão funcionando
SELECT 
    'profiles' as table_name,
    COUNT(*) as accessible_records
FROM profiles;

SELECT 
    'organization_subscriptions' as table_name,
    COUNT(*) as accessible_records
FROM organization_subscriptions;

SELECT 
    'organization_settings' as table_name,
    COUNT(*) as accessible_records
FROM organization_settings;

-- Verificar se você é super admin
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()) 
        THEN 'Você é SUPER ADMIN' 
        ELSE 'Você NÃO é super admin' 
    END as super_admin_status;

-- =====================================================
-- INSTRUÇÕES DE EXECUÇÃO
-- =====================================================
/*
1. Execute primeiro o diagnostic.sql para ver o estado atual
2. Execute este arquivo completo
3. Teste o sistema - os erros de recursão devem parar
4. Verifique se o banner de status aparece
5. Se ainda houver problemas, execute o diagnostic.sql novamente
*/