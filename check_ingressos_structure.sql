-- Verificar estrutura atual da tabela ingressos
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'ingressos'
ORDER BY ordinal_position;

-- Verificar se a VIEW ingressos_com_cliente existe
SELECT 
    'ingressos_com_cliente' as view_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'ingressos_com_cliente')
        THEN 'EXISTE'
        ELSE 'NÃO EXISTE'
    END as status;

-- Se a VIEW existe, mostrar sua definição
SELECT definition 
FROM pg_views 
WHERE viewname = 'ingressos_com_cliente';