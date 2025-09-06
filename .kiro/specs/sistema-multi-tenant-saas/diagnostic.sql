-- =====================================================
-- DIAGNÓSTICO COMPLETO DO SUPABASE
-- =====================================================

-- 1. VERIFICAR TODAS AS TABELAS
-- =====================================================
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. VERIFICAR COLUNAS DAS TABELAS PRINCIPAIS
-- =====================================================
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('organizations', 'profiles', 'organization_subscriptions', 'organization_settings', 'user_permissions', 'super_admin_users')
ORDER BY table_name, ordinal_position;

-- 3. VERIFICAR TODAS AS POLICIES RLS
-- =====================================================
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
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 4. VERIFICAR RLS HABILITADO
-- =====================================================
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- 5. VERIFICAR FUNCTIONS CRIADAS
-- =====================================================
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_schema = 'public'
AND routine_name IN ('create_trial_subscription', 'is_organization_active', 'create_default_permissions')
ORDER BY routine_name;

-- 6. VERIFICAR TRIGGERS
-- =====================================================
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- 7. VERIFICAR SEU USER ID E SE É SUPER ADMIN
-- =====================================================
-- Primeiro, vamos ver seu user_id atual
SELECT auth.uid() as current_user_id;

-- Verificar se você está na tabela profiles
SELECT 
    id,
    email,
    full_name,
    organization_id,
    role,
    active
FROM profiles 
WHERE id = auth.uid();

-- Verificar se você é super admin
SELECT 
    sa.*,
    p.email,
    p.full_name
FROM super_admin_users sa
LEFT JOIN profiles p ON sa.user_id = p.id
WHERE sa.user_id = auth.uid();

-- 8. VERIFICAR ORGANIZAÇÕES EXISTENTES
-- =====================================================
SELECT 
    o.*,
    os.status as subscription_status,
    os.trial_end_date,
    ost.cor_primaria,
    ost.cor_secundaria
FROM organizations o
LEFT JOIN organization_subscriptions os ON o.id = os.organization_id
LEFT JOIN organization_settings ost ON o.id = ost.organization_id
ORDER BY o.created_at;

-- 9. VERIFICAR DADOS DAS NOVAS TABELAS
-- =====================================================
-- Organization Subscriptions
SELECT COUNT(*) as total_subscriptions FROM organization_subscriptions;
SELECT * FROM organization_subscriptions LIMIT 5;

-- Organization Settings  
SELECT COUNT(*) as total_settings FROM organization_settings;
SELECT * FROM organization_settings LIMIT 5;

-- User Permissions
SELECT COUNT(*) as total_permissions FROM user_permissions;
SELECT * FROM user_permissions LIMIT 5;

-- User Invitations
SELECT COUNT(*) as total_invitations FROM user_invitations;
SELECT * FROM user_invitations LIMIT 5;

-- Super Admin Users
SELECT COUNT(*) as total_super_admins FROM super_admin_users;
SELECT * FROM super_admin_users;

-- 10. VERIFICAR POLICIES PROBLEMÁTICAS DA TABELA PROFILES
-- =====================================================
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'profiles'
ORDER BY policyname;

-- 11. VERIFICAR FOREIGN KEYS
-- =====================================================
SELECT
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_schema='public'
ORDER BY tc.table_name;

-- =====================================================
-- COMANDOS PARA EXECUTAR SEPARADAMENTE
-- =====================================================

-- Para ver seu user_id específico (execute separadamente):
-- SELECT auth.uid();

-- Para adicionar você como super admin (substitua o ID):
-- INSERT INTO super_admin_users (user_id, can_access_all_tenants, can_manage_subscriptions, can_block_organizations, can_view_analytics)
-- VALUES ('01e58a5e-d3f7-462c-8621-3ea65fc267c0', true, true, true, true)
-- ON CONFLICT (user_id) DO NOTHING;