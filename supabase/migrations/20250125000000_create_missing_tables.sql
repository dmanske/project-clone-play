-- =====================================================
-- MIGRAÇÃO COMPLETA: CRIAR TODAS AS TABELAS FALTANTES
-- =====================================================

-- 1. TABELA PASSEIOS (Principal que estava faltando)
CREATE TABLE IF NOT EXISTS passeios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    valor DECIMAL(10,2) NOT NULL DEFAULT 0,
    categoria VARCHAR(100),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    custo_operacional DECIMAL(10,2) DEFAULT 0,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- 2. TABELAS FINANCEIRAS
CREATE TABLE IF NOT EXISTS categorias_financeiras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('receita', 'despesa')),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS contas_pagar (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status VARCHAR(50) DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'vencido')),
    categoria_id UUID REFERENCES categorias_financeiras(id),
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS despesas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_despesa DATE NOT NULL,
    categoria_id UUID REFERENCES categorias_financeiras(id),
    viagem_id UUID REFERENCES viagens(id),
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS receitas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_receita DATE NOT NULL,
    categoria_id UUID REFERENCES categorias_financeiras(id),
    viagem_id UUID REFERENCES viagens(id),
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS projecoes_fluxo_caixa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data_projecao DATE NOT NULL,
    valor_projetado DECIMAL(10,2) NOT NULL,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('entrada', 'saida')),
    descricao TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- 3. TABELAS DE CRÉDITOS
CREATE TABLE IF NOT EXISTS cliente_creditos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    saldo_atual DECIMAL(10,2) DEFAULT 0,
    limite_credito DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS credito_historico (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('credito', 'debito')),
    valor DECIMAL(10,2) NOT NULL,
    descricao TEXT,
    saldo_anterior DECIMAL(10,2),
    saldo_atual DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS credito_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    acao VARCHAR(100) NOT NULL,
    detalhes JSONB,
    usuario_id UUID REFERENCES profiles(id),
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS credito_viagem_vinculacoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    valor_vinculado DECIMAL(10,2) NOT NULL,
    data_vinculacao TIMESTAMP DEFAULT NOW(),
    ativo BOOLEAN DEFAULT true,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- 4. TABELAS DE PRODUTOS/LOJA
CREATE TABLE IF NOT EXISTS categorias_produtos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS produtos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    categoria_id UUID REFERENCES categorias_produtos(id),
    estoque INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    imagem_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pedidos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    total DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente' CHECK (status IN ('pendente', 'confirmado', 'enviado', 'entregue', 'cancelado')),
    data_pedido TIMESTAMP DEFAULT NOW(),
    observacoes TEXT,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pedido_itens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id UUID NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_id UUID NOT NULL REFERENCES produtos(id),
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- 5. TABELAS DE GAMES
CREATE TABLE IF NOT EXISTS adversarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    logo_url TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    data_jogo TIMESTAMP NOT NULL,
    adversario_id UUID REFERENCES adversarios(id),
    local_jogo VARCHAR(255),
    resultado VARCHAR(50),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS game_buses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    onibus_id UUID NOT NULL REFERENCES onibus(id),
    preco DECIMAL(10,2) NOT NULL,
    vagas_disponiveis INTEGER,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- 6. TABELAS DE SISTEMA
CREATE TABLE IF NOT EXISTS empresa_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chave VARCHAR(255) NOT NULL,
    valor TEXT,
    descricao TEXT,
    tipo VARCHAR(50) DEFAULT 'string',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sistema_parametros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parametro VARCHAR(255) NOT NULL,
    valor TEXT NOT NULL,
    descricao TEXT,
    tipo VARCHAR(50) DEFAULT 'string',
    editavel BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS system_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key VARCHAR(255) NOT NULL,
    config_value TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    display_name VARCHAR(255),
    avatar_url TEXT,
    bio TEXT,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- 7. TABELAS DE PAGAMENTOS
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES clientes(id),
    viagem_id UUID REFERENCES viagens(id),
    valor DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente',
    metodo_pagamento VARCHAR(100),
    data_pagamento TIMESTAMP,
    referencia_externa VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS stripe_customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    stripe_customer_id VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- 8. OUTRAS TABELAS IMPORTANTES
CREATE TABLE IF NOT EXISTS passengers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(20),
    documento VARCHAR(50),
    data_nascimento DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS setores_maracana (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    capacidade INTEGER,
    preco_base DECIMAL(10,2),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lista_presenca (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    presente BOOLEAN DEFAULT false,
    data_checkin TIMESTAMP,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS viagem_onibus (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    onibus_id UUID NOT NULL REFERENCES onibus(id),
    ordem INTEGER DEFAULT 1,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS viagem_passageiros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'confirmado',
    assento VARCHAR(10),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS viagens_ingressos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    ingresso_id UUID NOT NULL REFERENCES ingressos(id) ON DELETE CASCADE,
    quantidade INTEGER DEFAULT 1,
    preco_unitario DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- 9. TABELAS DE HISTÓRICO E RELATÓRIOS
CREATE TABLE IF NOT EXISTS historico_pagamentos_categorizado (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pagamento_id UUID,
    categoria VARCHAR(100),
    subcategoria VARCHAR(100),
    valor DECIMAL(10,2) NOT NULL,
    data_categorizacao TIMESTAMP DEFAULT NOW(),
    usuario_id UUID REFERENCES profiles(id),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS historico_pagamentos_ingressos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingresso_id UUID NOT NULL REFERENCES ingressos(id),
    valor_pago DECIMAL(10,2) NOT NULL,
    data_pagamento TIMESTAMP NOT NULL,
    metodo_pagamento VARCHAR(100),
    status VARCHAR(50),
    referencia VARCHAR(255),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- 10. TABELAS DE VIAGEM ESPECÍFICAS
CREATE TABLE IF NOT EXISTS viagem_cobranca_historico (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    valor_cobrado DECIMAL(10,2) NOT NULL,
    data_cobranca TIMESTAMP NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente',
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS viagem_despesas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(100),
    data_despesa DATE NOT NULL,
    comprovante_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS viagem_receitas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(100),
    data_receita DATE NOT NULL,
    comprovante_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS viagem_orcamento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    categoria VARCHAR(100) NOT NULL,
    valor_orcado DECIMAL(10,2) NOT NULL,
    valor_realizado DECIMAL(10,2) DEFAULT 0,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS viagem_parcelamento_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    numero_parcelas INTEGER NOT NULL,
    valor_parcela DECIMAL(10,2) NOT NULL,
    data_vencimento_primeira DATE NOT NULL,
    intervalo_dias INTEGER DEFAULT 30,
    juros_percentual DECIMAL(5,2) DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS viagem_passageiros_parcelas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    numero_parcela INTEGER NOT NULL,
    valor_parcela DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status VARCHAR(50) DEFAULT 'pendente',
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE
);

-- =====================================================
-- HABILITAR RLS EM TODAS AS TABELAS
-- =====================================================

ALTER TABLE passeios ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias_financeiras ENABLE ROW LEVEL SECURITY;
ALTER TABLE contas_pagar ENABLE ROW LEVEL SECURITY;
ALTER TABLE despesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE projecoes_fluxo_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE cliente_creditos ENABLE ROW LEVEL SECURITY;
ALTER TABLE credito_historico ENABLE ROW LEVEL SECURITY;
ALTER TABLE credito_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE credito_viagem_vinculacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias_produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedido_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE adversarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_buses ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresa_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE sistema_parametros ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE stripe_customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE passengers ENABLE ROW LEVEL SECURITY;
ALTER TABLE setores_maracana ENABLE ROW LEVEL SECURITY;
ALTER TABLE lista_presenca ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_onibus ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_passageiros ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagens_ingressos ENABLE ROW LEVEL SECURITY;
ALTER TABLE historico_pagamentos_categorizado ENABLE ROW LEVEL SECURITY;
ALTER TABLE historico_pagamentos_ingressos ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_cobranca_historico ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_despesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_orcamento ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_parcelamento_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_passageiros_parcelas ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_passeios_organization_id ON passeios(organization_id);
CREATE INDEX IF NOT EXISTS idx_categorias_financeiras_organization_id ON categorias_financeiras(organization_id);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_organization_id ON contas_pagar(organization_id);
CREATE INDEX IF NOT EXISTS idx_despesas_organization_id ON despesas(organization_id);
CREATE INDEX IF NOT EXISTS idx_receitas_organization_id ON receitas(organization_id);
CREATE INDEX IF NOT EXISTS idx_projecoes_fluxo_caixa_organization_id ON projecoes_fluxo_caixa(organization_id);
CREATE INDEX IF NOT EXISTS idx_cliente_creditos_organization_id ON cliente_creditos(organization_id);
CREATE INDEX IF NOT EXISTS idx_credito_historico_organization_id ON credito_historico(organization_id);
CREATE INDEX IF NOT EXISTS idx_credito_logs_organization_id ON credito_logs(organization_id);
CREATE INDEX IF NOT EXISTS idx_credito_viagem_vinculacoes_organization_id ON credito_viagem_vinculacoes(organization_id);
CREATE INDEX IF NOT EXISTS idx_categorias_produtos_organization_id ON categorias_produtos(organization_id);
CREATE INDEX IF NOT EXISTS idx_produtos_organization_id ON produtos(organization_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_organization_id ON pedidos(organization_id);
CREATE INDEX IF NOT EXISTS idx_pedido_itens_organization_id ON pedido_itens(organization_id);
CREATE INDEX IF NOT EXISTS idx_adversarios_organization_id ON adversarios(organization_id);
CREATE INDEX IF NOT EXISTS idx_games_organization_id ON games(organization_id);
CREATE INDEX IF NOT EXISTS idx_game_buses_organization_id ON game_buses(organization_id);
CREATE INDEX IF NOT EXISTS idx_empresa_config_organization_id ON empresa_config(organization_id);
CREATE INDEX IF NOT EXISTS idx_sistema_parametros_organization_id ON sistema_parametros(organization_id);
CREATE INDEX IF NOT EXISTS idx_system_config_organization_id ON system_config(organization_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_organization_id ON user_profiles(organization_id);
CREATE INDEX IF NOT EXISTS idx_payments_organization_id ON payments(organization_id);
CREATE INDEX IF NOT EXISTS idx_stripe_customers_organization_id ON stripe_customers(organization_id);
CREATE INDEX IF NOT EXISTS idx_passengers_organization_id ON passengers(organization_id);
CREATE INDEX IF NOT EXISTS idx_setores_maracana_organization_id ON setores_maracana(organization_id);
CREATE INDEX IF NOT EXISTS idx_lista_presenca_organization_id ON lista_presenca(organization_id);
CREATE INDEX IF NOT EXISTS idx_viagem_onibus_organization_id ON viagem_onibus(organization_id);
CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_organization_id ON viagem_passageiros(organization_id);
CREATE INDEX IF NOT EXISTS idx_viagens_ingressos_organization_id ON viagens_ingressos(organization_id);
CREATE INDEX IF NOT EXISTS idx_historico_pagamentos_categorizado_organization_id ON historico_pagamentos_categorizado(organization_id);
CREATE INDEX IF NOT EXISTS idx_historico_pagamentos_ingressos_organization_id ON historico_pagamentos_ingressos(organization_id);
CREATE INDEX IF NOT EXISTS idx_viagem_cobranca_historico_organization_id ON viagem_cobranca_historico(organization_id);
CREATE INDEX IF NOT EXISTS idx_viagem_despesas_organization_id ON viagem_despesas(organization_id);
CREATE INDEX IF NOT EXISTS idx_viagem_receitas_organization_id ON viagem_receitas(organization_id);
CREATE INDEX IF NOT EXISTS idx_viagem_orcamento_organization_id ON viagem_orcamento(organization_id);
CREATE INDEX IF NOT EXISTS idx_viagem_parcelamento_config_organization_id ON viagem_parcelamento_config(organization_id);
CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_parcelas_organization_id ON viagem_passageiros_parcelas(organization_id);

-- Índices adicionais para performance
CREATE INDEX IF NOT EXISTS idx_cliente_creditos_cliente_id ON cliente_creditos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_credito_historico_cliente_id ON credito_historico(cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_cliente_id ON pedidos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_payments_cliente_id ON payments(cliente_id);
CREATE INDEX IF NOT EXISTS idx_payments_viagem_id ON payments(viagem_id);
CREATE INDEX IF NOT EXISTS idx_lista_presenca_viagem_id ON lista_presenca(viagem_id);
CREATE INDEX IF NOT EXISTS idx_lista_presenca_cliente_id ON lista_presenca(cliente_id);
CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_viagem_id ON viagem_passageiros(viagem_id);
CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_cliente_id ON viagem_passageiros(cliente_id);

-- =====================================================
-- INSERIR DADOS BÁSICOS DO SISTEMA
-- =====================================================

-- Inserir passeios padrão (dados do sistema, não de clientes)
INSERT INTO passeios (nome, valor, categoria, ativo, organization_id) 
SELECT 
    'Almoço no Restaurante', 45.00, 'Alimentação', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM passeios WHERE nome = 'Almoço no Restaurante' AND organization_id = organizations.id);

INSERT INTO passeios (nome, valor, categoria, ativo, organization_id) 
SELECT 
    'Jantar no Hotel', 55.00, 'Alimentação', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM passeios WHERE nome = 'Jantar no Hotel' AND organization_id = organizations.id);

INSERT INTO passeios (nome, valor, categoria, ativo, organization_id) 
SELECT 
    'City Tour', 80.00, 'Turismo', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM passeios WHERE nome = 'City Tour' AND organization_id = organizations.id);

INSERT INTO passeios (nome, valor, categoria, ativo, organization_id) 
SELECT 
    'Visita ao Cristo Redentor', 120.00, 'Turismo', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM passeios WHERE nome = 'Visita ao Cristo Redentor' AND organization_id = organizations.id);

INSERT INTO passeios (nome, valor, categoria, ativo, organization_id) 
SELECT 
    'Pão de Açúcar', 100.00, 'Turismo', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM passeios WHERE nome = 'Pão de Açúcar' AND organization_id = organizations.id);

-- Inserir categorias financeiras padrão
INSERT INTO categorias_financeiras (nome, tipo, ativo, organization_id) 
SELECT 
    'Combustível', 'despesa', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM categorias_financeiras WHERE nome = 'Combustível' AND organization_id = organizations.id);

INSERT INTO categorias_financeiras (nome, tipo, ativo, organization_id) 
SELECT 
    'Alimentação', 'despesa', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM categorias_financeiras WHERE nome = 'Alimentação' AND organization_id = organizations.id);

INSERT INTO categorias_financeiras (nome, tipo, ativo, organization_id) 
SELECT 
    'Hospedagem', 'despesa', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM categorias_financeiras WHERE nome = 'Hospedagem' AND organization_id = organizations.id);

INSERT INTO categorias_financeiras (nome, tipo, ativo, organization_id) 
SELECT 
    'Vendas de Viagens', 'receita', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM categorias_financeiras WHERE nome = 'Vendas de Viagens' AND organization_id = organizations.id);

INSERT INTO categorias_financeiras (nome, tipo, ativo, organization_id) 
SELECT 
    'Vendas de Passeios', 'receita', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM categorias_financeiras WHERE nome = 'Vendas de Passeios' AND organization_id = organizations.id);

-- Inserir setores do Maracanã
INSERT INTO setores_maracana (nome, preco_base, disponivel, organization_id) 
SELECT 
    'Setor Norte', 80.00, true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM setores_maracana WHERE nome = 'Setor Norte' AND organization_id = organizations.id);

INSERT INTO setores_maracana (nome, preco_base, disponivel, organization_id) 
SELECT 
    'Setor Sul', 80.00, true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM setores_maracana WHERE nome = 'Setor Sul' AND organization_id = organizations.id);

INSERT INTO setores_maracana (nome, preco_base, disponivel, organization_id) 
SELECT 
    'Setor Leste Superior', 100.00, true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM setores_maracana WHERE nome = 'Setor Leste Superior' AND organization_id = organizations.id);

INSERT INTO setores_maracana (nome, preco_base, disponivel, organization_id) 
SELECT 
    'Setor Oeste Superior', 100.00, true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM setores_maracana WHERE nome = 'Setor Oeste Superior' AND organization_id = organizations.id);

INSERT INTO setores_maracana (nome, preco_base, disponivel, organization_id) 
SELECT 
    'Setor Leste Inferior', 150.00, true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM setores_maracana WHERE nome = 'Setor Leste Inferior' AND organization_id = organizations.id);

INSERT INTO setores_maracana (nome, preco_base, disponivel, organization_id) 
SELECT 
    'Setor Oeste Inferior', 150.00, true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM setores_maracana WHERE nome = 'Setor Oeste Inferior' AND organization_id = organizations.id);

-- Inserir parâmetros do sistema
INSERT INTO sistema_parametros (parametro, valor, descricao, tipo, editavel, organization_id) 
SELECT 
    'taxa_cartao_credito', '3.5', 'Taxa percentual para pagamentos com cartão de crédito', 'decimal', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM sistema_parametros WHERE parametro = 'taxa_cartao_credito' AND organization_id = organizations.id);

INSERT INTO sistema_parametros (parametro, valor, descricao, tipo, editavel, organization_id) 
SELECT 
    'taxa_cartao_debito', '2.0', 'Taxa percentual para pagamentos com cartão de débito', 'decimal', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM sistema_parametros WHERE parametro = 'taxa_cartao_debito' AND organization_id = organizations.id);

INSERT INTO sistema_parametros (parametro, valor, descricao, tipo, editavel, organization_id) 
SELECT 
    'prazo_cancelamento', '48', 'Prazo em horas para cancelamento sem taxa', 'integer', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM sistema_parametros WHERE parametro = 'prazo_cancelamento' AND organization_id = organizations.id);

INSERT INTO sistema_parametros (parametro, valor, descricao, tipo, editavel, organization_id) 
SELECT 
    'email_contato', 'contato@empresa.com', 'Email de contato da empresa', 'string', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM sistema_parametros WHERE parametro = 'email_contato' AND organization_id = organizations.id);

INSERT INTO sistema_parametros (parametro, valor, descricao, tipo, editavel, organization_id) 
SELECT 
    'telefone_contato', '(21) 99999-9999', 'Telefone de contato da empresa', 'string', true, id
FROM organizations 
WHERE NOT EXISTS (SELECT 1 FROM sistema_parametros WHERE parametro = 'telefone_contato' AND organization_id = organizations.id);

-- =====================================================
-- COMENTÁRIOS FINAIS
-- =====================================================

COMMENT ON TABLE passeios IS 'Tabela de passeios disponíveis para as viagens';
COMMENT ON TABLE categorias_financeiras IS 'Categorias para classificação de receitas e despesas';
COMMENT ON TABLE contas_pagar IS 'Contas a pagar da empresa';
COMMENT ON TABLE despesas IS 'Registro de despesas da empresa';
COMMENT ON TABLE receitas IS 'Registro de receitas da empresa';
COMMENT ON TABLE cliente_creditos IS 'Saldo de créditos dos clientes';
COMMENT ON TABLE credito_historico IS 'Histórico de movimentações de crédito dos clientes';
COMMENT ON TABLE produtos IS 'Produtos disponíveis na loja';
COMMENT ON TABLE pedidos IS 'Pedidos realizados pelos clientes';
COMMENT ON TABLE adversarios IS 'Times adversários para os jogos';
COMMENT ON TABLE games IS 'Jogos/partidas disponíveis';
COMMENT ON TABLE payments IS 'Registro de pagamentos realizados';
COMMENT ON TABLE passengers IS 'Passageiros das viagens';
COMMENT ON TABLE setores_maracana IS 'Setores disponíveis no estádio do Maracanã';
COMMENT ON TABLE lista_presenca IS 'Lista de presença dos passageiros nas viagens';
COMMENT ON TABLE viagem_passageiros IS 'Relacionamento entre viagens e passageiros';
COMMENT ON TABLE sistema_parametros IS 'Parâmetros configuráveis do sistema';