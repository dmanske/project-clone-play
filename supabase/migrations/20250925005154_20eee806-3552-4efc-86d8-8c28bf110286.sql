-- Criar apenas as 4 tabelas que não existem (ignorando setores_maracana)

-- 1. Tabela fornecedores
CREATE TABLE IF NOT EXISTS public.fornecedores (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome character varying NOT NULL,
  tipo_fornecedor character varying NOT NULL CHECK (tipo_fornecedor::text = ANY (ARRAY['ingressos'::character varying::text, 'transporte'::character varying::text, 'hospedagem'::character varying::text, 'alimentacao'::character varying::text, 'eventos'::character varying::text])),
  email character varying,
  telefone character varying,
  whatsapp character varying,
  endereco text,
  cnpj character varying,
  contato_principal character varying,
  observacoes text,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  mensagem_padrao text,
  organization_id uuid NOT NULL,
  CONSTRAINT fornecedores_pkey PRIMARY KEY (id)
);

-- 2. Tabela message_templates
CREATE TABLE IF NOT EXISTS public.message_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome character varying NOT NULL,
  tipo_fornecedor character varying NOT NULL,
  assunto character varying,
  corpo_mensagem text NOT NULL,
  variaveis_disponiveis text[] DEFAULT '{}',
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  organization_id uuid NOT NULL,
  CONSTRAINT message_templates_pkey PRIMARY KEY (id)
);

-- 3. Tabela parcela_alertas
CREATE TABLE IF NOT EXISTS public.parcela_alertas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  parcela_id uuid NOT NULL,
  tipo_alerta character varying NOT NULL CHECK (tipo_alerta::text = ANY (ARRAY['5_dias_antes'::character varying::text, 'vencimento'::character varying::text, 'atraso_1dia'::character varying::text, 'atraso_7dias'::character varying::text])),
  canal character varying DEFAULT 'whatsapp'::character varying CHECK (canal::text = ANY (ARRAY['whatsapp'::character varying::text, 'email'::character varying::text, 'sms'::character varying::text])),
  template_usado character varying,
  mensagem_enviada text,
  data_envio timestamp without time zone DEFAULT now(),
  status_envio character varying DEFAULT 'enviado'::character varying CHECK (status_envio::text = ANY (ARRAY['enviado'::character varying::text, 'lido'::character varying::text, 'respondido'::character varying::text, 'erro'::character varying::text])),
  resposta_recebida text,
  tentativas integer DEFAULT 1,
  created_at timestamp without time zone DEFAULT now(),
  organization_id uuid NOT NULL,
  CONSTRAINT parcela_alertas_pkey PRIMARY KEY (id),
  CONSTRAINT fk_alertas_parcela FOREIGN KEY (parcela_id) REFERENCES public.viagem_passageiros_parcelas(id)
);

-- 4. Tabela parcela_historico
CREATE TABLE IF NOT EXISTS public.parcela_historico (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  parcela_id uuid NOT NULL,
  acao character varying NOT NULL,
  valor_anterior jsonb,
  valor_novo jsonb,
  usuario_id uuid,
  ip_address inet,
  user_agent text,
  observacoes text,
  created_at timestamp without time zone DEFAULT now(),
  organization_id uuid NOT NULL,
  CONSTRAINT parcela_historico_pkey PRIMARY KEY (id),
  CONSTRAINT fk_historico_parcela FOREIGN KEY (parcela_id) REFERENCES public.viagem_passageiros_parcelas(id)
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_fornecedores_organization_id ON public.fornecedores(organization_id);
CREATE INDEX IF NOT EXISTS idx_fornecedores_tipo ON public.fornecedores(tipo_fornecedor);
CREATE INDEX IF NOT EXISTS idx_message_templates_organization_id ON public.message_templates(organization_id);
CREATE INDEX IF NOT EXISTS idx_parcela_alertas_organization_id ON public.parcela_alertas(organization_id);
CREATE INDEX IF NOT EXISTS idx_parcela_historico_organization_id ON public.parcela_historico(organization_id);

-- Habilitar RLS
ALTER TABLE public.fornecedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parcela_alertas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parcela_historico ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS
CREATE POLICY "Users can manage fornecedores from their organization" ON public.fornecedores
    FOR ALL USING (organization_id IN (SELECT profiles.organization_id FROM profiles WHERE profiles.id = auth.uid()));

CREATE POLICY "Users can manage message_templates from their organization" ON public.message_templates
    FOR ALL USING (organization_id IN (SELECT profiles.organization_id FROM profiles WHERE profiles.id = auth.uid()));

CREATE POLICY "Users can manage parcela_alertas from their organization" ON public.parcela_alertas
    FOR ALL USING (organization_id IN (SELECT profiles.organization_id FROM profiles WHERE profiles.id = auth.uid()));

CREATE POLICY "Users can manage parcela_historico from their organization" ON public.parcela_historico
    FOR ALL USING (organization_id IN (SELECT profiles.organization_id FROM profiles WHERE profiles.id = auth.uid()));