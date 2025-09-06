-- SQL para verificar o estado da tabela organization_settings

-- 1. Verificar se a tabela existe
SELECT 
    'organization_settings' as tabela,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organization_settings' AND table_schema = 'public') 
        THEN 'EXISTE' 
        ELSE 'NÃO EXISTE' 
    END as status;

-- 2. Mostrar estrutura da tabela (se existir)
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'organization_settings'
ORDER BY ordinal_position;

-- 3. Verificar especificamente a coluna nome_empresa
SELECT 
    'nome_empresa' as coluna_verificada,
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

-- 4. Contar registros na tabela (se existir)
SELECT COUNT(*) as total_registros 
FROM organization_settings;

-- 5. Mostrar sample dos dados (se existir)
-- Comentado temporariamente devido ao erro de coluna inexistente
-- SELECT organization_id, nome_empresa, cor_primaria, cor_secundaria 
-- FROM organization_settings 
-- LIMIT 3;

-- Alternativa: mostrar todas as colunas disponíveis
SELECT * FROM organization_settings LIMIT 3;