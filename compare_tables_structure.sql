-- SQL para comparar estrutura de tabelas entre projeto original e multi-tenant
-- Execute este comando no seu banco de dados original

-- 1. Listar TODAS as tabelas do projeto original
SELECT 
    table_name,
    table_type,
    CASE 
        WHEN table_name IN (
            'organizations', 'profiles', 'super_admin_users', 'user_invitations', 
            'user_permissions', 'organization_subscriptions'
        ) THEN 'NOVA - Multi-tenant'
        ELSE 'ORIGINAL'
    END as status_tabela
FROM information_schema.tables 
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Verificar quais tabelas do original NÃO têm organization_id
SELECT 
    t.table_name,
    CASE 
        WHEN c.column_name IS NOT NULL THEN 'TEM organization_id'
        ELSE 'NÃO TEM organization_id'
    END as organization_id_status
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON (
    t.table_name = c.table_name 
    AND c.column_name = 'organization_id'
)
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('organizations', 'profiles', 'super_admin_users')
ORDER BY t.table_name;

-- 3. Contar registros em cada tabela principal
SELECT 
    'clientes' as tabela, COUNT(*) as total_registros FROM clientes
UNION ALL
SELECT 
    'viagens' as tabela, COUNT(*) as total_registros FROM viagens
UNION ALL
SELECT 
    'viagem_passageiros' as tabela, COUNT(*) as total_registros FROM viagem_passageiros
UNION ALL
SELECT 
    'onibus' as tabela, COUNT(*) as total_registros FROM onibus
UNION ALL
SELECT 
    'ingressos' as tabela, COUNT(*) as total_registros FROM ingressos
UNION ALL
SELECT 
    'empresa_config' as tabela, COUNT(*) as total_registros FROM empresa_config
ORDER BY tabela;

-- 4. Verificar se existem tabelas que podem ser removidas (sem dados)
SELECT 
    table_name,
    'Tabela vazia - pode ser analisada para remoção' as observacao
FROM information_schema.tables t
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    AND NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns c 
        WHERE c.table_name = t.table_name 
        AND c.column_name = 'id'
    )
ORDER BY table_name;

-- 5. Verificar dependências entre tabelas (foreign keys)
SELECT 
    tc.table_name as tabela_origem,
    kcu.column_name as coluna_origem,
    ccu.table_name as tabela_referenciada,
    ccu.column_name as coluna_referenciada
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name, kcu.column_name;