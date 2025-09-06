| tipo                          | trigger_name         | event_manipulation | action_timing | action_statement                   |
| ----------------------------- | -------------------- | ------------------ | ------------- | ---------------------------------- |
| TRIGGERS NA TABELA AUTH.USERS | on_auth_user_created | INSERT             | AFTER         | EXECUTE FUNCTION handle_new_user() |

| tipo                            | routine_name                    | routine_type | routine_definition                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ------------------------------- | ------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| FUNÇÕES RELACIONADAS A USUÁRIOS | create_default_permissions      | FUNCTION     | 
BEGIN
    INSERT INTO user_permissions (user_id, organization_id, permissions)
    VALUES (NEW.id, NEW.organization_id, 
        CASE NEW.role
            WHEN 'admin' THEN '{
                "viagens": {"read": true, "write": true, "delete": true},
                "clientes": {"read": true, "write": true, "delete": true},
                "onibus": {"read": true, "write": true, "delete": true},
                "financeiro": {"read": true, "write": true, "delete": true},
                "relatorios": {"read": true, "write": true, "delete": false},
                "configuracoes": {"read": true, "write": true, "delete": false},
                "usuarios": {"read": true, "write": true, "delete": true}
            }'::jsonb
            WHEN 'owner' THEN '{
                "viagens": {"read": true, "write": true, "delete": true},
                "clientes": {"read": true, "write": true, "delete": true},
                "onibus": {"read": true, "write": true, "delete": true},
                "financeiro": {"read": true, "write": true, "delete": true},
                "relatorios": {"read": true, "write": true, "delete": true},
                "configuracoes": {"read": true, "write": true, "delete": true},
                "usuarios": {"read": true, "write": true, "delete": true}
            }'::jsonb
            ELSE '{
                "viagens": {"read": true, "write": false, "delete": false},
                "clientes": {"read": true, "write": false, "delete": false},
                "onibus": {"read": true, "write": false, "delete": false},
                "financeiro": {"read": false, "write": false, "delete": false},
                "relatorios": {"read": true, "write": false, "delete": false},
                "configuracoes": {"read": false, "write": false, "delete": false},
                "usuarios": {"read": false, "write": false, "delete": false}
            }'::jsonb
        END
    );
    
    RETURN NEW;
END;
 |
| FUNÇÕES RELACIONADAS A USUÁRIOS | create_default_user_permissions | FUNCTION     | 
BEGIN
  -- Only create permissions if the user has an organization_id
  IF NEW.organization_id IS NOT NULL THEN
    INSERT INTO user_permissions (user_id, organization_id)
    VALUES (NEW.id, NEW.organization_id)
    ON CONFLICT (user_id, organization_id) DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| FUNÇÕES RELACIONADAS A USUÁRIOS | create_trial_subscription       | FUNCTION     | 
BEGIN
    INSERT INTO organization_subscriptions (organization_id, status, trial_start_date, trial_end_date)
    VALUES (NEW.id, 'TRIAL', NOW(), NOW() + INTERVAL '7 days');
    
    INSERT INTO organization_settings (organization_id)
    VALUES (NEW.id);
    
    RETURN NEW;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| FUNÇÕES RELACIONADAS A USUÁRIOS | delete_user_permissions         | FUNCTION     | 
BEGIN
  DELETE FROM user_permissions 
  WHERE user_id = p_user_id AND organization_id = p_organization_id;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| FUNÇÕES RELACIONADAS A USUÁRIOS | get_user_organization_id        | FUNCTION     | 
  SELECT organization_id FROM profiles WHERE id = auth.uid()
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| FUNÇÕES RELACIONADAS A USUÁRIOS | get_user_permissions            | FUNCTION     | 
BEGIN
  RETURN QUERY
  SELECT 
    up.id,
    up.user_id,
    up.organization_id,
    up.permissions,
    up.created_at,
    up.updated_at
  FROM user_permissions up
  WHERE up.user_id = ANY(user_ids);
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| FUNÇÕES RELACIONADAS A USUÁRIOS | get_user_permissions_by_id      | FUNCTION     | 
DECLARE
  user_permissions JSONB;
BEGIN
  SELECT permissions INTO user_permissions
  FROM user_permissions
  WHERE user_id = p_user_id AND organization_id = p_organization_id;
  
  -- Se não encontrar permissões, retornar permissões padrão
  IF user_permissions IS NULL THEN
    RETURN '{
      "viagens": {"read": true, "write": false, "delete": false},
      "clientes": {"read": true, "write": false, "delete": false},
      "onibus": {"read": true, "write": false, "delete": false},
      "financeiro": {"read": false, "write": false, "delete": false},
      "relatorios": {"read": true, "write": false, "delete": false},
      "configuracoes": {"read": false, "write": false, "delete": false},
      "usuarios": {"read": false, "write": false, "delete": false}
    }'::JSONB;
  END IF;
  
  RETURN user_permissions;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| FUNÇÕES RELACIONADAS A USUÁRIOS | handle_new_user                 | FUNCTION     | 
DECLARE
    default_org_id UUID;
BEGIN
    -- Buscar organização padrão
    SELECT id INTO default_org_id FROM organizations WHERE slug = 'gofans-dev' LIMIT 1;
    
    -- Criar profile para o novo usuário
    INSERT INTO profiles (id, organization_id, email, full_name, role)
    VALUES (
        NEW.id,
        default_org_id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        'user'
    );
    
    RETURN NEW;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| FUNÇÕES RELACIONADAS A USUÁRIOS | is_organization_active          | FUNCTION     | 
DECLARE
    subscription_status VARCHAR(20);
    trial_end TIMESTAMPTZ;
BEGIN
    SELECT status, trial_end_date 
    INTO subscription_status, trial_end
    FROM organization_subscriptions 
    WHERE organization_id = org_id;
    
    IF subscription_status IS NULL THEN
        RETURN FALSE;
    END IF;
    
    CASE subscription_status
        WHEN 'ACTIVE' THEN RETURN TRUE;
        WHEN 'TRIAL' THEN RETURN (trial_end > NOW());
        ELSE RETURN FALSE;
    END CASE;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| FUNÇÕES RELACIONADAS A USUÁRIOS | log_organization_status_change  | FUNCTION     | 
BEGIN
  -- Só registra se o status mudou
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    PERFORM log_system_activity(
      NEW.organization_id,
      auth.uid(),
      'STATUS_CHANGE',
      'ORGANIZATION',
      NEW.organization_id,
      format('Status alterado de %s para %s', OLD.status, NEW.status),
      jsonb_build_object(
        'old_status', OLD.status,
        'new_status', NEW.status,
        'changed_at', NOW()
      )
    );
  END IF;
  
  RETURN NEW;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| FUNÇÕES RELACIONADAS A USUÁRIOS | upsert_user_permissions         | FUNCTION     | 
BEGIN
  INSERT INTO user_permissions (user_id, organization_id, permissions)
  VALUES (p_user_id, p_organization_id, p_permissions)
  ON CONFLICT (user_id, organization_id)
  DO UPDATE SET 
    permissions = EXCLUDED.permissions,
    updated_at = NOW();
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | tipo                     | policyname                           | cmd | qual                                                                                  | with_check |
| ------------------------ | ------------------------------------ | --- | ------------------------------------------------------------------------------------- | ---------- |
| POLÍTICAS RLS - PROFILES | Service role can manage all profiles | ALL | (auth.role() = 'service_role'::text)                                                  | null       |
| POLÍTICAS RLS - PROFILES | Super admins can manage all profiles | ALL | (EXISTS ( SELECT 1
   FROM super_admin_users sau
  WHERE (sau.user_id = auth.uid()))) | null       |
| POLÍTICAS RLS - PROFILES | Users can manage own profile         | ALL | (auth.uid() = id)                                                                     | null       |

| tipo                     | total_usuarios_sem_org |
| ------------------------ | ---------------------- |
| USUÁRIOS SEM ORGANIZAÇÃO | 0                      |

| tipo                    | id                                   | name            | slug            | created_at                 | total_usuarios |
| ----------------------- | ------------------------------------ | --------------- | --------------- | -------------------------- | -------------- |
| ORGANIZAÇÕES EXISTENTES | 9f3c25e8-7bef-49f3-8528-1f3dbadaea15 | GoFans Dev      | gofans-dev      | 2025-09-02 20:59:45.915892 | 2              |
| ORGANIZAÇÕES EXISTENTES | 05e472b2-1a76-4972-9af5-034fdaf37afe | NetoTours Teste | netotours-teste | 2025-09-02 21:20:49.675838 | 0              |
| ORGANIZAÇÕES EXISTENTES | fa4281dc-0215-404b-87bd-f907687d8641 | Neto Viagens    | neto-viagens    | 2025-09-04 04:47:35.036099 | 0              |

| tipo           | datid | datname  | pid    | leader_pid | usesysid | usename  | application_name                | client_addr                           | client_hostname | client_port | backend_start                 | xact_start                   | query_start                  | state_change                  | wait_event_type | wait_event | state  | backend_xid | backend_xmin | query_id             | query                                                                                                                                                                                                                                                                                                                                              | backend_type   |
| -------------- | ----- | -------- | ------ | ---------- | -------- | -------- | ------------------------------- | ------------------------------------- | --------------- | ----------- | ----------------------------- | ---------------------------- | ---------------------------- | ----------------------------- | --------------- | ---------- | ------ | ----------- | ------------ | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| JOBS AGENDADOS | 5     | postgres | 198583 | null       | 16384    | postgres | supabase/dashboard-query-editor | 2600:1f18:2a66:6e00:e000:1c0:878d:e3a | null            | 52000       | 2025-09-06 14:58:09.459942+00 | 2025-09-06 14:58:10.14513+00 | 2025-09-06 14:58:10.14513+00 | 2025-09-06 14:58:10.145133+00 | null            | null       | active | null        | 1861         | -7377368828894170151 | -- Verificar se há jobs ou processos agendados
SELECT 
    'JOBS AGENDADOS' as tipo,
    *
FROM pg_stat_activity 
WHERE query ILIKE '%UPDATE%profiles%organization_id%'
   OR query ILIKE '%INSERT%organization%'
ORDER BY query_start DESC;

-- source: dashboard
-- user: eaa76ae9-dcdd-4d57-9623-bd7fbd8453a4
-- date: 2025-09-06T14:58:09.295Z | client backend |

| tipo                         | total_updates_recentes |
| ---------------------------- | ---------------------- |
| ATIVIDADE RECENTE - PROFILES | 2                      |

| tipo                   | routine_name    | routine_definition                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| ---------------------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FUNÇÃO HANDLE_NEW_USER | handle_new_user | 
DECLARE
    default_org_id UUID;
BEGIN
    -- Buscar organização padrão
    SELECT id INTO default_org_id FROM organizations WHERE slug = 'gofans-dev' LIMIT 1;
    
    -- Criar profile para o novo usuário
    INSERT INTO profiles (id, organization_id, email, full_name, role)
    VALUES (
        NEW.id,
        default_org_id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        'user'
    );
    
    RETURN NEW;
END;
 |

 