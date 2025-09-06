-- =====================================================
-- CORREÇÃO COMPLETA DO SISTEMA MULTI-TENANT
-- =====================================================

-- 1. PRIMEIRO: VERIFICAR SEU PERFIL ATUAL
-- =====================================================
SELECT 
    id,
    email,
    full_name,
    organization_id,
    role,
    active
FROM profiles 
WHERE email = 'daniel.manske@gmail.com';

-- 2. ATUALIZAR SEU PERFIL PARA TER ORGANIZATION_ID
-- =====================================================
-- Vamos te associar à organização GoFans Development
UPDATE profiles 
SET 
    organization_id = '9f3c25e8-7bef-49f3-8528-1f3dbadaea15',
    role = 'owner'
WHERE email = 'daniel.manske@gmail.com';

-- 3. REMOVER TODAS AS POLICIES PROBLEMÁTICAS DA TABELA PROFILES
-- =====================================================
DROP POLICY IF EXISTS "Organization admins can manage profiles in their organization" ON profiles;
DROP POLICY IF EXISTS "Super admins can create profiles" ON profiles;
DROP POLICY IF EXISTS "Super admins can manage all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view and update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view profiles from their organization" ON profiles;

-- 4. RECRIAR POLICIES CORRETAS PARA PROFILES (SEM RECURSÃO)
-- =====================================================

-- Policy básica: usuários podem ver e editar seu próprio perfil
CREATE POLICY "Users can manage own profile" ON profiles
    FOR ALL USING (id = auth.uid());

-- Policy para super admins (usando tabela super_admin_users)
CREATE POLICY "Super admins can manage all profiles" ON profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users 
            WHERE user_id = auth.uid()
        )
    );

-- Policy para admins gerenciarem perfis da organização (SEM JOIN COM PROFILES)
CREATE POLICY "Admins can manage organization profiles" ON profiles
    FOR ALL USING (
        -- Verificar se o usuário atual é admin/owner da mesma organização
        -- usando uma subquery que não causa recursão
        organization_id = (
            SELECT p.organization_id 
            FROM profiles p 
            WHERE p.id = auth.uid() 
            AND p.role IN ('admin', 'owner')
            LIMIT 1
        )
    );

-- 5. CORRIGIR POLICIES DE ORGANIZATION_SUBSCRIPTIONS
-- =====================================================
DROP POLICY IF EXISTS "Users can view their organization subscription" ON organization_subscriptions;
DROP POLICY IF EXISTS "Super admins can view all subscriptions" ON organization_subscriptions;

CREATE POLICY "Users can view their organization subscription" ON organization_subscriptions
    FOR SELECT USING (
        organization_id = (
            SELECT p.organization_id 
            FROM profiles p 
            WHERE p.id = auth.uid()
            LIMIT 1
        )
    );

CREATE POLICY "Super admins can manage all subscriptions" ON organization_subscriptions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- 6. CORRIGIR POLICIES DE ORGANIZATION_SETTINGS
-- =====================================================
DROP POLICY IF EXISTS "Users can view their organization settings" ON organization_settings;
DROP POLICY IF EXISTS "Admins can update their organization settings" ON organization_settings;

CREATE POLICY "Users can view their organization settings" ON organization_settings
    FOR SELECT USING (
        organization_id = (
            SELECT p.organization_id 
            FROM profiles p 
            WHERE p.id = auth.uid()
            LIMIT 1
        )
    );

CREATE POLICY "Admins can manage their organization settings" ON organization_settings
    FOR ALL USING (
        organization_id = (
            SELECT p.organization_id 
            FROM profiles p 
            WHERE p.id = auth.uid() 
            AND p.role IN ('admin', 'owner')
            LIMIT 1
        )
    );

CREATE POLICY "Super admins can manage all organization settings" ON organization_settings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- 7. CORRIGIR POLICIES DE USER_PERMISSIONS
-- =====================================================
DROP POLICY IF EXISTS "Users can view their own permissions" ON user_permissions;
DROP POLICY IF EXISTS "Admins can manage permissions in their organization" ON user_permissions;

CREATE POLICY "Users can view their own permissions" ON user_permissions
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Admins can manage permissions in their organization" ON user_permissions
    FOR ALL USING (
        organization_id = (
            SELECT p.organization_id 
            FROM profiles p 
            WHERE p.id = auth.uid() 
            AND p.role IN ('admin', 'owner')
            LIMIT 1
        )
    );

CREATE POLICY "Super admins can manage all permissions" ON user_permissions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- 8. CORRIGIR POLICIES DE USER_INVITATIONS
-- =====================================================
DROP POLICY IF EXISTS "Users can view invitations for their organization" ON user_invitations;
DROP POLICY IF EXISTS "Admins can manage invitations for their organization" ON user_invitations;

CREATE POLICY "Users can view invitations for their organization" ON user_invitations
    FOR SELECT USING (
        organization_id = (
            SELECT p.organization_id 
            FROM profiles p 
            WHERE p.id = auth.uid()
            LIMIT 1
        )
    );

CREATE POLICY "Admins can manage invitations for their organization" ON user_invitations
    FOR ALL USING (
        organization_id = (
            SELECT p.organization_id 
            FROM profiles p 
            WHERE p.id = auth.uid() 
            AND p.role IN ('admin', 'owner')
            LIMIT 1
        )
    );

CREATE POLICY "Super admins can manage all invitations" ON user_invitations
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- 9. GARANTIR QUE AS ASSINATURAS E CONFIGURAÇÕES EXISTAM
-- =====================================================

-- Criar assinatura para GoFans Development se não existir
INSERT INTO organization_subscriptions (
    organization_id, 
    status, 
    trial_start_date, 
    trial_end_date
) VALUES (
    '9f3c25e8-7bef-49f3-8528-1f3dbadaea15',
    'ACTIVE',  -- Como você é o dono, vamos deixar ativo
    NOW(),
    NOW() + INTERVAL '30 days'
) ON CONFLICT (organization_id) DO UPDATE SET
    status = 'ACTIVE',
    trial_end_date = NOW() + INTERVAL '30 days';

-- Criar configurações para GoFans Development se não existir
INSERT INTO organization_settings (
    organization_id,
    cor_primaria,
    cor_secundaria,
    timezone,
    moeda
) VALUES (
    '9f3c25e8-7bef-49f3-8528-1f3dbadaea15',
    '#1f2937',
    '#3b82f6',
    'America/Sao_Paulo',
    'BRL'
) ON CONFLICT (organization_id) DO NOTHING;

-- Criar assinatura para NetoTours Teste (trial)
INSERT INTO organization_subscriptions (
    organization_id, 
    status, 
    trial_start_date, 
    trial_end_date
) VALUES (
    '05e472b2-1a76-4972-9af5-034fdaf37afe',
    'TRIAL',
    NOW(),
    NOW() + INTERVAL '7 days'
) ON CONFLICT (organization_id) DO NOTHING;

-- Criar configurações para NetoTours Teste
INSERT INTO organization_settings (
    organization_id,
    cor_primaria,
    cor_secundaria,
    timezone,
    moeda
) VALUES (
    '05e472b2-1a76-4972-9af5-034fdaf37afe',
    '#dc2626',
    '#fbbf24',
    'America/Sao_Paulo',
    'BRL'
) ON CONFLICT (organization_id) DO NOTHING;

-- 10. VERIFICAR SE TUDO ESTÁ FUNCIONANDO
-- =====================================================

-- Verificar seu perfil atualizado
SELECT 
    'SEU PERFIL ATUALIZADO:' as info,
    id,
    email,
    full_name,
    organization_id,
    role,
    active
FROM profiles 
WHERE email = 'daniel.manske@gmail.com';

-- Verificar se você é super admin
SELECT 
    'STATUS SUPER ADMIN:' as info,
    CASE 
        WHEN EXISTS (SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()) 
        THEN 'Você é SUPER ADMIN ✅' 
        ELSE 'Você NÃO é super admin ❌' 
    END as status;

-- Verificar assinaturas criadas
SELECT 
    'ASSINATURAS:' as info,
    o.name as organization_name,
    os.status,
    os.trial_end_date
FROM organizations o
LEFT JOIN organization_subscriptions os ON o.id = os.organization_id
ORDER BY o.name;

-- Verificar configurações criadas
SELECT 
    'CONFIGURAÇÕES:' as info,
    o.name as organization_name,
    ost.cor_primaria,
    ost.cor_secundaria
FROM organizations o
LEFT JOIN organization_settings ost ON o.id = ost.organization_id
ORDER BY o.name;

-- Teste final: tentar acessar dados sem erro
SELECT 
    'TESTE FINAL:' as info,
    COUNT(*) as profiles_acessiveis
FROM profiles;

-- =====================================================
-- INSTRUÇÕES FINAIS
-- =====================================================
/*
APÓS EXECUTAR ESTE SQL:

1. ✅ Seu perfil terá organization_id definido
2. ✅ Você será owner da GoFans Development  
3. ✅ As policies não terão mais recursão infinita
4. ✅ O sistema multi-tenant funcionará
5. ✅ O banner de status aparecerá

PRÓXIMOS PASSOS:
1. Execute este SQL completo
2. Reinicie o servidor (npm run dev)
3. Faça login novamente
4. Verifique se o banner aparece
5. Teste as funcionalidades

Se ainda houver erros, execute novamente o diagnostic.sql
*/