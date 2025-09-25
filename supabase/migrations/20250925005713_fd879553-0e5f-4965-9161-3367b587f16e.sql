-- Corrigir problemas críticos do database - versão final

-- 1. Inserir configuração do logo do Flamengo diretamente
DO $$
DECLARE
  default_org_id uuid;
  config_exists boolean;
BEGIN
  -- Buscar uma organização padrão
  SELECT id INTO default_org_id FROM organizations WHERE slug IS NOT NULL LIMIT 1;
  
  IF default_org_id IS NOT NULL THEN
    -- Verificar se configuração já existe
    SELECT EXISTS(SELECT 1 FROM system_config WHERE config_key = 'flamengo_logo') INTO config_exists;
    
    -- Inserir apenas se não existe
    IF NOT config_exists THEN
      INSERT INTO public.system_config (config_key, config_value, description, organization_id) 
      VALUES ('flamengo_logo', 'https://logodetimes.com/times/flamengo/logo-flamengo-256.png', 'Logo padrão do Flamengo', default_org_id);
    END IF;
  END IF;
END $$;

-- 2. Adicionar colunas necessárias na tabela historico_pagamentos_categorizado
DO $$ 
DECLARE
  default_org_id uuid;
BEGIN
  -- Buscar uma organização padrão
  SELECT id INTO default_org_id FROM organizations WHERE slug IS NOT NULL LIMIT 1;
  
  IF default_org_id IS NOT NULL THEN
    -- Adicionar organization_id se não existe
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'historico_pagamentos_categorizado' 
      AND column_name = 'organization_id'
    ) THEN
      ALTER TABLE historico_pagamentos_categorizado 
      ADD COLUMN organization_id uuid;
      
      UPDATE historico_pagamentos_categorizado 
      SET organization_id = default_org_id 
      WHERE organization_id IS NULL;
      
      ALTER TABLE historico_pagamentos_categorizado 
      ALTER COLUMN organization_id SET NOT NULL;
    END IF;

    -- Adicionar coluna valor_pago se não existe
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'historico_pagamentos_categorizado' 
      AND column_name = 'valor_pago'
    ) THEN
      ALTER TABLE historico_pagamentos_categorizado 
      ADD COLUMN valor_pago numeric NOT NULL DEFAULT 0;
    END IF;

    -- Atualizar registros sem organization_id em tabelas críticas
    UPDATE empresa_config SET organization_id = default_org_id WHERE organization_id IS NULL;
    UPDATE clientes SET organization_id = default_org_id WHERE organization_id IS NULL;
  END IF;
END $$;

-- 3. Configurar RLS adequadamente
ALTER TABLE public.system_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.historico_pagamentos_categorizado ENABLE ROW LEVEL SECURITY;

-- 4. Remover políticas existentes e criar novas
DROP POLICY IF EXISTS "Users can manage system_config from their organization" ON public.system_config;
CREATE POLICY "Users can manage system_config from their organization" ON public.system_config
    FOR ALL USING (organization_id IN (SELECT profiles.organization_id FROM profiles WHERE profiles.id = auth.uid()));

DROP POLICY IF EXISTS "Users can manage historico_pagamentos_categorizado from their organization" ON public.historico_pagamentos_categorizado;
CREATE POLICY "Users can manage historico_pagamentos_categorizado from their organization" ON public.historico_pagamentos_categorizado
    FOR ALL USING (organization_id IN (SELECT profiles.organization_id FROM profiles WHERE profiles.id = auth.uid()));

-- 5. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_system_config_organization_id ON public.system_config(organization_id);
CREATE INDEX IF NOT EXISTS idx_system_config_key ON public.system_config(config_key);
CREATE INDEX IF NOT EXISTS idx_historico_pagamentos_categorizado_organization_id ON public.historico_pagamentos_categorizado(organization_id);