-- SQL para verificar a estrutura do banco e identificar problemas

-- 1. Verificar se a tabela passageiro_passeios existe
SELECT 
    'passageiro_passeios' as tabela,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'passageiro_passeios') 
        THEN 'EXISTE' 
        ELSE 'NÃO EXISTE' 
    END as status;

-- 2. Verificar se a coluna organization_id existe na tabela empresa_config
SELECT 
    'empresa_config.organization_id' as coluna,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'empresa_config' AND column_name = 'organization_id'
        ) 
        THEN 'EXISTE' 
        ELSE 'NÃO EXISTE' 
    END as status;

-- 3. Verificar estrutura completa da tabela empresa_config
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresa_config'
ORDER BY ordinal_position;

-- 4. Verificar políticas RLS existentes para empresa_config
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

-- 5. Verificar políticas RLS existentes para viagem_receitas
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
WHERE tablename = 'viagem_receitas';

-- 6. Verificar se as tabelas do sistema financeiro existem
SELECT 
    table_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = t.table_name) 
        THEN 'EXISTE' 
        ELSE 'NÃO EXISTE' 
    END as status
FROM (
    VALUES 
    ('viagem_receitas'),
    ('viagem_despesas'),
    ('viagem_cobranca_historico'),
    ('viagem_orcamento'),
    ('viagem_passageiros_parcelas'),
    ('passageiro_passeios')
) AS t(table_name);

-- 7. Verificar se a tabela organizations existe
SELECT 
    'organizations' as tabela,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organizations') 
        THEN 'EXISTE' 
        ELSE 'NÃO EXISTE' 
    END as status;

-- 8. Listar todas as tabelas do schema public
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;