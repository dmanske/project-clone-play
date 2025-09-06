-- Script simplificado para inserir adversários após criar a tabela organizations
-- Execute APÓS executar o create_organizations_table.sql

-- =====================================================
-- 1. VERIFICAR SE A ORGANIZAÇÃO EXISTE
-- =====================================================

SELECT 
    'VERIFICAÇÃO INICIAL' as status,
    id,
    name as nome,
    slug
FROM organizations
ORDER BY created_at;

-- =====================================================
-- 2. INSERIR ADVERSÁRIOS USANDO A ORGANIZAÇÃO PADRÃO
-- =====================================================

-- Criar constraint única se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'adversarios_nome_organization_unique'
    ) THEN
        ALTER TABLE adversarios 
        ADD CONSTRAINT adversarios_nome_organization_unique 
        UNIQUE (nome, organization_id);
    END IF;
END $$;

-- Inserir adversários usando a organização padrão diretamente
INSERT INTO adversarios (id, nome, logo_url, ativo, organization_id) VALUES
(gen_random_uuid(), 'Flamengo', 'https://logoeps.com/wp-content/uploads/2013/03/flamengo-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Corinthians', 'https://logoeps.com/wp-content/uploads/2013/03/corinthians-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Palmeiras', 'https://logoeps.com/wp-content/uploads/2013/03/palmeiras-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'São Paulo', 'https://logoeps.com/wp-content/uploads/2013/03/sao-paulo-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Santos', 'https://logoeps.com/wp-content/uploads/2013/03/santos-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Vasco da Gama', 'https://logoeps.com/wp-content/uploads/2013/03/vasco-da-gama-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Botafogo', 'https://logoeps.com/wp-content/uploads/2013/03/botafogo-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Fluminense', 'https://logoeps.com/wp-content/uploads/2013/03/fluminense-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Grêmio', 'https://logoeps.com/wp-content/uploads/2013/03/gremio-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Internacional', 'https://logoeps.com/wp-content/uploads/2013/03/internacional-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Atlético Mineiro', 'https://logoeps.com/wp-content/uploads/2013/03/atletico-mineiro-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Cruzeiro', 'https://logoeps.com/wp-content/uploads/2013/03/cruzeiro-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Bahia', 'https://logoeps.com/wp-content/uploads/2013/03/bahia-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Sport Recife', 'https://logoeps.com/wp-content/uploads/2013/03/sport-recife-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Ceará', 'https://logoeps.com/wp-content/uploads/2013/03/ceara-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Fortaleza', 'https://logoeps.com/wp-content/uploads/2013/03/fortaleza-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Athletico Paranaense', 'https://logoeps.com/wp-content/uploads/2013/03/athletico-paranaense-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Coritiba', 'https://logoeps.com/wp-content/uploads/2013/03/coritiba-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Goiás', 'https://logoeps.com/wp-content/uploads/2013/03/goias-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens')),
(gen_random_uuid(), 'Atlético Goianiense', 'https://logoeps.com/wp-content/uploads/2013/03/atletico-goianiense-vector-logo.png', true, (SELECT id FROM organizations WHERE slug = 'neto-viagens'))
ON CONFLICT (nome, organization_id) DO UPDATE SET
    logo_url = EXCLUDED.logo_url,
    ativo = EXCLUDED.ativo;

-- =====================================================
-- 3. VERIFICAÇÕES FINAIS
-- =====================================================

-- Contar adversários inseridos
SELECT 
    'ADVERSÁRIOS INSERIDOS' as status,
    COUNT(*) as total_adversarios
FROM adversarios 
WHERE organization_id = (SELECT id FROM organizations WHERE slug = 'neto-viagens');

-- Listar alguns adversários
SELECT 
    'LISTA DE ADVERSÁRIOS' as status,
    nome,
    ativo,
    organization_id
FROM adversarios 
WHERE organization_id = (SELECT id FROM organizations WHERE slug = 'neto-viagens')
ORDER BY nome
LIMIT 10;

-- Verificar se o usuário atual pode ver os adversários
SELECT 
    'TESTE ACESSO USUÁRIO' as status,
    COUNT(*) as adversarios_visiveis
FROM adversarios a
INNER JOIN profiles p ON a.organization_id = p.organization_id
WHERE p.id = auth.uid();

-- =====================================================
-- INSTRUÇÕES:
-- =====================================================
/*
1. Execute primeiro o create_organizations_table.sql
2. Execute este script para inserir os adversários
3. Verifique se os adversários foram inseridos corretamente
4. Teste a aplicação para ver se os adversários aparecem

Este script:
✅ Usa a organização padrão diretamente (não depende do JWT)
✅ Insere 20 times brasileiros populares
✅ Configura constraint única por organização
✅ Inclui verificações para confirmar o sucesso
✅ Testa se o usuário atual pode acessar os dados
*/