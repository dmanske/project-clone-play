-- Script para aplicar a migração de gestão de usuários
-- Execute este SQL no Supabase Dashboard > SQL Editor

-- Create organization_subscriptions table
CREATE TABLE IF NOT EXISTS organization_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL CHECK (plan_type IN ('trial', 'basic', 'premium', 'enterprise')),
  status TEXT NOT NULL CHECK (status IN ('active', 'canceled', 'past_due', 'trialing')),
  trial_ends_at TIMESTAMP WITH TIME ZONE,
  current_period_start TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
  stripe_subscription_id TEXT,
  stripe_customer_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(organization_id)
);

-- Create user_invitations table
CREATE TABLE IF NOT EXISTS user_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'user', 'viewer')),
  invited_by UUID NOT NULL REFERENCES profiles(id),
  token TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  accepted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(organization_id, email)
);

-- Create user_permissions table
CREATE TABLE IF NOT EXISTS user_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  permissions JSONB NOT NULL DEFAULT '{
    "viagens": {"read": true, "write": false, "delete": false},
    "clientes": {"read": true, "write": false, "delete": false},
    "onibus": {"read": true, "write": false, "delete": false},
    "financeiro": {"read": false, "write": false, "delete": false},
    "relatorios": {"read": true, "write": false, "delete": false},
    "configuracoes": {"read": false, "write": false, "delete": false},
    "usuarios": {"read": false, "write": false, "delete": false}
  }',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, organization_id)
);

-- Create super_admin_users table
CREATE TABLE IF NOT EXISTS super_admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES profiles(id)
);

-- Enable RLS on all tables
ALTER TABLE organization_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE super_admin_users ENABLE ROW LEVEL SECURITY;

-- RLS Policies for organization_subscriptions
DROP POLICY IF EXISTS "Users can view their organization subscription" ON organization_subscriptions;
CREATE POLICY "Users can view their organization subscription" ON organization_subscriptions
  FOR SELECT USING (
    organization_id IN (
      SELECT organization_id FROM profiles WHERE id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins can manage organization subscription" ON organization_subscriptions;
CREATE POLICY "Admins can manage organization subscription" ON organization_subscriptions
  FOR ALL USING (
    organization_id IN (
      SELECT organization_id FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'owner')
    )
    OR EXISTS (
      SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
    )
  );

-- RLS Policies for user_invitations
DROP POLICY IF EXISTS "Users can view invitations for their organization" ON user_invitations;
CREATE POLICY "Users can view invitations for their organization" ON user_invitations
  FOR SELECT USING (
    organization_id IN (
      SELECT organization_id FROM profiles WHERE id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins can manage invitations" ON user_invitations;
CREATE POLICY "Admins can manage invitations" ON user_invitations
  FOR ALL USING (
    organization_id IN (
      SELECT organization_id FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'owner')
    )
    OR EXISTS (
      SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
    )
  );

-- RLS Policies for user_permissions
DROP POLICY IF EXISTS "Users can view their own permissions" ON user_permissions;
CREATE POLICY "Users can view their own permissions" ON user_permissions
  FOR SELECT USING (
    user_id = auth.uid()
    OR organization_id IN (
      SELECT organization_id FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'owner')
    )
    OR EXISTS (
      SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins can manage user permissions" ON user_permissions;
CREATE POLICY "Admins can manage user permissions" ON user_permissions
  FOR ALL USING (
    organization_id IN (
      SELECT organization_id FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'owner')
    )
    OR EXISTS (
      SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
    )
  );

-- RLS Policies for super_admin_users
DROP POLICY IF EXISTS "Only super admins can view super admin users" ON super_admin_users;
CREATE POLICY "Only super admins can view super admin users" ON super_admin_users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Only super admins can manage super admin users" ON super_admin_users;
CREATE POLICY "Only super admins can manage super admin users" ON super_admin_users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM super_admin_users WHERE user_id = auth.uid()
    )
  );

-- Function to create default permissions for new users
CREATE OR REPLACE FUNCTION create_default_user_permissions()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create permissions if the user has an organization_id
  IF NEW.organization_id IS NOT NULL THEN
    INSERT INTO user_permissions (user_id, organization_id)
    VALUES (NEW.id, NEW.organization_id)
    ON CONFLICT (user_id, organization_id) DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create default permissions when a user is created or updated
DROP TRIGGER IF EXISTS create_user_permissions_trigger ON profiles;
CREATE TRIGGER create_user_permissions_trigger
  AFTER INSERT OR UPDATE OF organization_id ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION create_default_user_permissions();

-- Function to generate invitation tokens
CREATE OR REPLACE FUNCTION generate_invitation_token()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.token IS NULL OR NEW.token = '' THEN
    NEW.token := encode(gen_random_bytes(32), 'base64');
  END IF;
  
  IF NEW.expires_at IS NULL THEN
    NEW.expires_at := NOW() + INTERVAL '7 days';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para buscar permissões de múltiplos usuários
CREATE OR REPLACE FUNCTION get_user_permissions(user_ids UUID[])
RETURNS TABLE(
  id UUID,
  user_id UUID,
  organization_id UUID,
  permissions JSONB,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    up.id,
    up.user_id,
    up.organization_id,
    up.permissions,
    up.created_at,
    up.updated_at
  FROM user_permissions up
  WHERE up.user_id = ANY(user_ids);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para inserir ou atualizar permissões de usuário
CREATE OR REPLACE FUNCTION upsert_user_permissions(
  p_user_id UUID,
  p_organization_id UUID,
  p_permissions JSONB
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO user_permissions (user_id, organization_id, permissions)
  VALUES (p_user_id, p_organization_id, p_permissions)
  ON CONFLICT (user_id, organization_id)
  DO UPDATE SET 
    permissions = EXCLUDED.permissions,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para deletar permissões de usuário
CREATE OR REPLACE FUNCTION delete_user_permissions(
  p_user_id UUID,
  p_organization_id UUID
)
RETURNS VOID AS $$
BEGIN
  DELETE FROM user_permissions 
  WHERE user_id = p_user_id AND organization_id = p_organization_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para buscar permissões de um usuário específico
CREATE OR REPLACE FUNCTION get_user_permissions_by_id(
  p_user_id UUID,
  p_organization_id UUID
)
RETURNS JSONB AS $$
DECLARE
  user_permissions JSONB;
BEGIN
  SELECT permissions INTO user_permissions
  FROM user_permissions
  WHERE user_id = p_user_id AND organization_id = p_organization_id;
  
  -- Se não encontrar permissões, retornar permissões padrão
  IF user_permissions IS NULL THEN
    RETURN '{
      "viagens": {"read": true, "write": false, "delete": false},
      "clientes": {"read": true, "write": false, "delete": false},
      "onibus": {"read": true, "write": false, "delete": false},
      "financeiro": {"read": false, "write": false, "delete": false},
      "relatorios": {"read": true, "write": false, "delete": false},
      "configuracoes": {"read": false, "write": false, "delete": false},
      "usuarios": {"read": false, "write": false, "delete": false}
    }'::JSONB;
  END IF;
  
  RETURN user_permissions;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to generate invitation tokens
DROP TRIGGER IF EXISTS generate_invitation_token_trigger ON user_invitations;
CREATE TRIGGER generate_invitation_token_trigger
  BEFORE INSERT ON user_invitations
  FOR EACH ROW
  EXECUTE FUNCTION generate_invitation_token();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_organization_subscriptions_updated_at ON organization_subscriptions;
CREATE TRIGGER update_organization_subscriptions_updated_at
  BEFORE UPDATE ON organization_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_invitations_updated_at ON user_invitations;
CREATE TRIGGER update_user_invitations_updated_at
  BEFORE UPDATE ON user_invitations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_permissions_updated_at ON user_permissions;
CREATE TRIGGER update_user_permissions_updated_at
  BEFORE UPDATE ON user_permissions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Verificar se as tabelas foram criadas com sucesso
SELECT 
  table_name,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' AND table_name = t.table_name
    ) THEN 'CRIADA' 
    ELSE 'NÃO CRIADA' 
  END as status
FROM (
  VALUES 
    ('organization_subscriptions'),
    ('user_invitations'),
    ('user_permissions'),
    ('super_admin_users')
) AS t(table_name);

-- Mostrar estrutura das tabelas criadas
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name IN ('organization_subscriptions', 'user_invitations', 'user_permissions', 'super_admin_users')
ORDER BY table_name, ordinal_position;