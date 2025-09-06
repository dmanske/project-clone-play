-- Migração para completar o sistema multi-tenant
-- Adiciona organization_id às tabelas restantes e configura políticas RLS

-- =====================================================
-- ADICIONAR ORGANIZATION_ID ÀS TABELAS PRINCIPAIS
-- =====================================================

-- Tabela clientes
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_clientes_organization_id ON clientes(organization_id);

-- Tabela onibus
ALTER TABLE onibus ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_onibus_organization_id ON onibus(organization_id);

-- Tabela viagem_passageiros
ALTER TABLE viagem_passageiros ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_organization_id ON viagem_passageiros(organization_id);

-- Tabela ingressos
ALTER TABLE ingressos ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_ingressos_organization_id ON ingressos(organization_id);

-- Tabela creditos_clientes
ALTER TABLE creditos_clientes ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_creditos_clientes_organization_id ON creditos_clientes(organization_id);

-- Tabela empresa_config
ALTER TABLE empresa_config ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_empresa_config_organization_id ON empresa_config(organization_id);

-- Tabela viagem_receitas
ALTER TABLE viagem_receitas ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_viagem_receitas_organization_id ON viagem_receitas(organization_id);

-- Tabela viagem_despesas
ALTER TABLE viagem_despesas ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_viagem_despesas_organization_id ON viagem_despesas(organization_id);

-- Tabela viagem_cobranca_historico
ALTER TABLE viagem_cobranca_historico ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_viagem_cobranca_historico_organization_id ON viagem_cobranca_historico(organization_id);

-- Tabela viagem_orcamento
ALTER TABLE viagem_orcamento ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_viagem_orcamento_organization_id ON viagem_orcamento(organization_id);

-- Tabela viagem_passageiros_parcelas
ALTER TABLE viagem_passageiros_parcelas ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_parcelas_organization_id ON viagem_passageiros_parcelas(organization_id);

-- =====================================================
-- ATUALIZAR REGISTROS EXISTENTES
-- =====================================================

-- Atualizar clientes
UPDATE clientes 
SET organization_id = (
    SELECT id FROM organizations 
    ORDER BY created_at ASC 
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar onibus
UPDATE onibus 
SET organization_id = (
    SELECT id FROM organizations 
    ORDER BY created_at ASC 
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar viagem_passageiros baseado na viagem
UPDATE viagem_passageiros 
SET organization_id = (
    SELECT organization_id FROM viagens 
    WHERE viagens.id = viagem_passageiros.viagem_id
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar ingressos
UPDATE ingressos 
SET organization_id = (
    SELECT id FROM organizations 
    ORDER BY created_at ASC 
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar creditos_clientes baseado no cliente
UPDATE creditos_clientes 
SET organization_id = (
    SELECT organization_id FROM clientes 
    WHERE clientes.id = creditos_clientes.cliente_id
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar empresa_config
UPDATE empresa_config 
SET organization_id = (
    SELECT id FROM organizations 
    ORDER BY created_at ASC 
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar viagem_receitas baseado na viagem
UPDATE viagem_receitas 
SET organization_id = (
    SELECT organization_id FROM viagens 
    WHERE viagens.id = viagem_receitas.viagem_id
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar viagem_despesas baseado na viagem
UPDATE viagem_despesas 
SET organization_id = (
    SELECT organization_id FROM viagens 
    WHERE viagens.id = viagem_despesas.viagem_id
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar viagem_cobranca_historico baseado no passageiro
UPDATE viagem_cobranca_historico 
SET organization_id = (
    SELECT organization_id FROM viagem_passageiros 
    WHERE viagem_passageiros.id = viagem_cobranca_historico.viagem_passageiro_id
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar viagem_orcamento baseado na viagem
UPDATE viagem_orcamento 
SET organization_id = (
    SELECT organization_id FROM viagens 
    WHERE viagens.id = viagem_orcamento.viagem_id
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Atualizar viagem_passageiros_parcelas baseado no passageiro
UPDATE viagem_passageiros_parcelas 
SET organization_id = (
    SELECT organization_id FROM viagem_passageiros 
    WHERE viagem_passageiros.id = viagem_passageiros_parcelas.viagem_passageiro_id
    LIMIT 1
)
WHERE organization_id IS NULL;

-- =====================================================
-- TORNAR ORGANIZATION_ID OBRIGATÓRIO
-- =====================================================

ALTER TABLE clientes ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE onibus ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE viagem_passageiros ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE ingressos ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE creditos_clientes ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE empresa_config ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE viagem_receitas ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE viagem_despesas ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE viagem_cobranca_historico ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE viagem_orcamento ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE viagem_passageiros_parcelas ALTER COLUMN organization_id SET NOT NULL;

-- =====================================================
-- CONFIGURAR POLÍTICAS RLS
-- =====================================================

-- Remover políticas antigas e criar novas para clientes
DROP POLICY IF EXISTS "Público pode cadastrar clientes" ON clientes;
DROP POLICY IF EXISTS "Admin pode gerenciar clientes" ON clientes;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'clientes' AND policyname = 'Users can view organization clientes'
    ) THEN
        CREATE POLICY "Users can view organization clientes" ON clientes
        FOR SELECT USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'clientes' AND policyname = 'Users can manage organization clientes'
    ) THEN
        CREATE POLICY "Users can manage organization clientes" ON clientes
        FOR ALL USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        )
        WITH CHECK (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

-- Políticas para onibus
DROP POLICY IF EXISTS "Ônibus são públicos para visualização" ON onibus;
DROP POLICY IF EXISTS "Admin pode gerenciar ônibus" ON onibus;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'onibus' AND policyname = 'Users can view organization onibus'
    ) THEN
        CREATE POLICY "Users can view organization onibus" ON onibus
        FOR SELECT USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'onibus' AND policyname = 'Users can manage organization onibus'
    ) THEN
        CREATE POLICY "Users can manage organization onibus" ON onibus
        FOR ALL USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        )
        WITH CHECK (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

-- Políticas para viagem_passageiros
DROP POLICY IF EXISTS "Admin pode gerenciar passageiros" ON viagem_passageiros;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'viagem_passageiros' AND policyname = 'Users can view organization viagem_passageiros'
    ) THEN
        CREATE POLICY "Users can view organization viagem_passageiros" ON viagem_passageiros
        FOR SELECT USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'viagem_passageiros' AND policyname = 'Users can manage organization viagem_passageiros'
    ) THEN
        CREATE POLICY "Users can manage organization viagem_passageiros" ON viagem_passageiros
        FOR ALL USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        )
        WITH CHECK (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

-- Políticas para ingressos
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'ingressos' AND policyname = 'Users can view organization ingressos'
    ) THEN
        CREATE POLICY "Users can view organization ingressos" ON ingressos
        FOR SELECT USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'ingressos' AND policyname = 'Users can manage organization ingressos'
    ) THEN
        CREATE POLICY "Users can manage organization ingressos" ON ingressos
        FOR ALL USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        )
        WITH CHECK (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

-- Políticas para creditos_clientes
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'creditos_clientes' AND policyname = 'Users can view organization creditos_clientes'
    ) THEN
        CREATE POLICY "Users can view organization creditos_clientes" ON creditos_clientes
        FOR SELECT USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'creditos_clientes' AND policyname = 'Users can manage organization creditos_clientes'
    ) THEN
        CREATE POLICY "Users can manage organization creditos_clientes" ON creditos_clientes
        FOR ALL USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        )
        WITH CHECK (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

-- Políticas para empresa_config
DROP POLICY IF EXISTS "Configurações da empresa são públicas" ON empresa_config;

CREATE POLICY "Users can view organization empresa_config" ON empresa_config
    FOR SELECT USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

CREATE POLICY "Users can manage organization empresa_config" ON empresa_config
    FOR ALL USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    )
    WITH CHECK (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

-- Políticas para viagem_receitas
CREATE POLICY "Users can view organization viagem_receitas" ON viagem_receitas
    FOR SELECT USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

CREATE POLICY "Users can manage organization viagem_receitas" ON viagem_receitas
    FOR ALL USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    )
    WITH CHECK (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

-- Políticas para viagem_despesas
CREATE POLICY "Users can view organization viagem_despesas" ON viagem_despesas
    FOR SELECT USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

CREATE POLICY "Users can manage organization viagem_despesas" ON viagem_despesas
    FOR ALL USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    )
    WITH CHECK (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

-- Políticas para viagem_cobranca_historico
CREATE POLICY "Users can view organization viagem_cobranca_historico" ON viagem_cobranca_historico
    FOR SELECT USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

CREATE POLICY "Users can manage organization viagem_cobranca_historico" ON viagem_cobranca_historico
    FOR ALL USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    )
    WITH CHECK (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

-- Políticas para viagem_orcamento
CREATE POLICY "Users can view organization viagem_orcamento" ON viagem_orcamento
    FOR SELECT USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

CREATE POLICY "Users can manage organization viagem_orcamento" ON viagem_orcamento
    FOR ALL USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    )
    WITH CHECK (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

-- Políticas para viagem_passageiros_parcelas
CREATE POLICY "Users can view organization viagem_passageiros_parcelas" ON viagem_passageiros_parcelas
    FOR SELECT USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

CREATE POLICY "Users can manage organization viagem_passageiros_parcelas" ON viagem_passageiros_parcelas
    FOR ALL USING (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    )
    WITH CHECK (
        organization_id = (auth.jwt() ->> 'organization_id')::uuid
        OR auth.jwt() ->> 'role' = 'super_admin'
    );

-- =====================================================
-- COMENTÁRIOS PARA DOCUMENTAÇÃO
-- =====================================================

COMMENT ON COLUMN clientes.organization_id IS 'ID da organização que possui este cliente';
COMMENT ON COLUMN onibus.organization_id IS 'ID da organização que possui este ônibus';
COMMENT ON COLUMN viagem_passageiros.organization_id IS 'ID da organização que possui este passageiro';
COMMENT ON COLUMN ingressos.organization_id IS 'ID da organização que possui este ingresso';
COMMENT ON COLUMN creditos_clientes.organization_id IS 'ID da organização que possui este crédito';
COMMENT ON COLUMN empresa_config.organization_id IS 'ID da organização que possui esta configuração';
COMMENT ON COLUMN viagem_receitas.organization_id IS 'ID da organização que possui esta receita';
COMMENT ON COLUMN viagem_despesas.organization_id IS 'ID da organização que possui esta despesa';
COMMENT ON COLUMN viagem_cobranca_historico.organization_id IS 'ID da organização que possui este histórico';
COMMENT ON COLUMN viagem_orcamento.organization_id IS 'ID da organização que possui este orçamento';
COMMENT ON COLUMN viagem_passageiros_parcelas.organization_id IS 'ID da organização que possui esta parcela';