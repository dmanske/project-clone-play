-- SQL para verificar a estrutura da tabela empresa_config no projeto original
-- Execute este comando no seu banco de dados original

-- 1. Verificar se a tabela existe
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_name = 'empresa_config';

-- 2. Listar todas as colunas da tabela empresa_config
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresa_config'
ORDER BY ordinal_position;

-- 3. Verificar índices da tabela
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'empresa_config';

-- 4. Verificar constraints
SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'empresa_config'::regclass;

-- 5. Verificar se existe a coluna organization_id
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'empresa_config' 
            AND column_name = 'organization_id'
        ) 
        THEN 'SIM - Coluna organization_id existe'
        ELSE 'NÃO - Coluna organization_id não existe'
    END as organization_id_status;

-- 6. Contar registros na tabela
SELECT COUNT(*) as total_registros FROM empresa_config;

-- 7. Mostrar um exemplo de registro (se existir)
SELECT * FROM empresa_config LIMIT 1;