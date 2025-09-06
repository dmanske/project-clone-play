-- =====================================================
-- CORREÇÃO DO CHECK CONSTRAINT DE ROLES
-- =====================================================

-- 1. VERIFICAR O CHECK CONSTRAINT ATUAL
-- =====================================================
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'profiles'::regclass 
AND contype = 'c';

-- 2. VERIFICAR QUAIS ROLES SÃO PERMITIDOS ATUALMENTE
-- =====================================================
-- Vamos ver a definição da tabela profiles
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name = 'role';

-- 3. REMOVER O CHECK CONSTRAINT ATUAL E RECRIAR COM OWNER
-- =====================================================

-- Primeiro, vamos dropar o constraint existente
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;

-- Recriar o constraint incluindo 'owner'
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check 
CHECK (role IN ('user', 'admin', 'owner', 'super_admin'));

-- 4. AGORA ATUALIZAR SEU ROLE PARA OWNER
-- =====================================================
UPDATE profiles 
SET role = 'owner'
WHERE email = 'daniel.manske@gmail.com';

-- 5. VERIFICAR SE FUNCIONOU
-- =====================================================
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

-- 6. CRIAR PERMISSÕES PARA VOCÊ COMO OWNER
-- =====================================================
INSERT INTO user_permissions (
    user_id, 
    organization_id, 
    permissions
) VALUES (
    '01e58a5e-d3f7-462c-8621-3ea65fc267c0',
    '9f3c25e8-7bef-49f3-8528-1f3dbadaea15',
    '{
        "viagens": {"read": true, "write": true, "delete": true},
        "clientes": {"read": true, "write": true, "delete": true},
        "onibus": {"read": true, "write": true, "delete": true},
        "financeiro": {"read": true, "write": true, "delete": true},
        "relatorios": {"read": true, "write": true, "delete": true},
        "configuracoes": {"read": true, "write": true, "delete": true},
        "usuarios": {"read": true, "write": true, "delete": true}
    }'::jsonb
) ON CONFLICT (user_id, organization_id) DO UPDATE SET
    permissions = EXCLUDED.permissions;

-- 7. VERIFICAR SE AS ASSINATURAS E CONFIGURAÇÕES FORAM CRIADAS
-- =====================================================

-- Verificar assinaturas
SELECT 
    'ASSINATURAS:' as info,
    o.name as organization_name,
    os.status,
    os.trial_end_date
FROM organizations o
LEFT JOIN organization_subscriptions os ON o.id = os.organization_id
ORDER BY o.name;

-- Verificar configurações
SELECT 
    'CONFIGURAÇÕES:' as info,
    o.name as organization_name,
    ost.cor_primaria,
    ost.cor_secundaria
FROM organizations o
LEFT JOIN organization_settings ost ON o.id = ost.organization_id
ORDER BY o.name;

-- Verificar suas permissões
SELECT 
    'SUAS PERMISSÕES:' as info,
    permissions
FROM user_permissions 
WHERE user_id = '01e58a5e-d3f7-462c-8621-3ea65fc267c0';

-- 8. TESTE FINAL COMPLETO
-- =====================================================

-- Verificar se você consegue acessar dados da sua organização
SELECT 
    'TESTE ORGANIZAÇÃO:' as info,
    COUNT(*) as viagens_acessiveis
FROM viagens 
WHERE organization_id = '9f3c25e8-7bef-49f3-8528-1f3dbadaea15';

SELECT 
    'TESTE CLIENTES:' as info,
    COUNT(*) as clientes_acessiveis
FROM clientes 
WHERE organization_id = '9f3c25e8-7bef-49f3-8528-1f3dbadaea15';

-- Verificar se as policies estão funcionando
SELECT 
    'POLICIES FUNCIONANDO:' as info,
    COUNT(*) as profiles_visiveis
FROM profiles;

-- =====================================================
-- VERIFICAÇÃO FINAL DO SISTEMA
-- =====================================================

-- Status completo do seu usuário
SELECT 
    'STATUS COMPLETO:' as info,
    p.email,
    p.role,
    o.name as organization_name,
    os.status as subscription_status,
    CASE 
        WHEN EXISTS (SELECT 1 FROM super_admin_users WHERE user_id = p.id) 
        THEN 'Super Admin ✅' 
        ELSE 'Usuário Normal' 
    END as super_admin_status
FROM profiles p
LEFT JOIN organizations o ON p.organization_id = o.id
LEFT JOIN organization_subscriptions os ON o.id = os.organization_id
WHERE p.email = 'daniel.manske@gmail.com';

-- =====================================================
-- INSTRUÇÕES FINAIS
-- =====================================================
/*
APÓS EXECUTAR ESTE SQL:

1. ✅ O constraint de role será corrigido
2. ✅ Você será owner da GoFans Development
3. ✅ Suas permissões serão criadas
4. ✅ O sistema multi-tenant funcionará

PRÓXIMOS PASSOS:
1. Execute este SQL
2. Reinicie o servidor (npm run dev)
3. Faça login novamente
4. O banner de status deve aparecer
5. Teste as funcionalidades

Se ainda houver problemas, me avise!
*/