-- Migração para adaptar a tabela passeios ao sistema multi-tenant
-- Adiciona organization_id e atualiza políticas RLS

-- Adicionar coluna organization_id à tabela passeios
ALTER TABLE passeios ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;

-- Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_passeios_organization_id ON passeios(organization_id);

-- Remover políticas antigas
DROP POLICY IF EXISTS "Admins podem gerenciar passeios" ON passeios;
DROP POLICY IF EXISTS "Passeios são públicos" ON passeios;

-- Criar novas políticas RLS para isolamento por organização
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'passeios' AND policyname = 'Users can view organization passeios'
    ) THEN
        CREATE POLICY "Users can view organization passeios" ON passeios
         FOR SELECT USING (
             organization_id = (auth.jwt() ->> 'organization_id')::uuid
             OR auth.jwt() ->> 'role' = 'super_admin'
         );
     END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'passeios' AND policyname = 'Users can manage organization passeios'
    ) THEN
        CREATE POLICY "Users can manage organization passeios" ON passeios
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
UPDATE passeios 
SET organization_id = (
    SELECT id FROM organizations 
    ORDER BY created_at ASC 
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Tornar organization_id obrigatório após a atualização
ALTER TABLE passeios ALTER COLUMN organization_id SET NOT NULL;

-- Adicionar organization_id às outras tabelas relacionadas se necessário
ALTER TABLE viagem_passeios ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE;

-- Criar índices para as novas colunas
CREATE INDEX IF NOT EXISTS idx_viagem_passeios_organization_id ON viagem_passeios(organization_id);

-- Atualizar políticas RLS para viagem_passeios
DROP POLICY IF EXISTS "Users can view viagem_passeios" ON viagem_passeios;
DROP POLICY IF EXISTS "Users can manage viagem_passeios" ON viagem_passeios;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'viagem_passeios' AND policyname = 'Users can view organization viagem_passeios'
    ) THEN
        CREATE POLICY "Users can view organization viagem_passeios" ON viagem_passeios
        FOR SELECT USING (
            organization_id = (auth.jwt() ->> 'organization_id')::uuid
            OR auth.jwt() ->> 'role' = 'super_admin'
        );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'viagem_passeios' AND policyname = 'Users can manage organization viagem_passeios'
    ) THEN
        CREATE POLICY "Users can manage organization viagem_passeios" ON viagem_passeios
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

-- Nota: A tabela passageiro_passeios não existe no banco de dados atual
-- As referências foram removidas pois a tabela não foi criada

-- Atualizar registros existentes nas tabelas relacionadas
UPDATE viagem_passeios 
SET organization_id = (
    SELECT organization_id FROM viagens 
    WHERE viagens.id = viagem_passeios.viagem_id
    LIMIT 1
)
WHERE organization_id IS NULL;

-- Tornar organization_id obrigatório nas tabelas relacionadas
ALTER TABLE viagem_passeios ALTER COLUMN organization_id SET NOT NULL;

-- Comentários para documentação
COMMENT ON COLUMN passeios.organization_id IS 'ID da organização que possui este passeio';
COMMENT ON COLUMN viagem_passeios.organization_id IS 'ID da organização que possui este passeio de viagem';