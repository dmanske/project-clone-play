-- SQL para listar a estrutura da tabela adversarios original
-- Baseado na estrutura fornecida: id (uuid), nome (text), logo_url (text)

-- 1. Listar todos os adversários com seus dados
SELECT 
    id,
    nome,
    logo_url
FROM adversarios
ORDER BY nome;

-- 2. Contar total de adversários
SELECT COUNT(*) as total_adversarios FROM adversarios;

-- 3. Listar adversários que têm logo
SELECT 
    id,
    nome,
    logo_url
FROM adversarios
WHERE logo_url IS NOT NULL 
    AND logo_url != ''
ORDER BY nome;

-- 4. Contar adversários com e sem logo
SELECT 
    COUNT(*) as total_adversarios,
    COUNT(CASE WHEN logo_url IS NOT NULL AND logo_url != '' THEN 1 END) as com_logo,
    COUNT(CASE WHEN logo_url IS NULL OR logo_url = '' THEN 1 END) as sem_logo
FROM adversarios;

-- 5. Verificar estrutura da tabela
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'adversarios'
ORDER BY ordinal_position;

-- 6. Listar adversários únicos (para verificar duplicatas)
SELECT 
    nome,
    COUNT(*) as quantidade
FROM adversarios
GROUP BY nome
HAVING COUNT(*) > 1
ORDER BY quantidade DESC, nome;