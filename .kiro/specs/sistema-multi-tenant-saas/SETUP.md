# Setup do Sistema Multi-Tenant

## 🚀 Passos para Implementação

### 1. **Executar SQL no Supabase**

1. Acesse o painel do Supabase
2. Vá em **SQL Editor**
3. Execute o arquivo `database-schema.sql` completo
4. Verifique se todas as tabelas foram criadas

### 2. **Configurar Super Admin**

Após executar o SQL, você precisa se adicionar como super admin:

```sql
-- Substitua '01e58a5e-d3f7-462c-8621-3ea65fc267c0' pelo seu ID real do Supabase Auth
INSERT INTO super_admin_users (
  user_id, 
  can_access_all_tenants, 
  can_manage_subscriptions, 
  can_block_organizations, 
  can_view_analytics
) VALUES (
  '01e58a5e-d3f7-462c-8621-3ea65fc267c0', 
  true, 
  true, 
  true, 
  true
);
```

**Como encontrar seu User ID:**
1. Faça login no sistema
2. Abra o console do navegador (F12)
3. Execute: `console.log(supabase.auth.getUser())`
4. Copie o `id` do usuário

### 3. **Verificar Estrutura Criada**

Execute estas queries para verificar se tudo foi criado corretamente:

```sql
-- Verificar tabelas
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
  'organization_subscriptions',
  'organization_settings', 
  'user_invitations',
  'user_permissions',
  'super_admin_users'
);

-- Verificar policies RLS
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN (
  'organization_subscriptions',
  'organization_settings',
  'user_invitations', 
  'user_permissions',
  'super_admin_users'
);

-- Verificar functions
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN (
  'create_trial_subscription',
  'is_organization_active',
  'create_default_permissions'
);
```

### 4. **Testar o Sistema**

1. **Reinicie o servidor de desenvolvimento:**
   ```bash
   npm run dev
   ```

2. **Faça login no sistema**

3. **Verifique se o banner de status aparece** (deve mostrar TRIAL)

4. **Teste as permissões** - tente acessar diferentes páginas

### 5. **Próximos Passos**

Após confirmar que a Task 1 está funcionando:

1. ✅ **Task 1**: Estrutura Base ← **VOCÊ ESTÁ AQUI**
2. 🔄 **Task 2**: Autenticação Multi-Tenant
3. ⏳ **Task 3**: Super Admin Dashboard
4. ⏳ **Task 4**: Sistema de Permissões

## 🔧 Troubleshooting

### Erro: "relation does not exist"
- Verifique se executou todo o SQL
- Confirme que está no schema correto (`public`)

### Erro: "permission denied for table"
- Verifique se as policies RLS foram criadas
- Confirme que seu usuário tem as permissões necessárias

### Banner não aparece
- Verifique se o TenantProvider está envolvendo o App
- Confirme que existe um registro em `organization_subscriptions`

### Permissões não funcionam
- Verifique se existe registro em `user_permissions`
- Confirme que o trigger `create_default_permissions` foi criado

## 📋 Checklist de Verificação

- [ ] Todas as tabelas foram criadas
- [ ] Policies RLS estão ativas
- [ ] Functions foram criadas
- [ ] Triggers estão funcionando
- [ ] Super admin foi configurado
- [ ] Sistema inicia sem erros
- [ ] Banner de status aparece
- [ ] Permissões estão funcionando

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs do console do navegador
2. Verifique os logs do Supabase
3. Confirme que todas as dependências estão instaladas
4. Execute `npm install` se necessário

---

**Próximo passo**: Após confirmar que tudo está funcionando, podemos prosseguir para a **Task 2: Autenticação Multi-Tenant**!