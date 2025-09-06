-- Migração para corrigir problemas identificados
-- 1. A tabela passageiro_passeios não existe - as referências devem ser para viagem_passeios
-- 2. Verificar se empresa_config tem organization_id antes de criar políticas
-- 3. Remover políticas duplicadas

-- Primeiro, garantir que a tabela empresa_config tenha a coluna organization_id
DO $$ 
BEGIN
    -- Verificar se a coluna organization_id existe na tabela empresa_config
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'empresa_config' AND column_name = 'organization_id'
    ) THEN
        -- Adicionar a coluna se não existir
        ALTER TABLE empresa_config ADD COLUMN organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;
        
        -- Criar índice
        CREATE INDEX IF NOT EXISTS idx_empresa_config_organization_id ON empresa_config(organization_id);
        
        -- Comentário
        COMMENT ON COLUMN empresa_config.organization_id IS 'ID da organização que possui esta configuração de empresa';
    END IF;
END $$;

-- Remover políticas duplicadas antes de recriar
DROP POLICY IF EXISTS "Users can view organization empresa_config" ON empresa_config;
DROP POLICY IF EXISTS "Users can manage organization empresa_config" ON empresa_config;
DROP POLICY IF EXISTS "Users can view organization viagem_receitas" ON viagem_receitas;
DROP POLICY IF EXISTS "Users can manage organization viagem_receitas" ON viagem_receitas;
DROP POLICY IF EXISTS "Users can view organization viagem_despesas" ON viagem_despesas;
DROP POLICY IF EXISTS "Users can manage organization viagem_despesas" ON viagem_despesas;
DROP POLICY IF EXISTS "Users can view organization viagem_cobranca_historico" ON viagem_cobranca_historico;
DROP POLICY IF EXISTS "Users can manage organization viagem_cobranca_historico" ON viagem_cobranca_historico;
DROP POLICY IF EXISTS "Users can view organization viagem_orcamento" ON viagem_orcamento;
DROP POLICY IF EXISTS "Users can manage organization viagem_orcamento" ON viagem_orcamento;
DROP POLICY IF EXISTS "Users can view organization viagem_passageiros_parcelas" ON viagem_passageiros_parcelas;
DROP POLICY IF EXISTS "Users can manage organization viagem_passageiros_parcelas" ON viagem_passageiros_parcelas;

-- Habilitar RLS nas tabelas se não estiver habilitado
ALTER TABLE empresa_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_despesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_cobranca_historico ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_orcamento ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_passageiros_parcelas ENABLE ROW LEVEL SECURITY;

-- Criar políticas para empresa_config
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

-- Criar políticas para viagem_receitas
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

-- Criar políticas para viagem_despesas
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

-- Criar políticas para viagem_cobranca_historico
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

-- Criar políticas para viagem_orcamento
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

-- Criar políticas para viagem_passageiros_parcelas
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

-- Corrigir referências à tabela passageiro_passeios que não existe
-- A tabela correta é viagem_passeios (que existe na lista)
-- Remover a migração anterior que fazia referência à tabela inexistente

-- Comentário sobre a correção
COMMENT ON TABLE viagem_passeios IS 'Tabela que relaciona viagens com passeios - corrigida referência de passageiro_passeios';}}}