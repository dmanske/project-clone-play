-- Script para verificar se o usuário atual tem organization_id configurado
-- Execute este script no banco de dados para diagnosticar o problema

-- 1. Verificar o perfil do usuário atual
SELECT 
    id,
    email,
    full_name,
    organization_id,
    role,
    active,
    created_at
FROM profiles 
WHERE id = auth.uid();

-- 2. Verificar se existem organizações disponíveis
SELECT 
    id,
    name,
    created_at
FROM organizations
ORDER BY created_at ASC;

-- 3. Verificar se o usuário tem organization_id NULL
SELECT 
    'Usuário sem organização' as status,
    COUNT(*) as total_usuarios
FROM profiles 
WHERE organization_id IS NULL;

-- 4. Script para atualizar usuário com a primeira organização disponível
-- (Execute apenas se necessário)
/*
UPDATE profiles 
SET organization_id = (
    SELECT id FROM organizations 
    ORDER BY created_at ASC 
    LIMIT 1
)
WHERE id = auth.uid() AND organization_id IS NULL;
*/

-- 5. Verificar adversários existentes
SELECT 
    COUNT(*) as total_adversarios,
    organization_id
FROM adversarios
GROUP BY organization_id;

-- 6. Verificar se a tabela adversarios tem dados
SELECT COUNT(*) as total_adversarios_geral FROM adversarios;