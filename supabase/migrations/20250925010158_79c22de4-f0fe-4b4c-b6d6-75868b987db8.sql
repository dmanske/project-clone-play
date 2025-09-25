-- Corrigir relações e colunas faltantes

-- 1. Adicionar foreign key entre viagem_passageiros e historico_pagamentos_categorizado
DO $$
BEGIN
  -- Verificar se a coluna viagem_passageiro_id existe em historico_pagamentos_categorizado
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'historico_pagamentos_categorizado' 
    AND column_name = 'viagem_passageiro_id'
  ) THEN
    ALTER TABLE historico_pagamentos_categorizado 
    ADD COLUMN viagem_passageiro_id uuid;
    
    -- Adicionar foreign key constraint
    ALTER TABLE historico_pagamentos_categorizado
    ADD CONSTRAINT fk_historico_pagamentos_viagem_passageiro
    FOREIGN KEY (viagem_passageiro_id) REFERENCES viagem_passageiros(id) ON DELETE CASCADE;
  END IF;
END $$;

-- 2. Adicionar colunas faltantes em viagens
DO $$
BEGIN
  -- Adicionar coluna passeios_pagos se não existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'viagens' 
    AND column_name = 'passeios_pagos'
  ) THEN
    ALTER TABLE viagens 
    ADD COLUMN passeios_pagos jsonb DEFAULT '[]'::jsonb;
  END IF;
END $$;

-- 3. Adicionar colunas necessárias em viagem_passageiros
DO $$
BEGIN
  -- Adicionar coluna passeios_pagos se não existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'viagem_passageiros' 
    AND column_name = 'passeios_pagos'
  ) THEN
    ALTER TABLE viagem_passageiros 
    ADD COLUMN passeios_pagos boolean DEFAULT false;
  END IF;
  
  -- Adicionar coluna viagem_paga se não existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'viagem_passageiros' 
    AND column_name = 'viagem_paga'
  ) THEN
    ALTER TABLE viagem_passageiros 
    ADD COLUMN viagem_paga boolean DEFAULT false;
  END IF;
END $$;

-- 4. Adicionar colunas de data em historico_pagamentos_categorizado
DO $$
BEGIN
  -- Adicionar coluna data_pagamento se não existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'historico_pagamentos_categorizado' 
    AND column_name = 'data_pagamento'
  ) THEN
    ALTER TABLE historico_pagamentos_categorizado 
    ADD COLUMN data_pagamento timestamp with time zone;
  END IF;
  
  -- Adicionar coluna forma_pagamento se não existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'historico_pagamentos_categorizado' 
    AND column_name = 'forma_pagamento'
  ) THEN
    ALTER TABLE historico_pagamentos_categorizado 
    ADD COLUMN forma_pagamento varchar(100);
  END IF;
  
  -- Adicionar coluna observacoes se não existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'historico_pagamentos_categorizado' 
    AND column_name = 'observacoes'
  ) THEN
    ALTER TABLE historico_pagamentos_categorizado 
    ADD COLUMN observacoes text;
  END IF;
  
  -- Adicionar coluna created_at se não existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'historico_pagamentos_categorizado' 
    AND column_name = 'created_at'
  ) THEN
    ALTER TABLE historico_pagamentos_categorizado 
    ADD COLUMN created_at timestamp with time zone DEFAULT now();
  END IF;
END $$;

-- 5. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_historico_pagamentos_viagem_passageiro_id 
ON historico_pagamentos_categorizado(viagem_passageiro_id);

CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_viagem_paga 
ON viagem_passageiros(viagem_paga);

CREATE INDEX IF NOT EXISTS idx_viagem_passageiros_passeios_pagos 
ON viagem_passageiros(passeios_pagos);

-- 6. Atualizar valores padrão para organização
DO $$
DECLARE
  default_org_id uuid;
BEGIN
  -- Buscar uma organização padrão
  SELECT id INTO default_org_id FROM organizations WHERE slug IS NOT NULL LIMIT 1;
  
  IF default_org_id IS NOT NULL THEN
    -- Atualizar registros sem organization_id em historico_pagamentos_categorizado
    UPDATE historico_pagamentos_categorizado 
    SET organization_id = default_org_id 
    WHERE organization_id IS NULL;
  END IF;
END $$;