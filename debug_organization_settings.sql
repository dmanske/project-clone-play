-- Debug da tabela organization_settings

-- 1. Verificar se a tabela existe
SELECT 
    'organization_settings' as tabela,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organization_settings' AND table_schema = 'public') 
        THEN 'EXISTE' 
        ELSE 'NÃO EXISTE' 
    END as status;

-- 2. Se existe, mostrar todas as colunas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'organization_settings'
ORDER BY ordinal_position;

-- 3. Verificar se a coluna nome_empresa especificamente existe
SELECT 
    'nome_empresa' as coluna,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
                AND table_name = 'organization_settings' 
                AND column_name = 'nome_empresa'
        ) 
        THEN 'EXISTE' 
        ELSE 'NÃO EXISTE' 
    END as status;

-- 4. Listar todas as migrações aplicadas
SELECT version, name, executed_at 
FROM supabase_migrations.schema_migrations 
WHERE name LIKE '%organization_settings%' 
OR version LIKE '%20250124000005%'
ORDER BY executed_at DESC;

-- 5. Verificar dados na tabela (se existir)
SELECT COUNT(*) as total_registros FROM organization_settings;

-- 6. Tentar fazer um SELECT simples para ver o erro
SELECT organization_id, nome_empresa FROM organization_settings LIMIT 1;