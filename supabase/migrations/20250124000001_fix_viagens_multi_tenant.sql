-- Migração para adaptar a tabela viagens ao sistema multi-tenant
-- Atualiza políticas RLS para isolamento por organização

-- A coluna organization_id já existe, vamos criar o índice
CREATE INDEX IF NOT EXISTS idx_viagens_organization_id ON viagens(organization_id);

-- Remover políticas antigas
DROP POLICY IF EXISTS "Viagens são públicas para visualização" ON viagens;
DROP POLICY IF EXISTS "Admin pode gerenciar viagens" ON viagens;

-- Criar novas políticas RLS para isolamento por organização
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'viagens' AND policyname = 'Users can view organization viagens'
    ) THEN
        CREATE POLICY "Users can view organization viagens" ON viagens
        FOR SELECT USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'viagens' AND policyname = 'Users can manage organization viagens'
    ) THEN
        CREATE POLICY "Users can manage organization viagens" ON viagens
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

-- Atualizar registros existentes para ter uma organização padrão
-- (assumindo que existe pelo menos uma organização)
UPDATE viagens 
SET organization_id = (
    SELECT id FROM organizations 
    ORDER BY created_at ASC 
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Tornar organization_id obrigatório após a atualização
ALTER TABLE viagens ALTER COLUMN organization_id SET NOT NULL;

-- Comentário para documentação
COMMENT ON COLUMN viagens.organization_id IS 'ID da organização que possui esta viagem';