-- Script SQL para buscar todos os times e logos do banco de dados original
-- Execute este SQL no banco de dados ORIGINAL para obter os dados dos adversários

-- 1. Buscar todos os adversários da tabela adversarios (se existir)
SELECT 
    'adversarios' as origem_tabela,
    nome as time_adversario,
    logo_url,
    cidade,
    estado,
    ativo,
    created_at
FROM adversarios 
WHERE logo_url IS NOT NULL 
  AND logo_url != ''
ORDER BY nome;

-- 2. Buscar adversários únicos da tabela ingressos com logos
SELECT 
    'ingressos' as origem_tabela,
    adversario as time_adversario,
    logo_adversario as logo_url,
    COUNT(*) as total_jogos,
    MIN(data_evento) as primeiro_jogo,
    MAX(data_evento) as ultimo_jogo
FROM ingressos 
WHERE adversario IS NOT NULL 
  AND adversario != ''
  AND logo_adversario IS NOT NULL
  AND logo_adversario != ''
GROUP BY adversario, logo_adversario
ORDER BY total_jogos DESC, adversario;

-- 3. Buscar todos os adversários únicos (com e sem logo) da tabela ingressos
SELECT 
    'ingressos_todos' as origem_tabela,
    adversario as time_adversario,
    logo_adversario as logo_url,
    COUNT(*) as total_jogos,
    COUNT(CASE WHEN logo_adversario IS NOT NULL AND logo_adversario != '' THEN 1 END) as jogos_com_logo,
    MIN(data_evento) as primeiro_jogo,
    MAX(data_evento) as ultimo_jogo
FROM ingressos 
WHERE adversario IS NOT NULL 
  AND adversario != ''
GROUP BY adversario, logo_adversario
ORDER BY total_jogos DESC, adversario;

-- 4. Buscar adversários da tabela viagens (se existir)
SELECT 
    'viagens' as origem_tabela,
    adversario as time_adversario,
    logo_adversario as logo_url,
    COUNT(*) as total_viagens,
    MIN(data_jogo) as primeira_viagem,
    MAX(data_jogo) as ultima_viagem
FROM viagens 
WHERE adversario IS NOT NULL 
  AND adversario != ''
GROUP BY adversario, logo_adversario
ORDER BY total_viagens DESC, adversario;

-- 5. Resumo geral - todos os times únicos encontrados
SELECT DISTINCT
    adversario as time_adversario,
    logo_adversario as logo_url,
    'ingressos' as fonte
FROM ingressos 
WHERE adversario IS NOT NULL AND adversario != ''

UNION

SELECT DISTINCT
    nome as time_adversario,
    logo_url,
    'adversarios' as fonte
FROM adversarios 
WHERE nome IS NOT NULL AND nome != ''

UNION

SELECT DISTINCT
    adversario as time_adversario,
    logo_adversario as logo_url,
    'viagens' as fonte
FROM viagens 
WHERE adversario IS NOT NULL AND adversario != ''

ORDER BY time_adversario;

-- 6. Verificar estrutura das tabelas relacionadas a times/adversários
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE (column_name ILIKE '%logo%' 
   OR column_name ILIKE '%adversario%' 
   OR column_name ILIKE '%time%' 
   OR column_name ILIKE '%clube%'
   OR table_name ILIKE '%adversario%'
   OR table_name ILIKE '%time%')
  AND table_schema = 'public'
ORDER BY table_name, column_name;