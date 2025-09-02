-- =====================================================
-- SISTEMA COMPLETO DE GESTÃO DE VIAGENS - TABELAS PRINCIPAIS
-- =====================================================

-- 1. TABELA DE CLIENTES
CREATE TABLE IF NOT EXISTS clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    cep VARCHAR(10) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    como_conheceu VARCHAR(100) NOT NULL,
    indicacao_nome VARCHAR(255),
    observacoes TEXT,
    foto VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. TABELA DE ÔNIBUS
CREATE TABLE IF NOT EXISTS onibus (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo_onibus VARCHAR(100) NOT NULL,
    empresa VARCHAR(255) NOT NULL,
    numero_identificacao VARCHAR(50),
    capacidade INTEGER NOT NULL CHECK (capacidade > 0),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. TABELA DE VIAGENS
CREATE TABLE IF NOT EXISTS viagens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    destino VARCHAR(255) NOT NULL,
    data_ida DATE NOT NULL,
    data_volta DATE NOT NULL,
    preco_individual DECIMAL(10,2) NOT NULL CHECK (preco_individual > 0),
    onibus_id UUID REFERENCES onibus(id),
    vagas_disponiveis INTEGER NOT NULL CHECK (vagas_disponiveis >= 0),
    status_viagem VARCHAR(20) DEFAULT 'planejada' CHECK (status_viagem IN ('planejada', 'confirmada', 'em_andamento', 'finalizada', 'cancelada')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. TABELA DE PASSAGEIROS DA VIAGEM
CREATE TABLE IF NOT EXISTS viagem_passageiros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    valor_pago DECIMAL(10,2) NOT NULL CHECK (valor_pago >= 0),
    status_pagamento VARCHAR(20) DEFAULT 'pendente' CHECK (status_pagamento IN ('pendente', 'parcial', 'pago', 'cancelado')),
    data_inscricao TIMESTAMP DEFAULT NOW(),
    observacoes TEXT,
    UNIQUE(viagem_id, cliente_id)
);

-- 5. TABELA DE CRÉDITOS DOS CLIENTES
CREATE TABLE IF NOT EXISTS creditos_clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    valor_inicial DECIMAL(10,2) NOT NULL CHECK (valor_inicial > 0),
    saldo_disponivel DECIMAL(10,2) NOT NULL CHECK (saldo_disponivel >= 0),
    motivo VARCHAR(255) NOT NULL,
    data_expiracao DATE,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 6. TABELA DE INGRESSOS
CREATE TABLE IF NOT EXISTS ingressos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    evento VARCHAR(255) NOT NULL,
    setor VARCHAR(100) NOT NULL,
    fileira VARCHAR(10),
    cadeira VARCHAR(10),
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    data_evento DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'usado', 'cancelado')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 7. TABELA DE EMPRESA CONFIG
CREATE TABLE IF NOT EXISTS empresa_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    cnpj VARCHAR(18),
    email VARCHAR(255),
    telefone VARCHAR(20),
    whatsapp VARCHAR(20),
    endereco TEXT,
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    logo_url VARCHAR(500),
    logo_bucket_path VARCHAR(500),
    site VARCHAR(255),
    instagram VARCHAR(255),
    facebook VARCHAR(255),
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- SISTEMA FINANCEIRO
-- =====================================================

-- 8. TABELA DE RECEITAS DA VIAGEM
CREATE TABLE IF NOT EXISTS viagem_receitas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    descricao VARCHAR(255) NOT NULL,
    categoria VARCHAR(50) NOT NULL CHECK (categoria IN ('passageiro', 'patrocinio', 'vendas', 'extras')),
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    forma_pagamento VARCHAR(30) CHECK (forma_pagamento IN ('pix', 'cartao', 'dinheiro', 'transferencia', 'boleto')),
    status VARCHAR(20) DEFAULT 'recebido' CHECK (status IN ('recebido', 'pendente', 'cancelado')),
    data_recebimento DATE NOT NULL,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 9. TABELA DE DESPESAS DA VIAGEM
CREATE TABLE IF NOT EXISTS viagem_despesas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    fornecedor VARCHAR(255) NOT NULL,
    categoria VARCHAR(50) NOT NULL CHECK (categoria IN ('transporte', 'hospedagem', 'alimentacao', 'ingressos', 'pessoal', 'administrativo')),
    subcategoria VARCHAR(50),
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    forma_pagamento VARCHAR(30) CHECK (forma_pagamento IN ('pix', 'cartao', 'dinheiro', 'transferencia', 'boleto')),
    status VARCHAR(20) DEFAULT 'pago' CHECK (status IN ('pago', 'pendente', 'cancelado')),
    data_despesa DATE NOT NULL,
    comprovante_url VARCHAR(500),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 10. TABELA DE HISTÓRICO DE COBRANÇA
CREATE TABLE IF NOT EXISTS viagem_cobranca_historico (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_passageiro_id UUID NOT NULL REFERENCES viagem_passageiros(id) ON DELETE CASCADE,
    tipo_contato VARCHAR(20) NOT NULL CHECK (tipo_contato IN ('whatsapp', 'email', 'telefone', 'presencial')),
    template_usado VARCHAR(50),
    status_envio VARCHAR(20) DEFAULT 'enviado' CHECK (status_envio IN ('enviado', 'lido', 'respondido', 'erro')),
    data_tentativa TIMESTAMP DEFAULT NOW(),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 11. TABELA DE ORÇAMENTO DA VIAGEM
CREATE TABLE IF NOT EXISTS viagem_orcamento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    categoria VARCHAR(50) NOT NULL,
    subcategoria VARCHAR(50),
    valor_orcado DECIMAL(10,2) NOT NULL CHECK (valor_orcado >= 0),
    valor_realizado DECIMAL(10,2) DEFAULT 0 CHECK (valor_realizado >= 0),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- TRIGGERS PARA UPDATED_AT
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_onibus_updated_at BEFORE UPDATE ON onibus FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_viagens_updated_at BEFORE UPDATE ON viagens FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_creditos_updated_at BEFORE UPDATE ON creditos_clientes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_empresa_updated_at BEFORE UPDATE ON empresa_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_receitas_updated_at BEFORE UPDATE ON viagem_receitas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_despesas_updated_at BEFORE UPDATE ON viagem_despesas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orcamento_updated_at BEFORE UPDATE ON viagem_orcamento FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_clientes_cpf ON clientes(cpf);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes(email);
CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_viagem ON viagem_passageiros(viagem_id);
CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_cliente ON viagem_passageiros(cliente_id);
CREATE INDEX IF NOT EXISTS idx_creditos_cliente ON creditos_clientes(cliente_id);
CREATE INDEX IF NOT EXISTS idx_ingressos_cliente ON ingressos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_receitas_viagem ON viagem_receitas(viagem_id);
CREATE INDEX IF NOT EXISTS idx_despesas_viagem ON viagem_despesas(viagem_id);

-- =====================================================
-- DADOS INICIAIS
-- =====================================================

INSERT INTO empresa_config (nome, nome_fantasia, email, telefone, whatsapp, endereco, cidade, estado, cep, descricao, ativo)
VALUES ('GoFans', 'GoFans - Viagens Esportivas', 'contato@gofans.com', '(11) 99999-9999', '11999999999', 'Rua dos Esportes, 123', 'São Paulo', 'SP', '01234-567', 'Empresa especializada em viagens para jogos de futebol e eventos esportivos.', true)
ON CONFLICT DO NOTHING;