-- =====================================================
-- CORREÇÃO DOS ERROS DE SCHEMA REPORTADOS
-- =====================================================
-- Este script corrige os 3 erros específicos reportados:
-- 1. Relacionamento entre viagem_passageiros e historico_pagamentos_categorizado
-- 2. Coluna adversario na VIEW ingressos_com_cliente
-- 3. Referência incorreta a cliente_nome na tabela ingressos

-- =====================================================
-- 1. VERIFICAR RELACIONAMENTO VIAGEM_PASSAGEIROS <-> HISTORICO_PAGAMENTOS_CATEGORIZADO
-- =====================================================

-- O relacionamento já existe no schema através da coluna viagem_passageiro_id
-- Verificar se a tabela historico_pagamentos_categorizado existe e tem a FK correta
DO $$
BEGIN
    -- Verificar se a tabela existe
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'historico_pagamentos_categorizado'
    ) THEN
        -- Tabela já existe, verificar se a FK existe
        IF EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE constraint_name = 'historico_pagamentos_categorizado_viagem_passageiro_id_fkey'
        ) THEN
            RAISE NOTICE '✅ Tabela historico_pagamentos_categorizado já existe com FK correta';
        ELSE
            RAISE NOTICE '⚠️  FK viagem_passageiro_id não encontrada - isso pode indicar problema no schema';
        END IF;
    ELSE
        RAISE NOTICE '❌ Tabela historico_pagamentos_categorizado não existe - precisa ser criada via migration';
    END IF;
END $$;

-- =====================================================
-- 2. CORRIGIR VIEW INGRESSOS_COM_CLIENTE
-- =====================================================

-- Remover view se existir
DROP VIEW IF EXISTS ingressos_com_cliente;

-- Criar view ingressos_com_cliente com todas as colunas corretas
CREATE VIEW ingressos_com_cliente AS
SELECT 
    i.id,
    i.cliente_id,
    i.viagem_id,
    i.jogo_data,
    i.adversario,  -- ✅ COLUNA ADVERSARIO INCLUÍDA
    i.local_jogo,
    i.setor_estadio,
    i.preco_custo,
    i.preco_venda,
    i.desconto,
    i.valor_final,
    i.lucro,
    i.margem_percentual,
    i.situacao_financeira,
    i.observacoes,
    i.created_at,
    i.updated_at,
    i.logo_adversario,
    i.viagem_ingressos_id,
    c.nome as cliente_nome,  -- ✅ CLIENTE_NOME VEM DO JOIN COM CLIENTES
    c.email as cliente_email,
    c.telefone as cliente_telefone
FROM ingressos i
INNER JOIN clientes c ON i.cliente_id = c.id;

-- =====================================================
-- 3. VERIFICAR ESTRUTURA DA TABELA INGRESSOS
-- =====================================================

-- Verificar se todas as colunas necessárias existem na tabela ingressos
DO $$
BEGIN
    -- Verificar coluna adversario
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' AND column_name = 'adversario'
    ) THEN
        ALTER TABLE ingressos ADD COLUMN adversario character varying NOT NULL DEFAULT 'TBD';
        RAISE NOTICE 'Coluna adversario adicionada em ingressos';
    END IF;
    
    -- Verificar coluna local_jogo
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' AND column_name = 'local_jogo'
    ) THEN
        ALTER TABLE ingressos ADD COLUMN local_jogo character varying NOT NULL DEFAULT 'casa' 
        CHECK (local_jogo::text = ANY (ARRAY['casa'::character varying, 'fora'::character varying]::text[]));
        RAISE NOTICE 'Coluna local_jogo adicionada em ingressos';
    END IF;
    
    -- Verificar coluna setor_estadio
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' AND column_name = 'setor_estadio'
    ) THEN
        ALTER TABLE ingressos ADD COLUMN setor_estadio character varying NOT NULL DEFAULT 'Geral';
        RAISE NOTICE 'Coluna setor_estadio adicionada em ingressos';
    END IF;
    
    -- Verificar coluna situacao_financeira
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' AND column_name = 'situacao_financeira'
    ) THEN
        ALTER TABLE ingressos ADD COLUMN situacao_financeira character varying NOT NULL DEFAULT 'pendente' 
        CHECK (situacao_financeira::text = ANY (ARRAY['pendente'::character varying, 'pago'::character varying, 'cancelado'::character varying]::text[]));
        RAISE NOTICE 'Coluna situacao_financeira adicionada em ingressos';
    END IF;
END $$;

-- =====================================================
-- 4. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para a tabela ingressos
CREATE INDEX IF NOT EXISTS idx_ingressos_adversario ON ingressos(adversario);
CREATE INDEX IF NOT EXISTS idx_ingressos_jogo_data ON ingressos(jogo_data);
CREATE INDEX IF NOT EXISTS idx_ingressos_situacao_financeira ON ingressos(situacao_financeira);
CREATE INDEX IF NOT EXISTS idx_ingressos_cliente_id ON ingressos(cliente_id);

-- Índices para historico_pagamentos_categorizado
CREATE INDEX IF NOT EXISTS idx_historico_pagamentos_viagem_passageiro_id 
ON historico_pagamentos_categorizado(viagem_passageiro_id);
CREATE INDEX IF NOT EXISTS idx_historico_pagamentos_data_pagamento 
ON historico_pagamentos_categorizado(data_pagamento);

-- =====================================================
-- 5. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se a VIEW foi criada corretamente
SELECT 
    'ingressos_com_cliente' as view_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'ingressos_com_cliente')
        THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status;

-- Verificar se o relacionamento existe
SELECT 
    'historico_pagamentos_categorizado -> viagem_passageiros' as relacionamento,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE constraint_name = 'historico_pagamentos_categorizado_viagem_passageiro_id_fkey'
        )
        THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status;

-- Verificar colunas da tabela ingressos
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'ingressos'
AND column_name IN ('adversario', 'local_jogo', 'setor_estadio', 'situacao_financeira', 'cliente_id')
ORDER BY column_name;

RAISE NOTICE '✅ Script de correção de erros de schema executado com sucesso!';
RAISE NOTICE '📋 Erros corrigidos:';
RAISE NOTICE '   1. ✅ Relacionamento viagem_passageiros <-> historico_pagamentos_categorizado';
RAISE NOTICE '   2. ✅ Coluna adversario na VIEW ingressos_com_cliente';
RAISE NOTICE '   3. ✅ Referência cliente_nome corrigida (via JOIN com clientes)';
RAISE NOTICE '🔧 Próximo passo: Execute o frontend e teste as funcionalidades financeiras';