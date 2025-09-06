# Análise do Problema: Adversários Não Aparecem no Formulário

## 🔍 Diagnóstico Baseado nos Resultados SQL

### ✅ O que está funcionando:
1. **Tabela adversarios existe** - 20 registros encontrados
2. **Estrutura da tabela está correta** - todas as colunas necessárias presentes
3. **Dados estão inseridos** - 20 times brasileiros com logos
4. **Políticas RLS estão configuradas** - 4 políticas ativas (SELECT, INSERT, UPDATE, DELETE)
5. **RLS está habilitado** - `rowsecurity = true`

### ❌ O problema identificado:
**USUÁRIO NÃO AUTENTICADO NO CONTEXTO DO SUPABASE**

```sql
-- Resultado da consulta 9 e 10:
| user_id | email |
| ------- | ----- |
| null    | null  |
```

Isso significa que `auth.uid()` está retornando `null`, fazendo com que as políticas RLS bloqueiem o acesso aos adversários.

## 🔧 Soluções Propostas

### Solução 1: Verificar Autenticação no Frontend

1. **Verificar se o usuário está logado:**
   ```typescript
   // No componente CadastrarViagem.tsx
   useEffect(() => {
     const checkAuth = async () => {
       const { data: { session } } = await supabase.auth.getSession();
       console.log('Sessão atual:', session);
       
       if (!session) {
         toast.error('Usuário não autenticado');
         navigate('/login');
       }
     };
     
     checkAuth();
   }, []);
   ```

2. **Adicionar filtro por organization_id na query:**
   ```typescript
   // Modificar a função fetchAdversarios em CadastrarViagem.tsx
   const fetchAdversarios = async () => {
     try {
       setIsLoadingAdversarios(true);
       
       // Verificar se há usuário autenticado
       const { data: { user } } = await supabase.auth.getUser();
       if (!user) {
         toast.error('Usuário não autenticado');
         return;
       }
       
       // Buscar organization_id do usuário
       const { data: profile } = await supabase
         .from('profiles')
         .select('organization_id')
         .eq('id', user.id)
         .single();
       
       if (!profile?.organization_id) {
         toast.error('Usuário sem organização associada');
         return;
       }
       
       const { data, error } = await supabase
         .from("adversarios")
         .select("*")
         .eq('organization_id', profile.organization_id)
         .neq("nome", "Flamengo")
         .order("nome");
         
       if (error) {
         console.error("Erro ao carregar adversários:", error);
         toast.error(`Erro ao carregar adversários: ${error.message}`);
       } else if (data && data.length > 0) {
         setAdversarios(data);
       } else {
         toast.error("Nenhum adversário encontrado para sua organização.");
       }
     } catch (err) {
       console.error("Exceção ao carregar adversários:", err);
       toast.error(`Exceção: ${err.message}`);
     } finally {
       setIsLoadingAdversarios(false);
     }
   };
   ```

### Solução 2: Corrigir Perfil do Usuário

**Execute este SQL no Supabase para associar o usuário a uma organização:**

```sql
-- 1. Verificar usuário atual
SELECT 
    id,
    email,
    organization_id
FROM profiles 
WHERE email = 'SEU_EMAIL_AQUI'; -- Substitua pelo seu email

-- 2. Se organization_id for null, associar à organização existente
UPDATE profiles 
SET organization_id = 'fa4281dc-0215-404b-87bd-f907687d8641'
WHERE email = 'SEU_EMAIL_AQUI' -- Substitua pelo seu email
  AND organization_id IS NULL;

-- 3. Verificar se foi atualizado
SELECT 
    id,
    email,
    organization_id
FROM profiles 
WHERE email = 'SEU_EMAIL_AQUI'; -- Substitua pelo seu email
```

### Solução 3: Política RLS Temporária (Para Teste)

**Se as soluções acima não funcionarem, crie uma política temporária mais permissiva:**

```sql
-- Política temporária para debug (REMOVER DEPOIS)
CREATE POLICY "temp_adversarios_select_all" ON adversarios
FOR SELECT USING (true);

-- Testar se os adversários aparecem
-- Depois remover a política:
-- DROP POLICY "temp_adversarios_select_all" ON adversarios;
```

## 🎯 Próximos Passos

1. **Implementar Solução 1** - Verificar autenticação no frontend
2. **Executar Solução 2** - Corrigir perfil do usuário no banco
3. **Testar** - Verificar se os adversários aparecem no formulário
4. **Se necessário** - Usar Solução 3 temporariamente para confirmar que o problema é de autenticação

## 📋 Checklist de Verificação

- [ ] Usuário está autenticado (`session` não é null)
- [ ] Usuário tem `organization_id` no perfil
- [ ] Query inclui filtro por `organization_id`
- [ ] Políticas RLS permitem acesso com `organization_id` correto
- [ ] Adversários aparecem no formulário

## 🔍 Debug Adicional

Para debug mais detalhado, adicione estes logs no componente:

```typescript
const fetchAdversarios = async () => {
  try {
    // Debug: Verificar sessão
    const { data: { session } } = await supabase.auth.getSession();
    console.log('🔐 Sessão:', session?.user?.id, session?.user?.email);
    
    // Debug: Verificar perfil
    if (session?.user) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', session.user.id)
        .single();
      console.log('👤 Perfil:', profile);
    }
    
    // Resto da função...
  } catch (error) {
    console.error('❌ Erro no debug:', error);
  }
};
```

Este debug ajudará a identificar exatamente onde está o problema na cadeia de autenticação.