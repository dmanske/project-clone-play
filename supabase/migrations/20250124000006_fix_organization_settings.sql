-- Migração para corrigir problemas na tabela organization_settings
-- Garantir que a tabela tenha a estrutura correta

-- =====================================================
-- VERIFICAR E CORRIGIR TABELA ORGANIZATION_SETTINGS
-- =====================================================

-- Recriar a tabela se necessário (com backup dos dados existentes)
DO $$ 
BEGIN
    -- Se a tabela existe mas não tem a coluna nome_empresa, precisamos corrigi-la
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organization_settings' AND table_schema = 'public') THEN
        -- Verificar se a coluna nome_empresa existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
                AND table_name = 'organization_settings' 
                AND column_name = 'nome_empresa'
        ) THEN
            -- Adicionar a coluna nome_empresa se não existir
            ALTER TABLE organization_settings ADD COLUMN nome_empresa VARCHAR(255);
            RAISE NOTICE 'Coluna nome_empresa adicionada à tabela organization_settings';
        END IF;
        
        -- Verificar outras colunas essenciais e adicioná-las se necessário
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
                AND table_name = 'organization_settings' 
                AND column_name = 'logo_empresa_url'
        ) THEN
            ALTER TABLE organization_settings ADD COLUMN logo_empresa_url TEXT;
        END IF;
        
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
                AND table_name = 'organization_settings' 
                AND column_name = 'cor_primaria'
        ) THEN
            ALTER TABLE organization_settings ADD COLUMN cor_primaria VARCHAR(7) DEFAULT '#000000';
        END IF;
        
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
                AND table_name = 'organization_settings' 
                AND column_name = 'cor_secundaria'
        ) THEN
            ALTER TABLE organization_settings ADD COLUMN cor_secundaria VARCHAR(7) DEFAULT '#ffffff';
        END IF;
        
    ELSE
        -- Se a tabela não existe, criar ela completamente
        CREATE TABLE organization_settings (
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
        
        -- Criar índices
        CREATE INDEX IF NOT EXISTS idx_organization_settings_organization_id ON organization_settings(organization_id);
        CREATE INDEX IF NOT EXISTS idx_organization_settings_updated_at ON organization_settings(updated_at);
        
        -- Habilitar RLS
        ALTER TABLE organization_settings ENABLE ROW LEVEL SECURITY;
        
        RAISE NOTICE 'Tabela organization_settings criada completamente';
    END IF;
END $$;

-- =====================================================
-- GARANTIR POLÍTICAS RLS
-- =====================================================

-- Remover políticas existentes para recriar
DROP POLICY IF EXISTS "Users can view their organization settings" ON organization_settings;
DROP POLICY IF EXISTS "Admins can manage their organization settings" ON organization_settings;

-- Política para visualização
CREATE POLICY "Users can view their organization settings" ON organization_settings
FOR SELECT USING (
    organization_id = (auth.jwt() ->> 'organization_id')::uuid
    OR auth.jwt() ->> 'role' = 'super_admin'
);

-- Política para gerenciamento
CREATE POLICY "Admins can manage their organization settings" ON organization_settings
FOR ALL USING (
    (organization_id = (auth.jwt() ->> 'organization_id')::uuid
     AND EXISTS (
         SELECT 1 FROM profiles p
         WHERE p.id = auth.uid()
         AND p.organization_id = organization_settings.organization_id
         AND p.role IN ('admin', 'owner')
     ))
    OR auth.jwt() ->> 'role' = 'super_admin'
)
WITH CHECK (
    (organization_id = (auth.jwt() ->> 'organization_id')::uuid
     AND EXISTS (
         SELECT 1 FROM profiles p
         WHERE p.id = auth.uid()
         AND p.organization_id = organization_settings.organization_id
         AND p.role IN ('admin', 'owner')
     ))
    OR auth.jwt() ->> 'role' = 'super_admin'
);

-- =====================================================
-- INSERIR CONFIGURAÇÕES PADRÃO PARA ORGANIZAÇÕES EXISTENTES
-- =====================================================

-- Inserir configurações padrão apenas se não existirem
INSERT INTO organization_settings (organization_id, nome_empresa)
SELECT 
    o.id,
    o.name
FROM organizations o
LEFT JOIN organization_settings os ON o.id = os.organization_id
WHERE os.id IS NULL
ON CONFLICT (organization_id) DO NOTHING;

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

DROP TRIGGER IF EXISTS trigger_organization_settings_updated_at ON organization_settings;
CREATE TRIGGER trigger_organization_settings_updated_at
    BEFORE UPDATE ON organization_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_organization_settings_updated_at();