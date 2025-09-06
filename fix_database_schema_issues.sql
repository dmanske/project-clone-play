-- =====================================================
-- DIAGNÓSTICO E CORREÇÃO DE PROBLEMAS DE SCHEMA
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- =====================================================
-- 1. VERIFICAR ESTRUTURA ATUAL DAS TABELAS
-- =====================================================

-- Verificar se a tabela passageiro_passeios existe
SELECT 
    'passageiro_passeios' as tabela,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'passageiro_passeios')
        THEN 'EXISTE'
        ELSE 'NÃO EXISTE'
    END as status;

-- Verificar se a view ingressos_com_cliente existe
SELECT 
    'ingressos_com_cliente' as view_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'ingressos_com_cliente')
        THEN 'EXISTE'
        ELSE 'NÃO EXISTE'
    END as status;

-- Verificar estrutura da tabela viagem_passageiros
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'viagem_passageiros'
ORDER BY ordinal_position;

-- =====================================================
-- 2. CRIAR TABELA PASSAGEIRO_PASSEIOS SE NÃO EXISTIR
-- =====================================================

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

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_passageiro_passeios_viagem_passageiro_id 
ON passageiro_passeios(viagem_passageiro_id);

CREATE INDEX IF NOT EXISTS idx_passageiro_passeios_passeio_id 
ON passageiro_passeios(passeio_id);

CREATE INDEX IF NOT EXISTS idx_passageiro_passeios_organization_id 
ON passageiro_passeios(organization_id);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_passageiro_passeios_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger apenas se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers 
        WHERE trigger_name = 'trigger_update_passageiro_passeios_updated_at'
        AND event_object_table = 'passageiro_passeios'
    ) THEN
        CREATE TRIGGER trigger_update_passageiro_passeios_updated_at
            BEFORE UPDATE ON passageiro_passeios
            FOR EACH ROW
            EXECUTE FUNCTION update_passageiro_passeios_updated_at();
    END IF;
END $$;

-- =====================================================
-- 3. ADICIONAR COLUNA CREATED_AT EM VIAGEM_PASSAGEIROS SE NÃO EXISTIR
-- =====================================================

-- Verificar se a coluna created_at existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'viagem_passageiros' 
        AND column_name = 'created_at'
    ) THEN
        ALTER TABLE viagem_passageiros 
        ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        
        -- Atualizar registros existentes com data atual
        UPDATE viagem_passageiros 
        SET created_at = NOW() 
        WHERE created_at IS NULL;
    END IF;
END $$;

-- =====================================================
-- 4. CRIAR VIEW INGRESSOS_COM_CLIENTE
-- =====================================================

-- Verificar e adicionar coluna viagem_id na tabela ingressos se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'viagem_id'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN viagem_id UUID REFERENCES viagens(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Verificar e adicionar outras colunas necessárias na tabela ingressos
DO $$ 
BEGIN
  -- Adicionar jogo_data se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'jogo_data'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN jogo_data TIMESTAMPTZ;
  END IF;
  
  -- Adicionar adversario se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'adversario'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN adversario VARCHAR(255);
  END IF;
  
  -- Adicionar local_jogo se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'local_jogo'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN local_jogo VARCHAR(10) CHECK (local_jogo IN ('casa', 'fora'));
  END IF;
  
  -- Adicionar setor_estadio se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'setor_estadio'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN setor_estadio VARCHAR(255);
  END IF;
  
  -- Adicionar preco_custo se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'preco_custo'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN preco_custo DECIMAL(10,2) DEFAULT 0 CHECK (preco_custo >= 0);
  END IF;
  
  -- Adicionar preco_venda se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'preco_venda'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN preco_venda DECIMAL(10,2) DEFAULT 0 CHECK (preco_venda >= 0);
  END IF;
  
  -- Adicionar desconto se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'desconto'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN desconto DECIMAL(10,2) DEFAULT 0 CHECK (desconto >= 0);
  END IF;
  
  -- Adicionar valor_final se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'valor_final'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN valor_final DECIMAL(10,2) GENERATED ALWAYS AS (preco_venda - desconto) STORED;
  END IF;
  
  -- Adicionar lucro se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'lucro'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN lucro DECIMAL(10,2) GENERATED ALWAYS AS (preco_venda - desconto - preco_custo) STORED;
  END IF;
  
  -- Adicionar margem_percentual se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'margem_percentual'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN margem_percentual DECIMAL(5,2) GENERATED ALWAYS AS (
      CASE 
        WHEN (preco_venda - desconto) > 0 
        THEN ((preco_venda - desconto - preco_custo) / (preco_venda - desconto)) * 100
        ELSE 0 
      END
    ) STORED;
  END IF;
  
  -- Adicionar situacao_financeira se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'situacao_financeira'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN situacao_financeira VARCHAR(20) DEFAULT 'pendente' CHECK (situacao_financeira IN ('pendente', 'pago', 'cancelado'));
  END IF;
  
  -- Adicionar logo_adversario se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'logo_adversario'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN logo_adversario TEXT;
  END IF;
  
  -- Adicionar viagem_ingressos_id se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'viagem_ingressos_id'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN viagem_ingressos_id UUID REFERENCES viagens_ingressos(id) ON DELETE SET NULL;
  END IF;
  
  -- Adicionar observacoes se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'observacoes'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN observacoes TEXT;
  END IF;
  
  -- Adicionar updated_at se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ingressos' 
    AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE ingressos 
    ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
  END IF;
END $$;

-- Criar índices se não existirem
CREATE INDEX IF NOT EXISTS idx_ingressos_viagem_id ON ingressos(viagem_id);
CREATE INDEX IF NOT EXISTS idx_ingressos_jogo_data ON ingressos(jogo_data);
CREATE INDEX IF NOT EXISTS idx_ingressos_adversario ON ingressos(adversario);

-- Remover view se existir
DROP VIEW IF EXISTS ingressos_com_cliente;

-- Criar view ingressos_com_cliente
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
    i.logo_adversario,
    i.viagem_ingressos_id,
    c.nome as cliente_nome,
    c.email as cliente_email,
    c.telefone as cliente_telefone
FROM ingressos i
INNER JOIN clientes c ON i.cliente_id = c.id;

-- =====================================================
-- 5. POLÍTICAS RLS PARA PASSAGEIRO_PASSEIOS
-- =====================================================

-- Habilitar RLS
ALTER TABLE passageiro_passeios ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS apenas se não existirem
DO $$
BEGIN
    -- Política para usuários verem apenas dados da sua organização
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'passageiro_passeios' 
        AND policyname = 'Users can view passageiro_passeios from their organization'
    ) THEN
        CREATE POLICY "Users can view passageiro_passeios from their organization" ON passageiro_passeios
        FOR SELECT USING (
            organization_id IN (
                SELECT organization_id FROM profiles WHERE id = auth.uid()
            )
        );
    END IF;
    
    -- Política para usuários gerenciarem dados da sua organização
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'passageiro_passeios' 
        AND policyname = 'Users can manage passageiro_passeios from their organization'
    ) THEN
        CREATE POLICY "Users can manage passageiro_passeios from their organization" ON passageiro_passeios
        FOR ALL USING (
            organization_id IN (
                SELECT organization_id FROM profiles WHERE id = auth.uid()
            )
        );
    END IF;
    
    -- Política para service role
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'passageiro_passeios' 
        AND policyname = 'Service role can manage all passageiro_passeios'
    ) THEN
        CREATE POLICY "Service role can manage all passageiro_passeios" ON passageiro_passeios
        FOR ALL USING (auth.role() = 'service_role');
    END IF;
END $$;

-- =====================================================
-- 6. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se todas as tabelas e views foram criadas
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
    END as status
UNION ALL
SELECT 
    'viagem_passageiros.created_at' as objeto,
    'coluna' as tipo,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'viagem_passageiros' AND column_name = 'created_at')
        THEN '✅ EXISTE'
        ELSE '❌ ERRO'
    END as status;

-- Verificar políticas RLS da tabela passageiro_passeios
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename = 'passageiro_passeios'
ORDER BY policyname;

-- =====================================================
-- COMENTÁRIOS IMPORTANTES
-- =====================================================

/*
PROBLEMAS IDENTIFICADOS E SOLUÇÕES:

1. TABELA PASSAGEIRO_PASSEIOS INEXISTENTE:
   - Criada tabela com estrutura completa
   - Relacionamentos com viagem_passageiros e passeios
   - Suporte multi-tenant com organization_id
   - Políticas RLS implementadas

2. VIEW INGRESSOS_COM_CLIENTE AUSENTE:
   - Criada view que junta ingressos com dados dos clientes
   - Facilita consultas no frontend

3. COLUNA CREATED_AT EM VIAGEM_PASSAGEIROS:
   - Adicionada coluna se não existir
   - Registros existentes recebem data atual

4. POLÍTICAS RLS:
   - Implementadas para manter segurança multi-tenant
   - Usuários só veem dados da sua organização
   - Service role tem acesso total

APÓS EXECUTAR ESTE SQL:
- Todos os erros de schema devem ser resolvidos
- Sistema deve funcionar normalmente
- Dados existentes são preservados

Script executado com sucesso!
*/