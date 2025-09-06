-- =====================================================
-- SISTEMA MULTI-TENANT SAAS - ESTRUTURA DO BANCO
-- =====================================================

-- 1. TABELA DE ASSINATURAS DAS ORGANIZAÇÕES
-- =====================================================
CREATE TABLE IF NOT EXISTS organization_subscriptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Status da assinatura
    status VARCHAR(20) NOT NULL DEFAULT 'TRIAL' CHECK (status IN ('TRIAL', 'ACTIVE', 'SUSPENDED', 'BLOCKED')),
    
    -- Datas importantes
    trial_start_date TIMESTAMPTZ DEFAULT NOW(),
    trial_end_date TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
    subscription_start_date TIMESTAMPTZ,
    subscription_end_date TIMESTAMPTZ,
    
    -- Stripe
    stripe_customer_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    stripe_price_id VARCHAR(255),
    
    -- Controle
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Índices
    UNIQUE(organization_id)
);

-- 2. CONFIGURAÇÕES DAS ORGANIZAÇÕES
-- =====================================================
CREATE TABLE IF NOT EXISTS organization_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Branding
    logo_empresa_url TEXT,
    logo_time_url TEXT,
    cor_primaria VARCHAR(7) DEFAULT '#000000',
    cor_secundaria VARCHAR(7) DEFAULT '#ffffff',
    
    -- Informações para relatórios
    endereco_completo TEXT,
    telefone VARCHAR(20),
    email_contato VARCHAR(255),
    site_url TEXT,
    
    -- Configurações de passeios
    passeios_padrao JSONB DEFAULT '[]',
    
    -- Configurações gerais
    timezone VARCHAR(50) DEFAULT 'America/Sao_Paulo',
    moeda VARCHAR(3) DEFAULT 'BRL',
    
    -- Controle
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Índices
    UNIQUE(organization_id)
);

-- 3. CONVITES DE USUÁRIOS
-- =====================================================
CREATE TABLE IF NOT EXISTS user_invitations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Dados do convite
    email VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    permissions JSONB DEFAULT '{}',
    
    -- Controle do convite
    invited_by UUID REFERENCES profiles(id),
    token VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'EXPIRED', 'CANCELLED')),
    
    -- Datas
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
    accepted_at TIMESTAMPTZ,
    
    -- Controle
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. PERMISSÕES DOS USUÁRIOS
-- =====================================================
CREATE TABLE IF NOT EXISTS user_permissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Permissões específicas
    permissions JSONB NOT NULL DEFAULT '{
        "viagens": {"read": true, "write": false, "delete": false},
        "clientes": {"read": true, "write": false, "delete": false},
        "onibus": {"read": true, "write": false, "delete": false},
        "financeiro": {"read": false, "write": false, "delete": false},
        "relatorios": {"read": true, "write": false, "delete": false},
        "configuracoes": {"read": false, "write": false, "delete": false},
        "usuarios": {"read": false, "write": false, "delete": false}
    }',
    
    -- Controle
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Índices
    UNIQUE(user_id, organization_id)
);

-- 5. SUPER ADMINISTRADORES
-- =====================================================
CREATE TABLE IF NOT EXISTS super_admin_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Permissões de super admin
    can_access_all_tenants BOOLEAN DEFAULT true,
    can_manage_subscriptions BOOLEAN DEFAULT true,
    can_block_organizations BOOLEAN DEFAULT true,
    can_view_analytics BOOLEAN DEFAULT true,
    
    -- Controle
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Índices
    UNIQUE(user_id)
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para organization_subscriptions
CREATE INDEX IF NOT EXISTS idx_org_subscriptions_status ON organization_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_org_subscriptions_trial_end ON organization_subscriptions(trial_end_date);
CREATE INDEX IF NOT EXISTS idx_org_subscriptions_stripe_customer ON organization_subscriptions(stripe_customer_id);

-- Índices para user_invitations
CREATE INDEX IF NOT EXISTS idx_user_invitations_email ON user_invitations(email);
CREATE INDEX IF NOT EXISTS idx_user_invitations_token ON user_invitations(token);
CREATE INDEX IF NOT EXISTS idx_user_invitations_status ON user_invitations(status);
CREATE INDEX IF NOT EXISTS idx_user_invitations_expires ON user_invitations(expires_at);

-- Índices para user_permissions
CREATE INDEX IF NOT EXISTS idx_user_permissions_user ON user_permissions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_permissions_org ON user_permissions(organization_id);

-- =====================================================
-- RLS POLICIES
-- =====================================================

-- Habilitar RLS
ALTER TABLE organization_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE super_admin_users ENABLE ROW LEVEL SECURITY;

-- Policies para organization_subscriptions
CREATE POLICY "Users can view their organization subscription" ON organization_subscriptions
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM profiles WHERE id = auth.uid()
        )
    );

CREATE POLICY "Super admins can view all subscriptions" ON organization_subscriptions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- Policies para organization_settings
CREATE POLICY "Users can view their organization settings" ON organization_settings
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM profiles WHERE id = auth.uid()
        )
    );

CREATE POLICY "Admins can update their organization settings" ON organization_settings
    FOR UPDATE USING (
        organization_id IN (
            SELECT organization_id FROM profiles 
            WHERE id = auth.uid() AND role IN ('admin', 'owner')
        )
    );

-- Policies para user_invitations
CREATE POLICY "Users can view invitations for their organization" ON user_invitations
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM profiles WHERE id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage invitations for their organization" ON user_invitations
    FOR ALL USING (
        organization_id IN (
            SELECT organization_id FROM profiles 
            WHERE id = auth.uid() AND role IN ('admin', 'owner')
        )
    );

-- Policies para user_permissions
CREATE POLICY "Users can view their own permissions" ON user_permissions
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Admins can manage permissions in their organization" ON user_permissions
    FOR ALL USING (
        organization_id IN (
            SELECT organization_id FROM profiles 
            WHERE id = auth.uid() AND role IN ('admin', 'owner')
        )
    );

-- Policies para super_admin_users
CREATE POLICY "Only super admins can view super admin table" ON super_admin_users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
        )
    );

-- =====================================================
-- FUNCTIONS AUXILIARES
-- =====================================================

-- Function para criar assinatura trial automática
CREATE OR REPLACE FUNCTION create_trial_subscription()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO organization_subscriptions (organization_id, status, trial_start_date, trial_end_date)
    VALUES (NEW.id, 'TRIAL', NOW(), NOW() + INTERVAL '7 days');
    
    INSERT INTO organization_settings (organization_id)
    VALUES (NEW.id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para criar assinatura automática
DROP TRIGGER IF EXISTS trigger_create_trial_subscription ON organizations;
CREATE TRIGGER trigger_create_trial_subscription
    AFTER INSERT ON organizations
    FOR EACH ROW
    EXECUTE FUNCTION create_trial_subscription();

-- Function para verificar se organização está ativa
CREATE OR REPLACE FUNCTION is_organization_active(org_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    subscription_status VARCHAR(20);
    trial_end TIMESTAMPTZ;
BEGIN
    SELECT status, trial_end_date 
    INTO subscription_status, trial_end
    FROM organization_subscriptions 
    WHERE organization_id = org_id;
    
    IF subscription_status IS NULL THEN
        RETURN FALSE;
    END IF;
    
    CASE subscription_status
        WHEN 'ACTIVE' THEN RETURN TRUE;
        WHEN 'TRIAL' THEN RETURN (trial_end > NOW());
        ELSE RETURN FALSE;
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Function para criar permissões padrão para novos usuários
CREATE OR REPLACE FUNCTION create_default_permissions()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_permissions (user_id, organization_id, permissions)
    VALUES (NEW.id, NEW.organization_id, 
        CASE NEW.role
            WHEN 'admin' THEN '{
                "viagens": {"read": true, "write": true, "delete": true},
                "clientes": {"read": true, "write": true, "delete": true},
                "onibus": {"read": true, "write": true, "delete": true},
                "financeiro": {"read": true, "write": true, "delete": true},
                "relatorios": {"read": true, "write": true, "delete": false},
                "configuracoes": {"read": true, "write": true, "delete": false},
                "usuarios": {"read": true, "write": true, "delete": true}
            }'::jsonb
            WHEN 'owner' THEN '{
                "viagens": {"read": true, "write": true, "delete": true},
                "clientes": {"read": true, "write": true, "delete": true},
                "onibus": {"read": true, "write": true, "delete": true},
                "financeiro": {"read": true, "write": true, "delete": true},
                "relatorios": {"read": true, "write": true, "delete": true},
                "configuracoes": {"read": true, "write": true, "delete": true},
                "usuarios": {"read": true, "write": true, "delete": true}
            }'::jsonb
            ELSE '{
                "viagens": {"read": true, "write": false, "delete": false},
                "clientes": {"read": true, "write": false, "delete": false},
                "onibus": {"read": true, "write": false, "delete": false},
                "financeiro": {"read": false, "write": false, "delete": false},
                "relatorios": {"read": true, "write": false, "delete": false},
                "configuracoes": {"read": false, "write": false, "delete": false},
                "usuarios": {"read": false, "write": false, "delete": false}
            }'::jsonb
        END
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para criar permissões automáticas
DROP TRIGGER IF EXISTS trigger_create_default_permissions ON profiles;
CREATE TRIGGER trigger_create_default_permissions
    AFTER INSERT ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION create_default_permissions();

-- =====================================================
-- DADOS INICIAIS
-- =====================================================

-- Inserir você como super admin (substitua pelo seu user_id real)
-- INSERT INTO super_admin_users (user_id, can_access_all_tenants, can_manage_subscriptions, can_block_organizations, can_view_analytics)
-- VALUES ('SEU_USER_ID_AQUI', true, true, true, true);

-- =====================================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE organization_subscriptions IS 'Controla as assinaturas e status de pagamento das organizações';
COMMENT ON TABLE organization_settings IS 'Configurações personalizáveis por organização (branding, contatos, etc.)';
COMMENT ON TABLE user_invitations IS 'Sistema de convites para novos usuários das organizações';
COMMENT ON TABLE user_permissions IS 'Permissões granulares dos usuários por organização';
COMMENT ON TABLE super_admin_users IS 'Usuários com acesso de super administrador ao sistema';

COMMENT ON COLUMN organization_subscriptions.status IS 'TRIAL: período gratuito, ACTIVE: pagamento em dia, SUSPENDED: pagamento atrasado, BLOCKED: bloqueado pelo admin';
COMMENT ON COLUMN organization_settings.passeios_padrao IS 'Array JSON com os passeios padrão inclusos para esta organização';
COMMENT ON COLUMN user_permissions.permissions IS 'Objeto JSON com permissões granulares por módulo do sistema';