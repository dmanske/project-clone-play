-- Adicionar valores padrão para campos obrigatórios na tabela viagens

DO $$
DECLARE
  default_org_id uuid;
BEGIN
  -- Buscar uma organização padrão
  SELECT id INTO default_org_id FROM organizations WHERE slug IS NOT NULL LIMIT 1;
  
  IF default_org_id IS NOT NULL THEN
    -- Atualizar registros existentes com valores padrão para campos obrigatórios
    UPDATE viagens 
    SET 
      destino = COALESCE(destino, local_jogo, 'Rio de Janeiro'),
      data_ida = COALESCE(data_ida, data_jogo, CURRENT_DATE),
      data_volta = COALESCE(data_volta, data_jogo, CURRENT_DATE),
      preco_individual = COALESCE(preco_individual, valor_padrao, 0),
      vagas_disponiveis = COALESCE(vagas_disponiveis, capacidade_onibus, 0),
      organization_id = COALESCE(organization_id, default_org_id)
    WHERE organization_id IS NULL OR destino IS NULL OR data_ida IS NULL OR data_volta IS NULL OR preco_individual IS NULL OR vagas_disponiveis IS NULL;
    
    -- Definir valores padrão para novos registros
    ALTER TABLE viagens ALTER COLUMN destino SET DEFAULT 'Rio de Janeiro';
    ALTER TABLE viagens ALTER COLUMN data_ida SET DEFAULT CURRENT_DATE;
    ALTER TABLE viagens ALTER COLUMN data_volta SET DEFAULT CURRENT_DATE;
    ALTER TABLE viagens ALTER COLUMN preco_individual SET DEFAULT 0;
    ALTER TABLE viagens ALTER COLUMN vagas_disponiveis SET DEFAULT 0;
  END IF;
END $$;