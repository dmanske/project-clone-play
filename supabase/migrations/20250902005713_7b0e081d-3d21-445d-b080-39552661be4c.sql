-- =====================================================
-- CONFIGURAR RLS E POLÍTICAS DE SEGURANÇA
-- =====================================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE onibus ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagens ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_passageiros ENABLE ROW LEVEL SECURITY;
ALTER TABLE creditos_clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingressos ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresa_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_despesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_cobranca_historico ENABLE ROW LEVEL SECURITY;
ALTER TABLE viagem_orcamento ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS PARA ACESSO PÚBLICO (SEM AUTENTICAÇÃO)
-- =====================================================
-- Para permitir acesso público aos dados essenciais

-- Política para visualizar viagens (público pode ver)
CREATE POLICY "Viagens são públicas para visualização"
ON viagens FOR SELECT
TO public
USING (true);

-- Política para visualizar empresa_config (público pode ver)
CREATE POLICY "Configurações da empresa são públicas"
ON empresa_config FOR SELECT
TO public
USING (ativo = true);

-- Política para inserir clientes (público pode cadastrar)
CREATE POLICY "Público pode cadastrar clientes"
ON clientes FOR INSERT
TO public
WITH CHECK (true);

-- Política para visualizar ônibus (público pode ver)
CREATE POLICY "Ônibus são públicos para visualização"
ON onibus FOR SELECT
TO public
USING (true);

-- =====================================================
-- POLÍTICAS PARA USUÁRIOS AUTENTICADOS (ADMIN)
-- =====================================================
-- Para acesso completo quando implementar autenticação

-- Políticas para clientes (admin pode tudo)
CREATE POLICY "Admin pode gerenciar clientes"
ON clientes FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para ônibus (admin pode tudo)
CREATE POLICY "Admin pode gerenciar ônibus"
ON onibus FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para viagens (admin pode tudo)
CREATE POLICY "Admin pode gerenciar viagens"
ON viagens FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para passageiros (admin pode tudo)
CREATE POLICY "Admin pode gerenciar passageiros"
ON viagem_passageiros FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para créditos (admin pode tudo)
CREATE POLICY "Admin pode gerenciar créditos"
ON creditos_clientes FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para ingressos (admin pode tudo)
CREATE POLICY "Admin pode gerenciar ingressos"
ON ingressos FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para empresa_config (admin pode tudo)
CREATE POLICY "Admin pode gerenciar empresa"
ON empresa_config FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para receitas (admin pode tudo)
CREATE POLICY "Admin pode gerenciar receitas"
ON viagem_receitas FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para despesas (admin pode tudo)
CREATE POLICY "Admin pode gerenciar despesas"
ON viagem_despesas FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para histórico cobrança (admin pode tudo)
CREATE POLICY "Admin pode gerenciar cobrança"
ON viagem_cobranca_historico FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas para orçamento (admin pode tudo)
CREATE POLICY "Admin pode gerenciar orçamento"
ON viagem_orcamento FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- =====================================================
-- CORRIGIR FUNÇÃO update_updated_at_column
-- =====================================================

-- Recriar função com search_path correto
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;