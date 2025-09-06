-- SQL para buscar adversários com logos no projeto original
-- Execute este SQL no banco de dados original e me envie o resultado

SELECT 
    nome,
    logo_url,
    cidade,
    estado,
    ativo,
    created_at
FROM adversarios 
WHERE logo_url IS NOT NULL 
  AND logo_url != '' 
  AND ativo = true
ORDER BY nome;

-- Também buscar dados da tabela ingressos para ver quais adversários já foram usados
SELECT DISTINCT 
    adversario,
    logo_adversario,
    COUNT(*) as total_jogos
FROM ingressos 
WHERE adversario IS NOT NULL 
  AND adversario != ''
GROUP BY adversario, logo_adversario
ORDER BY total_jogos DESC, adversario;

-- Verificar se existe tabela de times/clubes com logos
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE (column_name ILIKE '%logo%' OR column_name ILIKE '%adversario%' OR column_name ILIKE '%time%' OR column_name ILIKE '%clube%')
  AND table_schema = 'public'
ORDER BY table_name, column_name;