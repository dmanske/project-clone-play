-- =====================================================
-- TABELAS ADICIONAIS NECESSÁRIAS PARA O SISTEMA
-- =====================================================

-- Adicionar campos faltantes na tabela viagens
ALTER TABLE viagens ADD COLUMN IF NOT EXISTS adversario VARCHAR(255);
ALTER TABLE viagens ADD COLUMN IF NOT EXISTS data_jogo DATE;
ALTER TABLE viagens ADD COLUMN IF NOT EXISTS local_jogo VARCHAR(255);
ALTER TABLE viagens ADD COLUMN IF NOT EXISTS valor_padrao DECIMAL(10,2);

-- Atualizar dados existentes se não estiverem preenchidos
UPDATE viagens SET 
  adversario = destino,
  data_jogo = data_ida,
  local_jogo = CASE 
    WHEN destino ILIKE '%rio%' OR destino ILIKE '%flamengo%' THEN 'Rio de Janeiro'
    WHEN destino ILIKE '%são paulo%' OR destino ILIKE '%sp%' THEN 'São Paulo'
    ELSE 'Rio de Janeiro'
  END,
  valor_padrao = preco_individual
WHERE adversario IS NULL OR data_jogo IS NULL OR local_jogo IS NULL OR valor_padrao IS NULL;

-- Atualizar campos em ingressos para dar compatibilidade
UPDATE ingressos SET 
  jogo_data = data_evento,
  adversario = evento,
  local_jogo = 'Rio de Janeiro',
  setor_estadio = setor,
  situacao_financeira = COALESCE(situacao_financeira, 'pendente'),
  valor_final = COALESCE(valor_final, valor),
  preco_face = COALESCE(preco_face, valor),
  taxa_servico = COALESCE(taxa_servico, 0),
  desconto = COALESCE(desconto, 0)
WHERE jogo_data IS NULL OR adversario IS NULL;

-- Adicionar campos faltantes em ingressos se não existirem
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS preco_custo DECIMAL(10,2) DEFAULT 0;
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS preco_venda DECIMAL(10,2);
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS lucro DECIMAL(10,2) DEFAULT 0;
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS margem_percentual DECIMAL(5,2) DEFAULT 0;
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Atualizar campos calculados em ingressos
UPDATE ingressos SET 
  preco_custo = COALESCE(preco_face, valor) * 0.8,
  preco_venda = COALESCE(valor_final, valor),
  lucro = COALESCE(valor_final, valor) - (COALESCE(preco_face, valor) * 0.8),
  margem_percentual = CASE 
    WHEN COALESCE(valor_final, valor) > 0 THEN 
      ((COALESCE(valor_final, valor) - (COALESCE(preco_face, valor) * 0.8)) / COALESCE(valor_final, valor)) * 100
    ELSE 0
  END,
  updated_at = NOW()
WHERE preco_custo IS NULL OR preco_venda IS NULL;

-- Tabela viagem_onibus (referenciada pelo código)
CREATE TABLE IF NOT EXISTS viagem_onibus (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    onibus_id UUID NOT NULL REFERENCES onibus(id) ON DELETE CASCADE,
    capacidade_onibus INTEGER NOT NULL DEFAULT 0,
    lugares_extras INTEGER DEFAULT 0,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(viagem_id, onibus_id)
);

-- Tabela viagem_passageiros_parcelas (referenciada pelo código)
CREATE TABLE IF NOT EXISTS viagem_passageiros_parcelas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_passageiro_id UUID NOT NULL REFERENCES viagem_passageiros(id) ON DELETE CASCADE,
    numero_parcela INTEGER NOT NULL,
    total_parcelas INTEGER NOT NULL,
    valor_parcela DECIMAL(10,2) NOT NULL,
    valor_original DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'atrasado', 'cancelado')),
    forma_pagamento VARCHAR(50),
    tipo_parcelamento VARCHAR(50),
    data_pagamento DATE,
    valor_pago DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela viagem_passeios (referenciada pelo código) 
CREATE TABLE IF NOT EXISTS viagem_passeios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    passeio_id UUID NOT NULL,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    valor DECIMAL(10,2) NOT NULL DEFAULT 0,
    obrigatorio BOOLEAN DEFAULT false,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Atualizar estrutura dos setores para compatibilidade
ALTER TABLE setores_maracana ADD COLUMN IF NOT EXISTS descricao TEXT;
ALTER TABLE setores_maracana ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT true;

-- Adicionar campos necessários na tabela viagem_passageiros
ALTER TABLE viagem_passageiros ADD COLUMN IF NOT EXISTS onibus_id UUID REFERENCES onibus(id);
ALTER TABLE viagem_passageiros ADD COLUMN IF NOT EXISTS valor DECIMAL(10,2);
ALTER TABLE viagem_passageiros ADD COLUMN IF NOT EXISTS forma_pagamento VARCHAR(50);
ALTER TABLE viagem_passageiros ADD COLUMN IF NOT EXISTS setor_maracana VARCHAR(100);
ALTER TABLE viagem_passageiros ADD COLUMN IF NOT EXISTS cidade_embarque VARCHAR(100);

-- =====================================================
-- HABILITAR RLS NAS NOVAS TABELAS
-- =====================================================

ALTER TABLE viagem_onibus ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_passageiros_parcelas ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_passeios ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS PARA AS NOVAS TABELAS
-- =====================================================

-- Políticas para viagem_onibus
CREATE POLICY "Admin pode gerenciar viagem_onibus"
ON viagem_onibus FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para viagem_passageiros_parcelas
CREATE POLICY "Admin pode gerenciar parcelas"
ON viagem_passageiros_parcelas FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para viagem_passeios
CREATE POLICY "Passeios são públicos para visualização"
ON viagem_passeios FOR SELECT
TO public
USING (ativo = true);

CREATE POLICY "Admin pode gerenciar passeios"
ON viagem_passeios FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- =====================================================
-- TRIGGERS PARA UPDATED_AT
-- =====================================================

CREATE TRIGGER update_parcelas_updated_at 
    BEFORE UPDATE ON viagem_passageiros_parcelas 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ingressos_updated_at 
    BEFORE UPDATE ON ingressos 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_viagem_onibus_viagem ON viagem_onibus(viagem_id);
CREATE INDEX IF NOT EXISTS idx_viagem_onibus_onibus ON viagem_onibus(onibus_id);
CREATE INDEX IF NOT EXISTS idx_parcelas_passageiro ON viagem_passageiros_parcelas(viagem_passageiro_id);
CREATE INDEX IF NOT EXISTS idx_parcelas_status ON viagem_passageiros_parcelas(status);
CREATE INDEX IF NOT EXISTS idx_viagem_passeios_viagem ON viagem_passeios(viagem_id);
CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_onibus ON viagem_passageiros(onibus_id);