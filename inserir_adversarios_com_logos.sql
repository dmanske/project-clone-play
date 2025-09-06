-- Script SQL para inserir adversários com logos no projeto multi-tenant
-- Execute este script no banco de dados multi-tenant

-- Obter o organization_id da organização atual
DO $$
DECLARE
    org_id UUID;
    rec RECORD;
    total_count INTEGER;
BEGIN
    -- Buscar o primeiro organization_id disponível
    SELECT id INTO org_id FROM organizations LIMIT 1;
    
    IF org_id IS NULL THEN
        RAISE EXCEPTION 'Nenhuma organização encontrada. Crie uma organização primeiro.';
    END IF;
    
    RAISE NOTICE 'Usando organization_id: %', org_id;
    
    -- Inserir adversários com logos
    INSERT INTO adversarios (organization_id, nome, logo_url)
    VALUES 
        (org_id, 'Fluminense', 'https://logodetimes.com/times/fluminense'),
        (org_id, 'Atlético Mineiro', 'https://logodetimes.com/times/atletico-mineiro'),
        (org_id, 'Botafogo', 'https://logodetimes.com/times/botafogo'),
        (org_id, 'Volta', 'https://logodetimes.com/times/volta'),
        (org_id, 'Fortaleza', 'https://logodetimes.com/times/fortaleza'),
        (org_id, 'Santos', 'https://logodetimes.com/times/santos/logo'),
        (org_id, 'Sport', 'https://logodetimes.com/times/sport-recife'),
        (org_id, 'São Paulo', 'https://logodetimes.com/times/sao-paulo'),
        (org_id, 'Vasco da Gama', 'https://logodetimes.com/times/vasco-da-gama'),
        (org_id, 'Cruzeiro', 'https://logodetimes.com/times/cruzeiro/logo'),
        (org_id, 'Grêmio', 'https://logodetimes.com/times/gremio/logo'),
        (org_id, 'Red Bull Bragantino', 'https://logodetimes.com/times/bragantino'),
        (org_id, 'Bahia', 'https://logodetimes.com/times/bahia/logo'),
        (org_id, 'Juventude', 'https://logodetimes.com/times/juventude'),
        (org_id, 'Mirassol', 'https://logodetimes.com/times/mirassol/'),
        (org_id, 'Internacional', 'https://logodetimes.com/times/internacional'),
        (org_id, 'Ceará', 'https://logodetimes.com/times/ceara/logo'),
        (org_id, 'Corinthians', 'https://logodetimes.com/times/corinthians'),
        (org_id, 'Palmeiras', 'https://logodetimes.com/times/palmeiras'),
        (org_id, 'Flamengo', 'https://logodetimes.com/times/flamengo');
    
    RAISE NOTICE 'Adversários inseridos com sucesso!';
     
     -- Verificar dados inseridos
     RAISE NOTICE 'Dados inseridos:';
     FOR rec IN 
         SELECT nome, logo_url 
         FROM adversarios 
         WHERE organization_id = org_id
         ORDER BY nome
     LOOP
         RAISE NOTICE 'Time: % - Logo: %', rec.nome, rec.logo_url;
     END LOOP;
     
     -- Contar total de adversários inseridos
     SELECT COUNT(*) INTO total_count 
     FROM adversarios
     WHERE organization_id = org_id;
     
     RAISE NOTICE 'Total de adversários inseridos: %', total_count;
END $$;

-- Consultas para verificar os dados inseridos
-- (Execute estas consultas separadamente se desejar ver os resultados em formato de tabela)

-- Listar todos os adversários inseridos
SELECT 
    id,
    organization_id,
    nome,
    logo_url,
    ativo,
    created_at
FROM adversarios 
ORDER BY nome;

-- Contar total de adversários por organização
SELECT 
    organization_id,
    COUNT(*) as total_adversarios
FROM adversarios 
GROUP BY organization_id
ORDER BY total_adversarios DESC;