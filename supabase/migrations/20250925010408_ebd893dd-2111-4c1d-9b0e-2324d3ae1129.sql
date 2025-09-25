-- Corrigir problemas da tabela viagens

-- 1. Tornar a coluna destino nullable ou definir um valor padrão
DO $$
BEGIN
  -- Alterar destino para aceitar null ou definir valor padrão
  ALTER TABLE viagens ALTER COLUMN destino DROP NOT NULL;
  
  -- Atualizar registros existentes que possam ter destino null
  UPDATE viagens SET destino = local_jogo WHERE destino IS NULL;
END $$;

-- 2. Verificar se todas as colunas necessárias existem
DO $$
BEGIN
  -- Verificar se data_ida existe (parece ser obrigatória mas pode não estar sendo usada)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'viagens' 
    AND column_name = 'data_ida'
    AND is_nullable = 'NO'
  ) THEN
    ALTER TABLE viagens ALTER COLUMN data_ida DROP NOT NULL;
  END IF;
  
  -- Verificar se data_volta existe
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'viagens' 
    AND column_name = 'data_volta' 
    AND is_nullable = 'NO'
  ) THEN
    ALTER TABLE viagens ALTER COLUMN data_volta DROP NOT NULL;
  END IF;
  
  -- Verificar se preco_individual existe  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'viagens' 
    AND column_name = 'preco_individual'
    AND is_nullable = 'NO'
  ) THEN
    ALTER TABLE viagens ALTER COLUMN preco_individual DROP NOT NULL;
  END IF;
  
  -- Verificar se vagas_disponiveis existe
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'viagens' 
    AND column_name = 'vagas_disponiveis'
    AND is_nullable = 'NO'
  ) THEN
    ALTER TABLE viagens ALTER COLUMN vagas_disponiveis DROP NOT NULL;
  END IF;
END $$;