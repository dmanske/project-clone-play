-- =====================================================
-- GESTÃO DE USUÁRIOS - TABELAS PARA MULTI-TENANCY
-- =====================================================

-- 1. ASSINATURAS DAS ORGANIZAÇÕES
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

-- 2. CONVITES DE USUÁRIOS
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

-- 3. PERMISSÕES DOS USUÁRIOS
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

-- 4. SUPER ADMINISTRADORES
-- =====================================================
CREATE TABLE IF NOT EXISTS super_admin_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);

-- =====================================================
-- POLÍTICAS RLS (ROW LEVEL SECURITY)
-- =====================================================

-- Habilitar RLS nas tabelas
ALTER TABLE organization_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE super_admin_users ENABLE ROW LEVEL SECURITY;

-- POLÍTICAS PARA ORGANIZATION_SUBSCRIPTIONS
-- =====================================================

-- Visualização: usuários da organização e super admins
CREATE POLICY "Users can view their organization subscription" ON organization_subscriptions
FOR SELECT USING (
    organization_id = (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    )
    OR auth.jwt() ->> 'role' = 'super_admin'
);

-- Gerenciamento: apenas super admins
CREATE POLICY "Super admins can manage subscriptions" ON organization_subscriptions
FOR ALL USING (auth.jwt() ->> 'role' = 'super_admin');

-- POLÍTICAS PARA USER_INVITATIONS
-- =====================================================

-- Visualização: admins da organização e super admins
CREATE POLICY "Admins can view organization invitations" ON user_invitations
FOR SELECT USING (
    (organization_id = (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    )
    AND EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.organization_id = user_invitations.organization_id
        AND p.role IN ('admin', 'owner')
    ))
    OR auth.jwt() ->> 'role' = 'super_admin'
);

-- Criação: admins da organização e super admins
CREATE POLICY "Admins can create invitations" ON user_invitations
FOR INSERT WITH CHECK (
    (organization_id = (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    )
    AND EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.organization_id = user_invitations.organization_id
        AND p.role IN ('admin', 'owner')
    ))
    OR auth.jwt() ->> 'role' = 'super_admin'
);

-- Atualização: admins da organização e super admins
CREATE POLICY "Admins can update invitations" ON user_invitations
FOR UPDATE USING (
    (organization_id = (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    )
    AND EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.organization_id = user_invitations.organization_id
        AND p.role IN ('admin', 'owner')
    ))
    OR auth.jwt() ->> 'role' = 'super_admin'
);

-- POLÍTICAS PARA USER_PERMISSIONS
-- =====================================================

-- Visualização: usuários podem ver suas próprias permissões, admins podem ver da organização
CREATE POLICY "Users can view permissions" ON user_permissions
FOR SELECT USING (
    user_id = auth.uid()
    OR (
        organization_id = (
            SELECT organization_id FROM profiles WHERE id = auth.uid()
        )
        AND EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid()
            AND p.organization_id = user_permissions.organization_id
            AND p.role IN ('admin', 'owner')
        )
    )
    OR auth.jwt() ->> 'role' = 'super_admin'
);

-- Gerenciamento: apenas admins da organização e super admins
CREATE POLICY "Admins can manage user permissions" ON user_permissions
FOR ALL USING (
    (organization_id = (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    )
    AND EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.organization_id = user_permissions.organization_id
        AND p.role IN ('admin', 'owner')
    ))
    OR auth.jwt() ->> 'role' = 'super_admin'
);

-- POLÍTICAS PARA SUPER_ADMIN_USERS
-- =====================================================

-- Apenas super admins podem gerenciar
CREATE POLICY "Super admins can manage super admin users" ON super_admin_users
FOR ALL USING (auth.jwt() ->> 'role' = 'super_admin');

-- =====================================================
-- TRIGGERS E FUNÇÕES
-- =====================================================

-- Função para criar permissões padrão quando um usuário é criado
CREATE OR REPLACE FUNCTION create_default_user_permissions()
RETURNS TRIGGER AS $$
BEGIN
    -- Criar permissões padrão apenas se o usuário tem organization_id
    IF NEW.organization_id IS NOT NULL THEN
        INSERT INTO user_permissions (user_id, organization_id, permissions)
        VALUES (
            NEW.id,
            NEW.organization_id,
            CASE 
                WHEN NEW.role = 'owner' THEN '{
                    "viagens": {"read": true, "write": true, "delete": true},
                    "clientes": {"read": true, "write": true, "delete": true},
                    "onibus": {"read": true, "write": true, "delete": true},
                    "financeiro": {"read": true, "write": true, "delete": true},
                    "relatorios": {"read": true, "write": true, "delete": true},
                    "configuracoes": {"read": true, "write": true, "delete": true},
                    "usuarios": {"read": true, "write": true, "delete": true}
                }'::jsonb
                WHEN NEW.role = 'admin' THEN '{
                    "viagens": {"read": true, "write": true, "delete": true},
                    "clientes": {"read": true, "write": true, "delete": true},
                    "onibus": {"read": true, "write": true, "delete": true},
                    "financeiro": {"read": true, "write": true, "delete": false},
                    "relatorios": {"read": true, "write": true, "delete": false},
                    "configuracoes": {"read": true, "write": true, "delete": false},
                    "usuarios": {"read": true, "write": true, "delete": false}
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
        )
        ON CONFLICT (user_id, organization_id) DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar permissões padrão
DROP TRIGGER IF EXISTS trigger_create_default_permissions ON profiles;
CREATE TRIGGER trigger_create_default_permissions
    AFTER INSERT ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION create_default_user_permissions();

-- Função para gerar token único para convites
CREATE OR REPLACE FUNCTION generate_invitation_token()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.token IS NULL OR NEW.token = '' THEN
        NEW.token := encode(gen_random_bytes(32), 'hex');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para gerar token de convite
DROP TRIGGER IF EXISTS trigger_generate_invitation_token ON user_invitations;
CREATE TRIGGER trigger_generate_invitation_token
    BEFORE INSERT ON user_invitations
    FOR EACH ROW
    EXECUTE FUNCTION generate_invitation_token();

-- =====================================================
-- INSERIR ASSINATURAS PADRÃO PARA ORGANIZAÇÕES EXISTENTES
-- =====================================================

-- Inserir assinaturas trial para organizações que não têm
INSERT INTO organization_subscriptions (organization_id, status, trial_start_date, trial_end_date)
SELECT 
    id,
    'TRIAL',
    NOW(),
    NOW() + INTERVAL '30 days'
FROM organizations
WHERE id NOT IN (SELECT organization_id FROM organization_subscriptions WHERE organization_id IS NOT NULL)
ON CONFLICT (organization_id) DO NOTHING;

-- =====================================================
-- COMENTÁRIOS PARA DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE organization_subscriptions IS 'Gerencia assinaturas e status de pagamento das organizações';
COMMENT ON TABLE user_invitations IS 'Convites para novos usuários se juntarem a organizações';
COMMENT ON TABLE user_permissions IS 'Permissões específicas de cada usuário por organização';
COMMENT ON TABLE super_admin_users IS 'Lista de usuários com privilégios de super administrador';

COMMENT ON COLUMN organization_subscriptions.status IS 'Status da assinatura: TRIAL, ACTIVE, SUSPENDED, BLOCKED';
COMMENT ON COLUMN user_invitations.status IS 'Status do convite: PENDING, ACCEPTED, EXPIRED, CANCELLED';
COMMENT ON COLUMN user_permissions.permissions IS 'Permissões JSONB por módulo do sistema';