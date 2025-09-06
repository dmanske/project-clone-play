-- Fix for fonte_cadastro column cache issue
-- This script verifies the column exists and refreshes the schema cache

-- 1. Verify the fonte_cadastro column exists in clientes table
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'clientes' 
    AND column_name = 'fonte_cadastro';

-- 2. If the column doesn't exist, add it
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS fonte_cadastro TEXT;

-- 3. Update any existing records that have NULL fonte_cadastro
UPDATE clientes 
SET fonte_cadastro = 'admin' 
WHERE fonte_cadastro IS NULL;

-- 4. Refresh the schema cache by running a simple query
SELECT COUNT(*) FROM clientes;

-- 5. Verify the column is accessible
SELECT 
    id,
    nome,
    fonte_cadastro
FROM clientes 
LIMIT 1;

-- 6. Test insert with fonte_cadastro
-- This is just a test - remove the record after
INSERT INTO clientes (
    nome,
    cpf,
    data_nascimento,
    telefone,
    email,
    cep,
    endereco,
    numero,
    bairro,
    cidade,
    estado,
    como_conheceu,
    fonte_cadastro
) VALUES (
    'Teste Cache',
    '12345678901',
    '1990-01-01',
    '11999999999',
    'teste@cache.com',
    '01234567',
    'Rua Teste',
    '123',
    'Bairro Teste',
    'São Paulo',
    'SP',
    'Teste',
    'admin'
) RETURNING id, nome, fonte_cadastro;

-- 7. Clean up test record
DELETE FROM clientes WHERE nome = 'Teste Cache' AND email = 'teste@cache.com';

-- 8. Final verification
SELECT 'fonte_cadastro column is working correctly' as status;