-- Script para inserir adversários do banco original no projeto multi-tenant
-- Exclui o Estudiantes conforme solicitado
-- Este script usa automaticamente o organization_id do usuário logado
-- Execute este script no banco de dados multi-tenant

-- Função para obter o organization_id do usuário atual
-- Cada organização terá seus próprios adversários isolados

-- Criar constraint única se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'adversarios_nome_organization_unique'
        AND table_name = 'adversarios'
    ) THEN
        ALTER TABLE adversarios 
        ADD CONSTRAINT adversarios_nome_organization_unique 
        UNIQUE (nome, organization_id);
    END IF;
END $$;

INSERT INTO adversarios (id, nome, logo_url, ativo, organization_id, created_at)
VALUES 
    (gen_random_uuid(), 'Atlético Mineiro', 'https://logodetimes.com/times/atletico-mineiro/logo-atletico-mineiro-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Bahia', 'https://logodetimes.com/times/bahia/logo-bahia-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Botafogo', 'https://logodetimes.com/times/botafogo/logo-botafogo-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Ceará', 'https://logodetimes.com/times/ceara/logo-ceara-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Corinthians', 'https://logodetimes.com/times/corinthians/logo-corinthians-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Cruzeiro', 'https://logodetimes.com/times/cruzeiro/logo-cruzeiro-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Flamengo', 'https://logodetimes.com/times/flamengo/logo-flamengo-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Fluminense', 'https://logodetimes.com/times/fluminense/logo-fluminense-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Fortaleza', 'https://logodetimes.com/times/fortaleza/logo-fortaleza-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Grêmio', 'https://logodetimes.com/times/gremio/logo-gremio-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Internacional', 'https://logodetimes.com/times/internacional/logo-internacional-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Juventude', 'https://logodetimes.com/times/juventude/logo-juventude-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Mirassol', 'https://logodetimes.com/times/mirassol/logo-mirassol-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Palmeiras', 'https://logodetimes.com/times/palmeiras/logo-palmeiras-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Red Bull Bragantino', 'https://logodetimes.com/times/red-bull-bragantino/logo-red-bull-bragantino-2048.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Santos', 'https://logodetimes.com/times/santos/logo-santos-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'São Paulo', 'https://logodetimes.com/times/sao-paulo/logo-sao-paulo-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Sport', 'https://logodetimes.com/times/sport-recife/logo-sport-recife-4096.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Vasco da Gama', 'https://logodetimes.com/times/vasco-da-gama/logo-vasco-da-gama-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW()),
    (gen_random_uuid(), 'Vitória', 'https://logodetimes.com/times/vitoria/logo-vitoria-256.png', true, (auth.jwt() ->> 'organization_id')::uuid, NOW())
ON CONFLICT (nome, organization_id) DO UPDATE SET
    logo_url = EXCLUDED.logo_url,
    ativo = EXCLUDED.ativo;

-- Verificar se os dados foram inseridos corretamente
SELECT COUNT(*) as total_adversarios FROM adversarios WHERE organization_id = (auth.jwt() ->> 'organization_id')::uuid;

-- Listar todos os adversários inseridos
SELECT id, nome, logo_url FROM adversarios WHERE organization_id = (auth.jwt() ->> 'organization_id')::uuid ORDER BY nome;