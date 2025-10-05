-- Remover possíveis constraints de check no status_viagem e permitir valores flexíveis

-- 1. Verificar se há constraints de check na tabela viagens
DO $$
DECLARE
    constraint_rec RECORD;
BEGIN
    -- Buscar e remover constraints de check que possam estar bloqueando valores de status_viagem
    FOR constraint_rec IN 
        SELECT constraint_name 
        FROM information_schema.table_constraints 
        WHERE table_name = 'viagens' 
        AND constraint_type = 'CHECK'
        AND constraint_name LIKE '%status%'
    LOOP
        EXECUTE 'ALTER TABLE viagens DROP CONSTRAINT IF EXISTS ' || constraint_rec.constraint_name;
        RAISE NOTICE 'Removida constraint: %', constraint_rec.constraint_name;
    END LOOP;
    
    -- Garantir que o valor padrão está correto
    ALTER TABLE viagens ALTER COLUMN status_viagem SET DEFAULT 'planejada';
    
    -- Atualizar registros existentes que possam ter valores incompatíveis
    UPDATE viagens SET status_viagem = 'planejada' WHERE status_viagem IS NULL;
END $$;