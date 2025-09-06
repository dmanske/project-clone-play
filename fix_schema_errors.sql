-- =====================================================
-- CORREÇÃO COMPLETA DOS ERROS DE SCHEMA
-- Execute este SQL no Supabase para resolver todos os problemas
-- =====================================================

-- 1. ADICIONAR COLUNA CREATED_AT EM VIAGEM_PASSAGEIROS
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'viagem_passageiros' 
        AND column_name = 'created_at'
    ) THEN
        ALTER TABLE viagem_passageiros 
        ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        
        -- Atualizar registros existentes
        UPDATE viagem_passageiros 
        SET created_at = NOW() 
        WHERE created_at IS NULL;
        
        RAISE NOTICE 'Coluna created_at adicionada em viagem_passageiros';
    END IF;
END $$;

-- 2. CRIAR TABELA PASSAGEIRO_PASSEIOS
CREATE TABLE IF NOT EXISTS passageiro_passeios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_passageiro_id UUID NOT NULL REFERENCES viagem_passageiros(id) ON DELETE CASCADE,
    passeio_id UUID NOT NULL REFERENCES passeios(id) ON DELETE CASCADE,
    valor_cobrado DECIMAL(10,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'cancelado')),
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    UNIQUE(viagem_passageiro_id, passeio_id)
);

-- 3. GARANTIR ESTRUTURA CORRETA DA TABELA INGRESSOS
-- Adicionar colunas que podem estar faltando
DO $$
BEGIN
    -- Verificar e adicionar viagem_id se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'viagem_id'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN viagem_id UUID REFERENCES viagens(id) ON DELETE SET NULL;
        RAISE NOTICE 'Coluna viagem_id adicionada em ingressos';
    END IF;
    
    -- Verificar e adicionar outras colunas essenciais
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'jogo_data'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN jogo_data DATE;
        RAISE NOTICE 'Coluna jogo_data adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'adversario'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN adversario VARCHAR(255);
        RAISE NOTICE 'Coluna adversario adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'local_jogo'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN local_jogo VARCHAR(10) CHECK (local_jogo IN ('casa', 'fora'));
        RAISE NOTICE 'Coluna local_jogo adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'setor_estadio'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN setor_estadio VARCHAR(255);
        RAISE NOTICE 'Coluna setor_estadio adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'preco_custo'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN preco_custo DECIMAL(10,2) DEFAULT 0;
        RAISE NOTICE 'Coluna preco_custo adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'preco_venda'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN preco_venda DECIMAL(10,2) DEFAULT 0;
        RAISE NOTICE 'Coluna preco_venda adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'desconto'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN desconto DECIMAL(10,2) DEFAULT 0;
        RAISE NOTICE 'Coluna desconto adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'valor_final'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN valor_final DECIMAL(10,2);
        RAISE NOTICE 'Coluna valor_final adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'lucro'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN lucro DECIMAL(10,2);
        RAISE NOTICE 'Coluna lucro adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'margem_percentual'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN margem_percentual DECIMAL(5,2);
        RAISE NOTICE 'Coluna margem_percentual adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'situacao_financeira'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN situacao_financeira VARCHAR(20) DEFAULT 'pendente' CHECK (situacao_financeira IN ('pendente', 'pago', 'cancelado'));
        RAISE NOTICE 'Coluna situacao_financeira adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada em ingressos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingressos' 
        AND column_name = 'viagem_ingressos_id'
    ) THEN
        ALTER TABLE ingressos 
        ADD COLUMN viagem_ingressos_id UUID;
        RAISE NOTICE 'Coluna viagem_ingressos_id adicionada em ingressos';
    END IF;
END $$;

-- 4. CRIAR VIEW INGRESSOS_COM_CLIENTE
DROP VIEW IF EXISTS ingressos_com_cliente;

CREATE VIEW ingressos_com_cliente AS
SELECT 
    i.id,
    i.cliente_id,
    i.viagem_id,
    i.jogo_data,
    i.adversario,
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
    i.viagem_ingressos_id,
    c.nome as cliente_nome,
    c.email as cliente_email,
    c.telefone as cliente_telefone
FROM ingressos i
INNER JOIN clientes c ON i.cliente_id = c.id;

-- 5. HABILITAR RLS E CRIAR POLÍTICAS PARA PASSAGEIRO_PASSEIOS
ALTER TABLE passageiro_passeios ENABLE ROW LEVEL SECURITY;

-- Política para visualização
CREATE POLICY "Users can view passageiro_passeios from their organization" ON passageiro_passeios
FOR SELECT USING (
    organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    )
);

-- Política para gerenciamento
CREATE POLICY "Users can manage passageiro_passeios from their organization" ON passageiro_passeios
FOR ALL USING (
    organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    )
);

-- Política para service role
CREATE POLICY "Service role can manage all passageiro_passeios" ON passageiro_passeios
FOR ALL USING (auth.role() = 'service_role');

-- 6. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_passageiro_passeios_viagem_passageiro_id 
ON passageiro_passeios(viagem_passageiro_id);

CREATE INDEX IF NOT EXISTS idx_passageiro_passeios_passeio_id 
ON passageiro_passeios(passeio_id);

CREATE INDEX IF NOT EXISTS idx_passageiro_passeios_organization_id 
ON passageiro_passeios(organization_id);

CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_created_at 
ON viagem_passageiros(created_at);

-- 7. TRIGGER PARA UPDATED_AT EM PASSAGEIRO_PASSEIOS
CREATE OR REPLACE FUNCTION update_passageiro_passeios_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_passageiro_passeios_updated_at
    BEFORE UPDATE ON passageiro_passeios
    FOR EACH ROW
    EXECUTE FUNCTION update_passageiro_passeios_updated_at();

-- 8. VERIFICAÇÃO FINAL
SELECT 
    'viagem_passageiros.created_at' as objeto,
    'coluna' as tipo,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'viagem_passageiros' AND column_name = 'created_at')
        THEN '✅ EXISTE'
        ELSE '❌ ERRO'
    END as status
UNION ALL
SELECT 
    'passageiro_passeios' as objeto,
    'tabela' as tipo,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'passageiro_passeios')
        THEN '✅ CRIADA'
        ELSE '❌ ERRO'
    END as status
UNION ALL
SELECT 
    'ingressos_com_cliente' as objeto,
    'view' as tipo,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'ingressos_com_cliente')
        THEN '✅ CRIADA'
        ELSE '❌ ERRO'
    END as status;

-- =====================================================
-- COMENTÁRIOS
-- =====================================================

/*
ESTES PROBLEMAS ERAM CAUSADOS POR:

1. MIGRAÇÃO INCOMPLETA:
   - A tabela viagem_passageiros foi criada sem created_at
   - A tabela passageiro_passeios nunca foi criada
   - A view ingressos_com_cliente não existia

2. RELACIONAMENTOS QUEBRADOS:
   - O frontend tentava acessar passageiro_passeios que não existia
   - Consultas tentavam usar cliente_nome que só existe na view

3. DADOS VAZIOS:
   - Como as tabelas estão vazias, muitas consultas retornam arrays vazios
   - Isso causa erros de "reduce of empty array" no frontend

APÓS EXECUTAR ESTE SCRIPT:
✅ Todos os erros de schema serão resolvidos
✅ O sistema funcionará normalmente
✅ Os dados existentes serão preservados
✅ O sistema multi-tenant continuará funcionando
*/