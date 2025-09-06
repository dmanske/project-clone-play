-- =====================================================
-- FIX PROFILES TABLE STRUCTURE
-- Adicionar colunas faltantes na tabela profiles
-- =====================================================

-- Adicionar colunas necessárias para o AuthContext (apenas se não existirem)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') THEN
        ALTER TABLE profiles ADD COLUMN email TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'full_name') THEN
        ALTER TABLE profiles ADD COLUMN full_name TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'organization_id') THEN
        ALTER TABLE profiles ADD COLUMN organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'role') THEN
        ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'user', 'viewer', 'owner'));
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'active') THEN
        ALTER TABLE profiles ADD COLUMN active BOOLEAN DEFAULT true;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'avatar_url') THEN
        ALTER TABLE profiles ADD COLUMN avatar_url TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'permissions') THEN
        ALTER TABLE profiles ADD COLUMN permissions JSONB DEFAULT '{}';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'updated_at') THEN
        ALTER TABLE profiles ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Criar índices para melhor performance (apenas se não existirem)
CREATE INDEX IF NOT EXISTS profiles_email_idx ON profiles(email);
CREATE INDEX IF NOT EXISTS profiles_organization_id_idx ON profiles(organization_id);
CREATE INDEX IF NOT EXISTS profiles_role_idx ON profiles(role);
CREATE INDEX IF NOT EXISTS profiles_active_idx ON profiles(active);

-- Atualizar registros existentes para ter valores padrão
-- Verificar se a coluna 'nome' existe antes de usá-la
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'nome'
    ) THEN
        UPDATE profiles SET 
            email = COALESCE(email, ''),
            full_name = COALESCE(full_name, nome, ''),
            role = COALESCE(role, 'user'),
            active = COALESCE(active, true),
            permissions = COALESCE(permissions, '{}'),
            updated_at = COALESCE(updated_at, NOW())
        WHERE email IS NULL OR full_name IS NULL OR role IS NULL OR active IS NULL;
    ELSE
        UPDATE profiles SET 
            email = COALESCE(email, ''),
            full_name = COALESCE(full_name, ''),
            role = COALESCE(role, 'user'),
            active = COALESCE(active, true),
            permissions = COALESCE(permissions, '{}'),
            updated_at = COALESCE(updated_at, NOW())
        WHERE email IS NULL OR full_name IS NULL OR role IS NULL OR active IS NULL;
    END IF;
END $$;

-- Criar trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários para documentação
COMMENT ON COLUMN profiles.email IS 'Email do usuário (sincronizado com auth.users)';
COMMENT ON COLUMN profiles.full_name IS 'Nome completo do usuário';
COMMENT ON COLUMN profiles.organization_id IS 'ID da organização à qual o usuário pertence';
COMMENT ON COLUMN profiles.role IS 'Papel do usuário na organização (admin, user, viewer, owner)';
COMMENT ON COLUMN profiles.active IS 'Se o usuário está ativo no sistema';
COMMENT ON COLUMN profiles.avatar_url IS 'URL do avatar do usuário';
COMMENT ON COLUMN profiles.permissions IS 'Permissões específicas do usuário em formato JSON';

-- Verificar se as colunas foram adicionadas com sucesso
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'profiles'
ORDER BY ordinal_position;

SELECT '✅ Migração da tabela profiles concluída com sucesso!' as resultado;