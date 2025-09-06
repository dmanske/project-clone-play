-- Verificar estrutura da tabela empresa_config
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresa_config'
ORDER BY ordinal_position;

-- Verificar políticas RLS existentes para empresa_config
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
WHERE tablename = 'empresa_config';

-- Verificar políticas RLS existentes para viagem_receitas
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
WHERE tablename = 'viagem_receitas';}}}