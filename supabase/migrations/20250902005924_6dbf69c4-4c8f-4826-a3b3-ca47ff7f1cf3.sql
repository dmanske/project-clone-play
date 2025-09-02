-- =====================================================
-- TABELAS ADICIONAIS PARA COMPLETAR O SISTEMA
-- =====================================================

-- Tabela para vinculações de créditos
CREATE TABLE IF NOT EXISTS credito_vinculacoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    credito_id UUID NOT NULL REFERENCES creditos_clientes(id) ON DELETE CASCADE,
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    valor_usado DECIMAL(10,2) NOT NULL CHECK (valor_usado > 0),
    data_uso TIMESTAMP DEFAULT NOW(),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Adicionar campos faltantes na tabela viagens
ALTER TABLE viagens ADD COLUMN IF NOT EXISTS capacidade_onibus INTEGER;
ALTER TABLE viagens ADD COLUMN IF NOT EXISTS tem_passeios BOOLEAN DEFAULT false;

-- Adicionar campos faltantes na tabela ingressos
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS jogo_data DATE;
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS adversario VARCHAR(255);
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS local_jogo VARCHAR(255);
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS setor_estadio VARCHAR(100);
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS situacao_financeira VARCHAR(50) DEFAULT 'pendente';
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS valor_final DECIMAL(10,2);
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS preco_face DECIMAL(10,2);
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS taxa_servico DECIMAL(10,2);
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS desconto DECIMAL(10,2) DEFAULT 0;
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS metodo_pagamento VARCHAR(50);
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS detalhes_pagamento TEXT;
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS codigo_barras VARCHAR(255);

-- Tabela para setores do Maracanã
CREATE TABLE IF NOT EXISTS setores_maracana (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    preco_base DECIMAL(10,2) NOT NULL,
    disponivel BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Inserir setores padrão do Maracanã
INSERT INTO setores_maracana (nome, preco_base) VALUES
('Norte', 50.00),
('Sul', 50.00),
('Leste Superior', 80.00),
('Oeste Superior', 80.00),
('Leste Inferior', 120.00),
('Oeste Inferior', 120.00),
('Maracanã Mais', 200.00),
('Cadeira Cativa', 300.00)
ON CONFLICT DO NOTHING;

-- =====================================================
-- HABILITAR RLS E CRIAR POLÍTICAS
-- =====================================================

ALTER TABLE credito_vinculacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE setores_maracana ENABLE ROW LEVEL SECURITY;

-- Políticas para credito_vinculacoes
CREATE POLICY "Admin pode gerenciar vinculações de crédito"
ON credito_vinculacoes FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para setores_maracana
CREATE POLICY "Setores são públicos para visualização"
ON setores_maracana FOR SELECT
TO public
USING (true);

CREATE POLICY "Admin pode gerenciar setores"
ON setores_maracana FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- =====================================================
-- ÍNDICES ADICIONAIS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_credito_vinculacoes_credito ON credito_vinculacoes(credito_id);
CREATE INDEX IF NOT EXISTS idx_credito_vinculacoes_viagem ON credito_vinculacoes(viagem_id);
CREATE INDEX IF NOT EXISTS idx_setores_disponivel ON setores_maracana(disponivel);