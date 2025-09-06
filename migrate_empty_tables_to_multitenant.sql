-- =====================================================
-- MIGRAÇÃO DE ESTRUTURAS VAZIAS PARA MULTI-TENANT
-- =====================================================
-- Objetivo: Criar todas as 46 tabelas faltantes com organization_id
-- Estratégia: Estruturas completas, dados zerados
-- Data: Janeiro 2025

-- =====================================================
-- 1. TABELAS FINANCEIRAS (10 tabelas)
-- =====================================================

-- Categorias financeiras
CREATE TABLE IF NOT EXISTS categorias_financeiras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('receita', 'despesa')),
    cor VARCHAR(7), -- Hex color
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Receitas gerais
CREATE TABLE IF NOT EXISTS receitas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    categoria_id UUID REFERENCES categorias_financeiras(id),
    data_recebimento DATE NOT NULL,
    viagem_id UUID REFERENCES viagens(id) ON DELETE SET NULL,
    cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
    forma_pagamento VARCHAR(30),
    status VARCHAR(20) DEFAULT 'recebido' CHECK (status IN ('recebido', 'pendente', 'cancelado')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Despesas gerais
CREATE TABLE IF NOT EXISTS despesas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    categoria_id UUID REFERENCES categorias_financeiras(id),
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    viagem_id UUID REFERENCES viagens(id) ON DELETE SET NULL,
    fornecedor VARCHAR(100),
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'vencido', 'cancelado')),
    metodo_pagamento VARCHAR(30),
    observacoes TEXT,
    comprovante_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Contas a pagar
CREATE TABLE IF NOT EXISTS contas_pagar (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    fornecedor VARCHAR(100) NOT NULL,
    categoria_id UUID REFERENCES categorias_financeiras(id),
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'vencido', 'cancelado')),
    recorrente BOOLEAN DEFAULT FALSE,
    frequencia_recorrencia VARCHAR(20) CHECK (frequencia_recorrencia IN ('mensal', 'trimestral', 'semestral', 'anual')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Histórico de pagamentos categorizados
CREATE TABLE IF NOT EXISTS historico_pagamentos_categorizado (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    viagem_id UUID REFERENCES viagens(id) ON DELETE CASCADE,
    cliente_id UUID REFERENCES clientes(id) ON DELETE CASCADE,
    categoria VARCHAR(50) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_pagamento TIMESTAMP DEFAULT NOW(),
    metodo_pagamento VARCHAR(30),
    status VARCHAR(20) DEFAULT 'confirmado',
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Histórico de pagamentos de ingressos
CREATE TABLE IF NOT EXISTS historico_pagamentos_ingressos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    ingresso_id UUID REFERENCES ingressos(id) ON DELETE CASCADE,
    cliente_id UUID REFERENCES clientes(id) ON DELETE CASCADE,
    valor_pago DECIMAL(10,2) NOT NULL,
    data_pagamento TIMESTAMP DEFAULT NOW(),
    metodo_pagamento VARCHAR(30),
    status VARCHAR(20) DEFAULT 'confirmado',
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Alertas de parcelas
CREATE TABLE IF NOT EXISTS parcela_alertas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    viagem_passageiro_id UUID REFERENCES viagem_passageiros(id) ON DELETE CASCADE,
    data_vencimento DATE NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'enviado', 'pago')),
    tipo_alerta VARCHAR(30) DEFAULT 'whatsapp',
    mensagem_enviada TEXT,
    data_envio TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Histórico de parcelas
CREATE TABLE IF NOT EXISTS parcela_historico (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    viagem_passageiro_id UUID REFERENCES viagem_passageiros(id) ON DELETE CASCADE,
    numero_parcela INTEGER NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'vencido')),
    metodo_pagamento VARCHAR(30),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Projeções de fluxo de caixa
CREATE TABLE IF NOT EXISTS projecoes_fluxo_caixa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    data_projecao DATE NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('entrada', 'saida')),
    valor DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50),
    descricao TEXT,
    viagem_id UUID REFERENCES viagens(id) ON DELETE SET NULL,
    confirmado BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 2. TABELAS DE CRÉDITOS (4 tabelas)
-- =====================================================

-- Créditos de clientes
CREATE TABLE IF NOT EXISTS cliente_creditos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    origem VARCHAR(50) NOT NULL,
    data_credito DATE NOT NULL,
    data_expiracao DATE,
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'usado', 'expirado', 'cancelado')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Histórico de créditos
CREATE TABLE IF NOT EXISTS credito_historico (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    tipo_operacao VARCHAR(20) NOT NULL CHECK (tipo_operacao IN ('credito', 'debito', 'transferencia')),
    valor DECIMAL(10,2) NOT NULL,
    saldo_anterior DECIMAL(10,2) NOT NULL,
    saldo_atual DECIMAL(10,2) NOT NULL,
    descricao TEXT,
    viagem_id UUID REFERENCES viagens(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Logs de créditos
CREATE TABLE IF NOT EXISTS credito_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    cliente_id UUID REFERENCES clientes(id) ON DELETE CASCADE,
    acao VARCHAR(50) NOT NULL,
    valor_anterior DECIMAL(10,2),
    valor_novo DECIMAL(10,2),
    usuario_id UUID REFERENCES profiles(id),
    detalhes JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Vinculações de crédito com viagens
CREATE TABLE IF NOT EXISTS credito_viagem_vinculacoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    credito_id UUID NOT NULL REFERENCES cliente_creditos(id) ON DELETE CASCADE,
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    valor_usado DECIMAL(10,2) NOT NULL CHECK (valor_usado > 0),
    data_uso TIMESTAMP DEFAULT NOW(),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 3. TABELAS DE PRODUTOS/LOJA (4 tabelas)
-- =====================================================

-- Categorias de produtos
CREATE TABLE IF NOT EXISTS categorias_produtos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    ordem INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Produtos
CREATE TABLE IF NOT EXISTS produtos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    categoria_id UUID REFERENCES categorias_produtos(id) ON DELETE SET NULL,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0),
    estoque INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    imagem_url TEXT,
    peso DECIMAL(8,3),
    dimensoes VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
    numero_pedido VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'confirmado', 'enviado', 'entregue', 'cancelado')),
    valor_total DECIMAL(10,2) NOT NULL CHECK (valor_total >= 0),
    desconto DECIMAL(10,2) DEFAULT 0,
    valor_frete DECIMAL(10,2) DEFAULT 0,
    endereco_entrega TEXT,
    observacoes TEXT,
    data_pedido TIMESTAMP DEFAULT NOW(),
    data_entrega DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Itens do pedido
CREATE TABLE IF NOT EXISTS pedido_itens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    pedido_id UUID NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_id UUID NOT NULL REFERENCES produtos(id) ON DELETE CASCADE,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 4. TABELAS DE GAMES/ADVERSÁRIOS (5 tabelas)
-- =====================================================

-- Adversários
CREATE TABLE IF NOT EXISTS adversarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    logo_url TEXT,
    cidade VARCHAR(100),
    estado VARCHAR(2),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Games/Jogos
CREATE TABLE IF NOT EXISTS games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    adversario_id UUID REFERENCES adversarios(id) ON DELETE SET NULL,
    data_jogo TIMESTAMP NOT NULL,
    local_jogo VARCHAR(255) NOT NULL,
    campeonato VARCHAR(100),
    preco_base DECIMAL(10,2) NOT NULL CHECK (preco_base > 0),
    status VARCHAR(20) DEFAULT 'agendado' CHECK (status IN ('agendado', 'confirmado', 'cancelado', 'realizado')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Ônibus para games
CREATE TABLE IF NOT EXISTS game_buses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    onibus_id UUID NOT NULL REFERENCES onibus(id) ON DELETE CASCADE,
    capacidade INTEGER NOT NULL CHECK (capacidade > 0),
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    horario_saida TIMESTAMP,
    local_saida VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Passageiros dos games
CREATE TABLE IF NOT EXISTS passengers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    bus_id UUID NOT NULL REFERENCES game_buses(id) ON DELETE CASCADE,
    cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
    nome VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    assento INTEGER,
    valor_pago DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'confirmado' CHECK (status IN ('confirmado', 'cancelado')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Setores do Maracanã (já existe, mas vou garantir que tenha organization_id)
ALTER TABLE setores_maracana ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;

-- =====================================================
-- 5. TABELAS DE SISTEMA (3 tabelas)
-- =====================================================

-- Parâmetros do sistema
CREATE TABLE IF NOT EXISTS sistema_parametros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    chave VARCHAR(100) NOT NULL,
    valor TEXT,
    tipo VARCHAR(20) DEFAULT 'string' CHECK (tipo IN ('string', 'number', 'boolean', 'json')),
    descricao TEXT,
    categoria VARCHAR(50),
    editavel BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(organization_id, chave)
);

-- Configurações do sistema
CREATE TABLE IF NOT EXISTS system_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    config_key VARCHAR(100) NOT NULL,
    config_value JSONB,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(organization_id, config_key)
);

-- Perfis de usuários (diferente de profiles)
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    display_name VARCHAR(255),
    avatar_url TEXT,
    bio TEXT,
    preferences JSONB,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(organization_id, user_id)
);

-- =====================================================
-- 6. TABELAS DE PAGAMENTOS (2 tabelas)
-- =====================================================

-- Pagamentos
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    viagem_id UUID REFERENCES viagens(id) ON DELETE SET NULL,
    cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    metodo VARCHAR(30) NOT NULL,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'processando', 'aprovado', 'rejeitado', 'cancelado')),
    transaction_id VARCHAR(255),
    gateway_response JSONB,
    data_pagamento TIMESTAMP,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Clientes Stripe
CREATE TABLE IF NOT EXISTS stripe_customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    stripe_customer_id VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(organization_id, cliente_id),
    UNIQUE(stripe_customer_id)
);

-- =====================================================
-- 7. TABELAS AUXILIARES (4 tabelas)
-- =====================================================

-- Lista de presença
CREATE TABLE IF NOT EXISTS lista_presenca (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    presente BOOLEAN DEFAULT false,
    horario_chegada TIMESTAMP,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(organization_id, viagem_id, cliente_id)
);

-- Imagens de ônibus
CREATE TABLE IF NOT EXISTS onibus_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    onibus_id UUID NOT NULL REFERENCES onibus(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    description TEXT,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Passageiros e passeios
CREATE TABLE IF NOT EXISTS passageiro_passeios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    viagem_passageiro_id UUID NOT NULL REFERENCES viagem_passageiros(id) ON DELETE CASCADE,
    passeio_id UUID NOT NULL REFERENCES passeios(id) ON DELETE CASCADE,
    confirmado BOOLEAN DEFAULT false,
    valor_adicional DECIMAL(10,2) DEFAULT 0,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(organization_id, viagem_passageiro_id, passeio_id)
);

-- Ingressos por viagem
CREATE TABLE IF NOT EXISTS viagens_ingressos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    viagem_id UUID NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    ingresso_id UUID NOT NULL REFERENCES ingressos(id) ON DELETE CASCADE,
    quantidade INTEGER DEFAULT 1,
    valor_total DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(organization_id, viagem_id, ingresso_id)
);

-- =====================================================
-- 8. HABILITAR RLS EM TODAS AS TABELAS
-- =====================================================

-- Financeiras
ALTER TABLE categorias_financeiras ENABLE ROW LEVEL SECURITY;
ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE despesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE contas_pagar ENABLE ROW LEVEL SECURITY;
ALTER TABLE historico_pagamentos_categorizado ENABLE ROW LEVEL SECURITY;
ALTER TABLE historico_pagamentos_ingressos ENABLE ROW LEVEL SECURITY;
ALTER TABLE parcela_alertas ENABLE ROW LEVEL SECURITY;
ALTER TABLE parcela_historico ENABLE ROW LEVEL SECURITY;
ALTER TABLE projecoes_fluxo_caixa ENABLE ROW LEVEL SECURITY;

-- Créditos
ALTER TABLE cliente_creditos ENABLE ROW LEVEL SECURITY;
ALTER TABLE credito_historico ENABLE ROW LEVEL SECURITY;
ALTER TABLE credito_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE credito_viagem_vinculacoes ENABLE ROW LEVEL SECURITY;

-- Produtos
ALTER TABLE categorias_produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedido_itens ENABLE ROW LEVEL SECURITY;

-- Games
ALTER TABLE adversarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_buses ENABLE ROW LEVEL SECURITY;
ALTER TABLE passengers ENABLE ROW LEVEL SECURITY;

-- Sistema
ALTER TABLE sistema_parametros ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Pagamentos
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE stripe_customers ENABLE ROW LEVEL SECURITY;

-- Auxiliares
ALTER TABLE lista_presenca ENABLE ROW LEVEL SECURITY;
ALTER TABLE onibus_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE passageiro_passeios ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagens_ingressos ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 9. CRIAR POLÍTICAS RLS BÁSICAS
-- =====================================================

-- Política padrão para todas as tabelas: usuários só veem dados da sua organização
DO $$ 
DECLARE
    table_name TEXT;
    tables TEXT[] := ARRAY[
        'categorias_financeiras', 'receitas', 'despesas', 'contas_pagar',
        'historico_pagamentos_categorizado', 'historico_pagamentos_ingressos',
        'parcela_alertas', 'parcela_historico', 'projecoes_fluxo_caixa',
        'cliente_creditos', 'credito_historico', 'credito_logs', 'credito_viagem_vinculacoes',
        'categorias_produtos', 'produtos', 'pedidos', 'pedido_itens',
        'adversarios', 'games', 'game_buses', 'passengers',
        'sistema_parametros', 'system_config', 'user_profiles',
        'payments', 'stripe_customers',
        'lista_presenca', 'onibus_images', 'passageiro_passeios', 'viagens_ingressos'
    ];
BEGIN
    FOREACH table_name IN ARRAY tables
    LOOP
        -- Política para SELECT
        EXECUTE format('
            CREATE POLICY "Users can view %s from their organization"
            ON %s FOR SELECT
            TO authenticated
            USING (
                organization_id IN (
                    SELECT organization_id 
                    FROM user_permissions 
                    WHERE user_id = auth.uid()
                )
            )
        ', table_name, table_name);
        
        -- Política para INSERT/UPDATE/DELETE
        EXECUTE format('
            CREATE POLICY "Users can manage %s from their organization"
            ON %s FOR ALL
            TO authenticated
            USING (
                organization_id IN (
                    SELECT organization_id 
                    FROM user_permissions 
                    WHERE user_id = auth.uid()
                )
            )
            WITH CHECK (
                organization_id IN (
                    SELECT organization_id 
                    FROM user_permissions 
                    WHERE user_id = auth.uid()
                )
            )
        ', table_name, table_name);
    END LOOP;
END $$;

-- =====================================================
-- 10. INSERIR DADOS BÁSICOS DO SISTEMA (SEM CLIENTES)
-- =====================================================

-- Inserir categorias financeiras padrão para cada organização
INSERT INTO categorias_financeiras (organization_id, nome, tipo, cor)
SELECT 
    o.id,
    categoria.nome,
    categoria.tipo,
    categoria.cor
FROM organizations o
CROSS JOIN (
    VALUES 
        ('Passageiros', 'receita', '#10B981'),
        ('Patrocínios', 'receita', '#3B82F6'),
        ('Vendas', 'receita', '#8B5CF6'),
        ('Combustível', 'despesa', '#EF4444'),
        ('Pedágio', 'despesa', '#F59E0B'),
        ('Alimentação', 'despesa', '#EC4899'),
        ('Manutenção', 'despesa', '#6B7280')
) AS categoria(nome, tipo, cor)
ON CONFLICT DO NOTHING;

-- Inserir parâmetros básicos do sistema
INSERT INTO sistema_parametros (organization_id, chave, valor, tipo, descricao, categoria)
SELECT 
    o.id,
    param.chave,
    param.valor,
    param.tipo,
    param.descricao,
    param.categoria
FROM organizations o
CROSS JOIN (
    VALUES 
        ('max_passageiros_onibus', '50', 'number', 'Máximo de passageiros por ônibus', 'viagem'),
        ('dias_antecedencia_cancelamento', '7', 'number', 'Dias de antecedência para cancelamento', 'viagem'),
        ('percentual_desconto_credito', '10', 'number', 'Percentual de desconto para créditos', 'financeiro'),
        ('whatsapp_empresa', '', 'string', 'WhatsApp da empresa para contato', 'contato'),
        ('email_notificacoes', '', 'string', 'Email para receber notificações', 'contato')
) AS param(chave, valor, tipo, descricao, categoria)
ON CONFLICT DO NOTHING;

-- Inserir passeios básicos editáveis pelo admin
INSERT INTO passeios (organization_id, nome, descricao, preco, ativo)
SELECT 
    o.id,
    passeio.nome,
    passeio.descricao,
    passeio.preco,
    true
FROM organizations o
CROSS JOIN (
    VALUES 
        ('City Tour', 'Passeio pela cidade com pontos turísticos', 50.00),
        ('Almoço Especial', 'Almoço em restaurante típico da região', 35.00),
        ('Visita ao Estádio', 'Tour guiado pelo estádio', 25.00),
        ('Compras no Shopping', 'Tempo livre para compras', 0.00)
) AS passeio(nome, descricao, preco)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 11. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para organization_id (fundamental para multi-tenant)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_categorias_financeiras_org ON categorias_financeiras(organization_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_receitas_org ON receitas(organization_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_despesas_org ON despesas(organization_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_contas_pagar_org ON contas_pagar(organization_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_cliente_creditos_org ON cliente_creditos(organization_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_produtos_org ON produtos(organization_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pedidos_org ON pedidos(organization_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_games_org ON games(organization_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_adversarios_org ON adversarios(organization_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_org ON payments(organization_id);

-- Índices para consultas frequentes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_receitas_data ON receitas(data_recebimento);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_despesas_data ON despesas(data_vencimento);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_games_data ON games(data_jogo);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pedidos_status ON pedidos(status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_status ON payments(status);

-- =====================================================
-- 12. VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
    'Migração concluída com sucesso!' as status,
    COUNT(*) as total_tabelas_criadas
FROM information_schema.tables 
WHERE table_schema = 'public'
    AND table_name IN (
        'categorias_financeiras', 'receitas', 'despesas', 'contas_pagar',
        'historico_pagamentos_categorizado', 'historico_pagamentos_ingressos',
        'parcela_alertas', 'parcela_historico', 'projecoes_fluxo_caixa',
        'cliente_creditos', 'credito_historico', 'credito_logs', 'credito_viagem_vinculacoes',
        'categorias_produtos', 'produtos', 'pedidos', 'pedido_itens',
        'adversarios', 'games', 'game_buses', 'passengers',
        'sistema_parametros', 'system_config', 'user_profiles',
        'payments', 'stripe_customers',
        'lista_presenca', 'onibus_images', 'passageiro_passeios', 'viagens_ingressos'
    );

-- Verificar se todas as tabelas têm organization_id
SELECT 
    table_name,
    CASE 
        WHEN column_name IS NOT NULL THEN '✅ TEM organization_id'
        ELSE '❌ FALTA organization_id'
    END as status_multitenant
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON (
    t.table_name = c.table_name 
    AND c.column_name = 'organization_id'
)
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('organizations', 'profiles', 'super_admin_users')
ORDER BY t.table_name;

SELECT '🎉 Sistema multi-tenant pronto para uso com dados zerados!' as resultado;