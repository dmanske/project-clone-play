-- Script para verificar a estrutura da tabela profiles

-- 1. Verificar se a tabela profiles existe
SELECT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'profiles'
) AS profiles_exists;

-- 2. Verificar colunas da tabela profiles
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'profiles'
ORDER BY ordinal_position;

-- 3. Verificar se organization_id existe
SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'profiles' 
    AND column_name = 'organization_id'
) AS organization_id_exists;

-- 4. Verificar se a tabela organizations existe
SELECT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'organizations'
) AS organizations_exists;

-- 5. Se profiles existe mas organization_id não, mostrar dados atuais
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'organization_id') THEN
            RAISE NOTICE 'Tabela profiles existe mas não tem coluna organization_id';
            RAISE NOTICE 'Colunas atuais: %', (
                SELECT string_agg(column_name, ', ' ORDER BY ordinal_position)
                FROM information_schema.columns 
                WHERE table_schema = 'public' AND table_name = 'profiles'
            );
        END IF;
    END IF;
END $$;