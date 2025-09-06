-- Criar tabela de logs de atividades do sistema
CREATE TABLE IF NOT EXISTS system_activity_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  action_type VARCHAR(50) NOT NULL, -- 'LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE', 'STATUS_CHANGE', etc.
  resource_type VARCHAR(50), -- 'VIAGEM', 'CLIENTE', 'ONIBUS', 'ORGANIZATION', etc.
  resource_id UUID, -- ID do recurso afetado
  description TEXT NOT NULL,
  metadata JSONB, -- Dados adicionais sobre a ação
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_system_activity_logs_organization_id ON system_activity_logs(organization_id);
CREATE INDEX IF NOT EXISTS idx_system_activity_logs_user_id ON system_activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_system_activity_logs_action_type ON system_activity_logs(action_type);
CREATE INDEX IF NOT EXISTS idx_system_activity_logs_created_at ON system_activity_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_system_activity_logs_resource ON system_activity_logs(resource_type, resource_id);

-- RLS Policy para super admins verem todos os logs
ALTER TABLE system_activity_logs ENABLE ROW LEVEL SECURITY;

-- Super admins podem ver todos os logs
CREATE POLICY "Super admins can view all activity logs" ON system_activity_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM super_admin_users 
      WHERE user_id = auth.uid()
    )
  );

-- Usuários podem ver apenas logs da sua organização
CREATE POLICY "Users can view organization activity logs" ON system_activity_logs
  FOR SELECT USING (
    organization_id IN (
      SELECT organization_id FROM profiles 
      WHERE user_id = auth.uid()
    )
  );

-- Apenas o sistema pode inserir logs (via service role)
CREATE POLICY "System can insert activity logs" ON system_activity_logs
  FOR INSERT WITH CHECK (true);

-- Função para registrar atividade
CREATE OR REPLACE FUNCTION log_system_activity(
  p_organization_id UUID,
  p_user_id UUID,
  p_action_type VARCHAR(50),
  p_resource_type VARCHAR(50) DEFAULT NULL,
  p_resource_id UUID DEFAULT NULL,
  p_description TEXT DEFAULT '',
  p_metadata JSONB DEFAULT NULL,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  log_id UUID;
BEGIN
  INSERT INTO system_activity_logs (
    organization_id,
    user_id,
    action_type,
    resource_type,
    resource_id,
    description,
    metadata,
    ip_address,
    user_agent
  ) VALUES (
    p_organization_id,
    p_user_id,
    p_action_type,
    p_resource_type,
    p_resource_id,
    p_description,
    p_metadata,
    p_ip_address,
    p_user_agent
  ) RETURNING id INTO log_id;
  
  RETURN log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para logar mudanças de status de organizações
CREATE OR REPLACE FUNCTION log_organization_status_change()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger na tabela de subscriptions
DROP TRIGGER IF EXISTS trigger_log_organization_status_change ON organization_subscriptions;
CREATE TRIGGER trigger_log_organization_status_change
  AFTER UPDATE ON organization_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION log_organization_status_change();

-- Inserir alguns logs de exemplo para teste
INSERT INTO system_activity_logs (
  organization_id,
  user_id,
  action_type,
  resource_type,
  description,
  metadata
) VALUES 
(
  (SELECT id FROM organizations LIMIT 1),
  (SELECT id FROM auth.users LIMIT 1),
  'SYSTEM_START',
  'SYSTEM',
  'Sistema de logs de atividades iniciado',
  jsonb_build_object('version', '1.0', 'feature', 'activity_logs')
);