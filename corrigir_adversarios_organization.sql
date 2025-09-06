-- Script para corrigir o problema dos adversários
-- Verificar e corrigir organization_id na tabela adversarios

-- 1. Verificar estrutura atual
SELECT 'Estrutura da tabela adversarios:' as info;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'adversarios' AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Verificar dados atuais
SELECT 'Dados atuais:' as info;
SELECT 
    COUNT(*) as total_adversarios,
    COUNT(CASE WHEN organization_id IS NULL THEN 1 END) as sem_organization_id,
    COUNT(CASE WHEN organization_id IS NOT NULL THEN 1 END) as com_organization_id
FROM adversarios;

-- 3. Buscar a primeira organização disponível
SELECT 'Organizações disponíveis:' as info;
SELECT id, name FROM organizations LIMIT 3;

-- 4. Atualizar adversários sem organization_id
-- (Substitua 'ORGANIZATION_ID_AQUI' pelo ID real da organização)
DO $$
DECLARE
    org_id uuid;
BEGIN
    -- Buscar a primeira organização
    SELECT id INTO org_id FROM organizations LIMIT 1;
    
    IF org_id IS NOT NULL THEN
        -- Atualizar adversários sem organization_id
        UPDATE adversarios 
        SET organization_id = org_id 
        WHERE organization_id IS NULL;
        
        RAISE NOTICE 'Adversários atualizados com organization_id: %', org_id;
    ELSE
        RAISE NOTICE 'Nenhuma organização encontrada!';
    END IF;
END $$;

-- 5. Verificar resultado
SELECT 'Resultado após atualização:' as info;
SELECT 
    COUNT(*) as total_adversarios,
    COUNT(CASE WHEN organization_id IS NULL THEN 1 END) as sem_organization_id,
    COUNT(CASE WHEN organization_id IS NOT NULL THEN 1 END) as com_organization_id
FROM adversarios;

-- 6. Mostrar alguns registros atualizados
SELECT 'Exemplos de adversários:' as info;
SELECT id, nome, organization_id, ativo
FROM adversarios 
ORDER BY nome
LIMIT 5;

-- 7. Testar a query que será usada no frontend
SELECT 'Teste da query do frontend:' as info;
SELECT id, nome, logo_url, ativo, organization_id
FROM adversarios 
WHERE organization_id = (SELECT id FROM organizations LIMIT 1)
  AND nome != 'Flamengo'
ORDER BY nome;