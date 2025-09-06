-- Migração para criar o sistema de configurações organizacionais
-- Task 7: Sistema de Configurações - OrganizationSettings com upload de logos e configurações

-- =====================================================
-- CRIAR TABELA ORGANIZATION_SETTINGS
-- =====================================================

CREATE TABLE IF NOT EXISTS organization_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Branding e Visual
    logo_empresa_url TEXT,
    logo_time_url TEXT,
    cor_primaria VARCHAR(7) DEFAULT '#000000',
    cor_secundaria VARCHAR(7) DEFAULT '#ffffff',
    favicon_url TEXT,
    
    -- Informações da Empresa para Relatórios
    nome_empresa VARCHAR(255),
    endereco_completo TEXT,
    telefone VARCHAR(20),
    email_contato VARCHAR(255),
    site_url TEXT,
    cnpj VARCHAR(18),
    
    -- Configurações de Passeios
    passeios_padrao JSONB DEFAULT '[]',
    valor_padrao_passeio DECIMAL(10,2),
    
    -- Configurações Regionais
    timezone VARCHAR(50) DEFAULT 'America/Sao_Paulo',
    moeda VARCHAR(3) DEFAULT 'BRL',
    idioma VARCHAR(5) DEFAULT 'pt-BR',
    formato_data VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    
    -- Configurações de Notificações
    email_notificacoes BOOLEAN DEFAULT true,
    whatsapp_notificacoes BOOLEAN DEFAULT false,
    whatsapp_numero VARCHAR(20),
    
    -- Configurações de Pagamento
    aceita_pix BOOLEAN DEFAULT true,
    aceita_cartao BOOLEAN DEFAULT true,
    aceita_dinheiro BOOLEAN DEFAULT true,
    taxa_cartao DECIMAL(5,2) DEFAULT 0.00,
    
    -- Configurações de Relatórios
    incluir_logo_relatorios BOOLEAN DEFAULT true,
    rodape_personalizado TEXT,
    
    -- Configurações Avançadas
    configuracoes_extras JSONB DEFAULT '{}',
    
    -- Controle
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(organization_id),
    CONSTRAINT valid_colors CHECK (
        cor_primaria ~ '^#[0-9A-Fa-f]{6}$' AND 
        cor_secundaria ~ '^#[0-9A-Fa-f]{6}$'
    ),
    CONSTRAINT valid_email CHECK (email_contato ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email_contato IS NULL),
    CONSTRAINT valid_cnpj CHECK (cnpj ~ '^[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}-[0-9]{2}$' OR cnpj IS NULL)
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_organization_settings_organization_id ON organization_settings(organization_id);
CREATE INDEX IF NOT EXISTS idx_organization_settings_updated_at ON organization_settings(updated_at);

-- =====================================================
-- TRIGGER PARA UPDATED_AT
-- =====================================================

CREATE OR REPLACE FUNCTION update_organization_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_organization_settings_updated_at
    BEFORE UPDATE ON organization_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_organization_settings_updated_at();

-- =====================================================
-- HABILITAR ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE organization_settings ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS RLS
-- =====================================================

-- Política para visualização (todos os usuários da organização)
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'organization_settings' AND policyname = 'Users can view their organization settings'
    ) THEN
        CREATE POLICY "Users can view their organization settings" ON organization_settings
        FOR SELECT USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

-- Política para gerenciamento (apenas admins da organização)
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'organization_settings' AND policyname = 'Admins can manage their organization settings'
    ) THEN
        CREATE POLICY "Admins can manage their organization settings" ON organization_settings
        FOR ALL USING (
            (organization_id = (auth.jwt() ->> 'organization_id')::uuid
             AND EXISTS (
                 SELECT 1 FROM user_permissions up
                 WHERE up.user_id = auth.uid()
                 AND up.organization_id = organization_settings.organization_id
                 AND up.role IN ('admin', 'owner')
             ))
            OR auth.jwt() ->> 'role' = 'super_admin'
        )
        WITH CHECK (
            (organization_id = (auth.jwt() ->> 'organization_id')::uuid
             AND EXISTS (
                 SELECT 1 FROM user_permissions up
                 WHERE up.user_id = auth.uid()
                 AND up.organization_id = organization_settings.organization_id
                 AND up.role IN ('admin', 'owner')
             ))
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

-- =====================================================
-- CRIAR CONFIGURAÇÕES PADRÃO PARA ORGANIZAÇÕES EXISTENTES
-- =====================================================

-- Inserir configurações padrão para organizações que não têm
INSERT INTO organization_settings (organization_id, nome_empresa)
SELECT 
    o.id,
    o.name
FROM organizations o
LEFT JOIN organization_settings os ON o.id = os.organization_id
WHERE os.id IS NULL;

-- =====================================================
-- COMENTÁRIOS PARA DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE organization_settings IS 'Configurações personalizáveis por organização (branding, contatos, etc.)';
COMMENT ON COLUMN organization_settings.organization_id IS 'ID da organização proprietária das configurações';
COMMENT ON COLUMN organization_settings.logo_empresa_url IS 'URL do logo da empresa (para relatórios e interface)';
COMMENT ON COLUMN organization_settings.logo_time_url IS 'URL do logo do time/clube (para relatórios específicos)';
COMMENT ON COLUMN organization_settings.cor_primaria IS 'Cor primária da organização em formato hexadecimal';
COMMENT ON COLUMN organization_settings.cor_secundaria IS 'Cor secundária da organização em formato hexadecimal';
COMMENT ON COLUMN organization_settings.passeios_padrao IS 'Array JSON com os passeios padrão inclusos para esta organização';
COMMENT ON COLUMN organization_settings.configuracoes_extras IS 'Configurações adicionais em formato JSON para extensibilidade';