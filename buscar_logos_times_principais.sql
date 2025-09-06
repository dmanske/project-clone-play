-- SQL adicional para buscar logos dos principais times brasileiros
-- Execute este também no projeto original

-- Buscar por times específicos que provavelmente têm logos
SELECT 
    nome,
    logo_url,
    cidade,
    estado
FROM adversarios 
WHERE nome ILIKE ANY(ARRAY[
    '%Fluminense%',
    '%Botafogo%', 
    '%Vasco%',
    '%Palmeiras%',
    '%Corinthians%',
    '%São Paulo%',
    '%Santos%',
    '%Grêmio%',
    '%Internacional%',
    '%Atlético%',
    '%Cruzeiro%',
    '%Bahia%',
    '%Fortaleza%',
    '%Ceará%',
    '%Sport%',
    '%Náutico%',
    '%Santa Cruz%'
])
ORDER BY nome;

-- Buscar URLs de logos que seguem padrões comuns
SELECT 
    nome,
    logo_url
FROM adversarios 
WHERE logo_url ILIKE ANY(ARRAY[
    '%logodetimes%',
    '%logoeps%',
    '%escudos%',
    '%brasoes%',
    '%futebol%',
    '%times%',
    '%clubes%'
])
ORDER BY nome;

-- Verificar dados nas 3 tabelas principais
SELECT 
    'adversarios' as tabela,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN logo_url IS NOT NULL AND logo_url != '' THEN 1 END) as com_logo
FROM adversarios
UNION ALL
SELECT 
    'ingressos' as tabela,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN logo_adversario IS NOT NULL AND logo_adversario != '' THEN 1 END) as com_logo
FROM ingressos
UNION ALL
SELECT 
    'viagens' as tabela,
    COUNT(*) as total_registros,
    0 as com_logo -- viagens não tem coluna de logo
FROM viagens;

-- Verificar estrutura das tabelas
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name IN ('adversarios', 'ingressos', 'viagens')
    AND column_name ILIKE '%logo%'
ORDER BY table_name, column_name;