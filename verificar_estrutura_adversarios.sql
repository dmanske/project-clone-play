-- Verificar se a coluna organization_id existe na tabela adversarios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'adversarios' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar se há dados na tabela adversarios
SELECT 
    COUNT(*) as total_adversarios,
    COUNT(CASE WHEN organization_id IS NULL THEN 1 END) as sem_organization_id,
    COUNT(CASE WHEN organization_id IS NOT NULL THEN 1 END) as com_organization_id
FROM adversarios;

-- Verificar alguns registros de exemplo
SELECT id, nome, organization_id, ativo, created_at
FROM adversarios 
LIMIT 5;

-- Verificar se há alguma organização específica nos dados
SELECT DISTINCT organization_id
FROM adversarios 
WHERE organization_id IS NOT NULL;