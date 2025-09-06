-- Script simples para buscar dados básicos dos adversários no banco de dados original
-- Execute este script no banco de dados original

SELECT 
    id,
    nome,
    logo_url
FROM adversarios 
ORDER BY nome;