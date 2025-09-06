-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.adversarios (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  logo_url text NOT NULL,
  CONSTRAINT adversarios_pkey PRIMARY KEY (id)
);
CREATE TABLE public.categorias_financeiras (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome character varying NOT NULL UNIQUE,
  tipo character varying NOT NULL CHECK (tipo::text = ANY (ARRAY['receita'::character varying, 'despesa'::character varying]::text[])),
  cor character varying,
  icone character varying,
  ativa boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categorias_financeiras_pkey PRIMARY KEY (id)
);
CREATE TABLE public.categorias_produtos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  descricao text,
  icone text,
  cor text,
  ativo boolean DEFAULT true,
  ordem_exibicao integer,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categorias_produtos_pkey PRIMARY KEY (id)
);
CREATE TABLE public.cliente_creditos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cliente_id uuid NOT NULL,
  valor_credito numeric NOT NULL CHECK (valor_credito > 0::numeric),
  data_pagamento date NOT NULL,
  forma_pagamento character varying,
  observacoes text,
  status character varying DEFAULT 'disponivel'::character varying CHECK (status::text = ANY (ARRAY['disponivel'::character varying, 'utilizado'::character varying, 'parcial'::character varying, 'reembolsado'::character varying]::text[])),
  saldo_disponivel numeric NOT NULL CHECK (saldo_disponivel >= 0::numeric),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cliente_creditos_pkey PRIMARY KEY (id),
  CONSTRAINT cliente_creditos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id)
);
CREATE TABLE public.clientes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  endereco text NOT NULL,
  numero text NOT NULL,
  complemento text,
  bairro text NOT NULL,
  telefone text NOT NULL,
  cep text NOT NULL,
  cidade text NOT NULL,
  estado text NOT NULL,
  cpf text NOT NULL UNIQUE,
  data_nascimento date NOT NULL,
  email text NOT NULL,
  como_conheceu text NOT NULL,
  indicacao_nome text,
  observacoes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  foto text,
  fonte_cadastro text,
  passeio_cristo text NOT NULL DEFAULT 'sim'::text,
  CONSTRAINT clientes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contas_pagar (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  descricao text NOT NULL,
  valor numeric NOT NULL CHECK (valor > 0::numeric),
  data_vencimento date NOT NULL,
  data_pagamento date,
  fornecedor character varying NOT NULL,
  categoria character varying NOT NULL,
  status character varying DEFAULT 'pendente'::character varying CHECK (status::text = ANY (ARRAY['pendente'::character varying, 'pago'::character varying, 'vencido'::character varying, 'cancelado'::character varying]::text[])),
  recorrente boolean DEFAULT false,
  frequencia_recorrencia character varying CHECK (frequencia_recorrencia::text = ANY (ARRAY['mensal'::character varying, 'trimestral'::character varying, 'semestral'::character varying, 'anual'::character varying]::text[])),
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contas_pagar_pkey PRIMARY KEY (id)
);
CREATE TABLE public.credito_historico (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  credito_id uuid NOT NULL,
  tipo_movimentacao character varying NOT NULL CHECK (tipo_movimentacao::text = ANY (ARRAY['criacao'::character varying, 'utilizacao'::character varying, 'reembolso'::character varying, 'ajuste'::character varying]::text[])),
  valor_anterior numeric,
  valor_movimentado numeric NOT NULL,
  valor_posterior numeric,
  descricao text,
  viagem_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT credito_historico_pkey PRIMARY KEY (id),
  CONSTRAINT credito_historico_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id),
  CONSTRAINT credito_historico_credito_id_fkey FOREIGN KEY (credito_id) REFERENCES public.cliente_creditos(id)
);
CREATE TABLE public.credito_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  credito_id uuid,
  operacao character varying NOT NULL,
  valor numeric,
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT credito_logs_pkey PRIMARY KEY (id),
  CONSTRAINT credito_logs_credito_id_fkey FOREIGN KEY (credito_id) REFERENCES public.cliente_creditos(id)
);
CREATE TABLE public.credito_viagem_vinculacoes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  credito_id uuid NOT NULL,
  viagem_id uuid NOT NULL,
  valor_utilizado numeric NOT NULL CHECK (valor_utilizado > 0::numeric),
  data_vinculacao timestamp with time zone DEFAULT now(),
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  passageiro_id uuid,
  CONSTRAINT credito_viagem_vinculacoes_pkey PRIMARY KEY (id),
  CONSTRAINT credito_viagem_vinculacoes_credito_id_fkey FOREIGN KEY (credito_id) REFERENCES public.cliente_creditos(id),
  CONSTRAINT credito_viagem_vinculacoes_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id),
  CONSTRAINT credito_viagem_vinculacoes_passageiro_id_fkey FOREIGN KEY (passageiro_id) REFERENCES public.clientes(id)
);
CREATE TABLE public.despesas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  descricao text NOT NULL,
  valor numeric NOT NULL CHECK (valor > 0::numeric),
  categoria character varying NOT NULL,
  data_vencimento date NOT NULL,
  data_pagamento date,
  viagem_id uuid,
  fornecedor character varying,
  status character varying DEFAULT 'pendente'::character varying CHECK (status::text = ANY (ARRAY['pendente'::character varying, 'pago'::character varying, 'vencido'::character varying, 'cancelado'::character varying]::text[])),
  metodo_pagamento character varying,
  observacoes text,
  comprovante_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT despesas_pkey PRIMARY KEY (id),
  CONSTRAINT despesas_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id)
);
CREATE TABLE public.empresa_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome character varying NOT NULL,
  nome_fantasia character varying,
  cnpj character varying,
  email character varying,
  telefone character varying,
  whatsapp character varying,
  endereco text,
  cidade character varying,
  estado character varying,
  cep character varying,
  logo_url character varying,
  logo_bucket_path character varying,
  site character varying,
  instagram character varying,
  facebook character varying,
  descricao text,
  ativo boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT empresa_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.game_buses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  game_id uuid NOT NULL,
  name text NOT NULL,
  capacity integer,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT game_buses_pkey PRIMARY KEY (id),
  CONSTRAINT game_buses_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id)
);
CREATE TABLE public.games (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  date timestamp with time zone NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT games_pkey PRIMARY KEY (id)
);
CREATE TABLE public.historico_pagamentos_categorizado (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_passageiro_id uuid NOT NULL,
  categoria text NOT NULL CHECK (categoria = ANY (ARRAY['viagem'::text, 'passeios'::text, 'ambos'::text])),
  valor_pago numeric NOT NULL,
  data_pagamento timestamp with time zone DEFAULT now(),
  forma_pagamento text,
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT historico_pagamentos_categorizado_pkey PRIMARY KEY (id),
  CONSTRAINT historico_pagamentos_categorizado_viagem_passageiro_id_fkey FOREIGN KEY (viagem_passageiro_id) REFERENCES public.viagem_passageiros(id)
);
CREATE TABLE public.historico_pagamentos_ingressos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ingresso_id uuid NOT NULL,
  valor_pago numeric NOT NULL,
  data_pagamento date NOT NULL,
  forma_pagamento character varying NOT NULL DEFAULT 'dinheiro'::character varying,
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT historico_pagamentos_ingressos_pkey PRIMARY KEY (id),
  CONSTRAINT historico_pagamentos_ingressos_ingresso_id_fkey FOREIGN KEY (ingresso_id) REFERENCES public.ingressos(id)
);
CREATE TABLE public.ingressos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cliente_id uuid NOT NULL,
  viagem_id uuid,
  jogo_data date NOT NULL,
  adversario character varying NOT NULL,
  local_jogo character varying NOT NULL CHECK (local_jogo::text = ANY (ARRAY['casa'::character varying, 'fora'::character varying]::text[])),
  setor_estadio character varying NOT NULL,
  preco_custo numeric NOT NULL DEFAULT 0,
  preco_venda numeric NOT NULL DEFAULT 0,
  desconto numeric NOT NULL DEFAULT 0,
  valor_final numeric DEFAULT (preco_venda - desconto),
  lucro numeric DEFAULT ((preco_venda - desconto) - preco_custo),
  margem_percentual numeric DEFAULT 
CASE
    WHEN ((preco_venda - desconto) > (0)::numeric) THEN ((((preco_venda - desconto) - preco_custo) / (preco_venda - desconto)) * (100)::numeric)
    ELSE (0)::numeric
END,
  situacao_financeira character varying NOT NULL DEFAULT 'pendente'::character varying CHECK (situacao_financeira::text = ANY (ARRAY['pendente'::character varying, 'pago'::character varying, 'cancelado'::character varying]::text[])),
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  logo_adversario text,
  viagem_ingressos_id uuid,
  CONSTRAINT ingressos_pkey PRIMARY KEY (id),
  CONSTRAINT ingressos_viagem_ingressos_id_fkey FOREIGN KEY (viagem_ingressos_id) REFERENCES public.viagens_ingressos(id),
  CONSTRAINT ingressos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id),
  CONSTRAINT ingressos_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id)
);
CREATE TABLE public.lista_presenca (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_id uuid NOT NULL,
  passageiro_id uuid NOT NULL,
  presente boolean DEFAULT false,
  horario_chegada timestamp with time zone,
  observacoes text,
  registrado_por uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT lista_presenca_pkey PRIMARY KEY (id),
  CONSTRAINT lista_presenca_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES auth.users(id),
  CONSTRAINT lista_presenca_passageiro_id_fkey FOREIGN KEY (passageiro_id) REFERENCES public.viagem_passageiros(id),
  CONSTRAINT lista_presenca_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id)
);
CREATE TABLE public.onibus (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tipo_onibus text NOT NULL,
  empresa text NOT NULL,
  numero_identificacao text,
  capacidade integer NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  image_path text,
  description text,
  CONSTRAINT onibus_pkey PRIMARY KEY (id)
);
CREATE TABLE public.onibus_images (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tipo_onibus text NOT NULL,
  empresa text NOT NULL,
  image_url text,
  created_at timestamp with time zone DEFAULT now(),
  onibus_id uuid,
  CONSTRAINT onibus_images_pkey PRIMARY KEY (id),
  CONSTRAINT onibus_images_onibus_id_fkey FOREIGN KEY (onibus_id) REFERENCES public.onibus(id)
);
CREATE TABLE public.parcela_alertas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  parcela_id uuid NOT NULL,
  tipo_alerta character varying NOT NULL CHECK (tipo_alerta::text = ANY (ARRAY['5_dias_antes'::character varying, 'vencimento'::character varying, 'atraso_1dia'::character varying, 'atraso_7dias'::character varying]::text[])),
  canal character varying DEFAULT 'whatsapp'::character varying CHECK (canal::text = ANY (ARRAY['whatsapp'::character varying, 'email'::character varying, 'sms'::character varying]::text[])),
  template_usado character varying,
  mensagem_enviada text,
  data_envio timestamp without time zone DEFAULT now(),
  status_envio character varying DEFAULT 'enviado'::character varying CHECK (status_envio::text = ANY (ARRAY['enviado'::character varying, 'lido'::character varying, 'respondido'::character varying, 'erro'::character varying]::text[])),
  resposta_recebida text,
  tentativas integer DEFAULT 1,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT parcela_alertas_pkey PRIMARY KEY (id),
  CONSTRAINT fk_alertas_parcela FOREIGN KEY (parcela_id) REFERENCES public.viagem_passageiros_parcelas(id)
);
CREATE TABLE public.parcela_historico (
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
  CONSTRAINT parcela_historico_pkey PRIMARY KEY (id),
  CONSTRAINT fk_historico_parcela FOREIGN KEY (parcela_id) REFERENCES public.viagem_passageiros_parcelas(id)
);
CREATE TABLE public.passageiro_passeios (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  viagem_passageiro_id uuid NOT NULL,
  passeio_nome text NOT NULL,
  status text NOT NULL DEFAULT 'Confirmado'::text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  passeio_id uuid,
  valor_cobrado numeric DEFAULT 0,
  CONSTRAINT passageiro_passeios_pkey PRIMARY KEY (id),
  CONSTRAINT passageiro_passeios_viagem_passageiro_id_fkey FOREIGN KEY (viagem_passageiro_id) REFERENCES public.viagem_passageiros(id),
  CONSTRAINT passageiro_passeios_passeio_id_fkey FOREIGN KEY (passeio_id) REFERENCES public.passeios(id)
);
CREATE TABLE public.passeios (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nome text NOT NULL UNIQUE,
  valor numeric NOT NULL,
  categoria text NOT NULL,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  custo_operacional numeric NOT NULL DEFAULT 0,
  CONSTRAINT passeios_pkey PRIMARY KEY (id)
);
CREATE TABLE public.passengers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  boarding_city text NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::passenger_status,
  game_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  bus_id uuid,
  CONSTRAINT passengers_pkey PRIMARY KEY (id),
  CONSTRAINT passengers_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id),
  CONSTRAINT passengers_bus_id_fkey FOREIGN KEY (bus_id) REFERENCES public.game_buses(id)
);
CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  session_id text UNIQUE,
  customer_email text,
  amount numeric NOT NULL,
  currency text NOT NULL DEFAULT 'brl'::text,
  status text NOT NULL DEFAULT 'pending'::text,
  payment_method text,
  viagem_id uuid,
  cliente_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT payments_pkey PRIMARY KEY (id),
  CONSTRAINT payments_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id),
  CONSTRAINT payments_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id)
);
CREATE TABLE public.pedido_itens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  pedido_id uuid,
  tipo_item text NOT NULL,
  item_id uuid NOT NULL,
  nome text NOT NULL,
  preco numeric NOT NULL,
  quantidade integer DEFAULT 1,
  descricao text,
  detalhes jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pedido_itens_pkey PRIMARY KEY (id),
  CONSTRAINT pedido_itens_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos(id)
);
CREATE TABLE public.pedidos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  numero_pedido text UNIQUE,
  cliente_email text NOT NULL,
  cliente_nome text,
  cliente_telefone text,
  total numeric NOT NULL,
  status text DEFAULT 'pendente'::text,
  forma_pagamento text,
  dados_entrega jsonb DEFAULT '{}'::jsonb,
  observacoes text,
  stripe_session_id text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pedidos_pkey PRIMARY KEY (id)
);
CREATE TABLE public.produtos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  descricao text,
  preco numeric NOT NULL,
  categoria_id uuid,
  categoria_nome text,
  imagem_url text,
  imagens jsonb DEFAULT '[]'::jsonb,
  estoque integer DEFAULT 0,
  destaque boolean DEFAULT false,
  ativo boolean DEFAULT true,
  tags ARRAY,
  especificacoes jsonb DEFAULT '{}'::jsonb,
  peso numeric,
  dimensoes text,
  marca text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT produtos_pkey PRIMARY KEY (id),
  CONSTRAINT produtos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias_produtos(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  nome text,
  telefone text,
  perfil text DEFAULT 'cliente'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.projecoes_fluxo_caixa (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mes_ano date NOT NULL UNIQUE,
  receitas_projetadas numeric DEFAULT 0,
  despesas_projetadas numeric DEFAULT 0,
  saldo_projetado numeric DEFAULT 0,
  receitas_realizadas numeric DEFAULT 0,
  despesas_realizadas numeric DEFAULT 0,
  saldo_realizado numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT projecoes_fluxo_caixa_pkey PRIMARY KEY (id)
);
CREATE TABLE public.receitas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  descricao text NOT NULL,
  valor numeric NOT NULL CHECK (valor > 0::numeric),
  categoria character varying NOT NULL,
  data_recebimento date NOT NULL,
  viagem_id uuid,
  cliente_id uuid,
  metodo_pagamento character varying,
  status character varying DEFAULT 'recebido'::character varying CHECK (status::text = ANY (ARRAY['recebido'::character varying, 'pendente'::character varying, 'cancelado'::character varying]::text[])),
  observacoes text,
  comprovante_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT receitas_pkey PRIMARY KEY (id),
  CONSTRAINT receitas_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id),
  CONSTRAINT receitas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id)
);
CREATE TABLE public.setores_maracana (
  id integer NOT NULL DEFAULT nextval('setores_maracana_id_seq'::regclass),
  nome character varying NOT NULL UNIQUE,
  descricao text,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT setores_maracana_pkey PRIMARY KEY (id)
);
CREATE TABLE public.sistema_parametros (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  chave text NOT NULL UNIQUE,
  valor text,
  descricao text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT sistema_parametros_pkey PRIMARY KEY (id)
);
CREATE TABLE public.stripe_customers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cliente_id uuid,
  stripe_customer_id text NOT NULL UNIQUE,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT stripe_customers_pkey PRIMARY KEY (id),
  CONSTRAINT stripe_customers_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id)
);
CREATE TABLE public.system_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  value text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT system_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  email character varying NOT NULL,
  nome character varying NOT NULL,
  role character varying NOT NULL DEFAULT 'presenca'::character varying CHECK (role::text = ANY (ARRAY['admin'::character varying, 'manager'::character varying, 'presenca'::character varying, 'user'::character varying]::text[])),
  ativo boolean DEFAULT true,
  viagem_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id),
  CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.viagem_cobranca_historico (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_passageiro_id uuid NOT NULL,
  tipo_contato character varying NOT NULL CHECK (tipo_contato::text = ANY (ARRAY['whatsapp'::character varying, 'email'::character varying, 'telefone'::character varying, 'presencial'::character varying]::text[])),
  template_usado character varying,
  mensagem_enviada text,
  status_envio character varying DEFAULT 'enviado'::character varying CHECK (status_envio::text = ANY (ARRAY['enviado'::character varying, 'lido'::character varying, 'respondido'::character varying, 'erro'::character varying]::text[])),
  data_tentativa timestamp without time zone DEFAULT now(),
  proximo_followup date,
  observacoes text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT viagem_cobranca_historico_pkey PRIMARY KEY (id),
  CONSTRAINT viagem_cobranca_historico_viagem_passageiro_id_fkey FOREIGN KEY (viagem_passageiro_id) REFERENCES public.viagem_passageiros(id)
);
CREATE TABLE public.viagem_despesas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_id uuid NOT NULL,
  fornecedor character varying NOT NULL,
  categoria character varying NOT NULL CHECK (categoria::text = ANY (ARRAY['transporte'::character varying, 'hospedagem'::character varying, 'alimentacao'::character varying, 'ingressos'::character varying, 'pessoal'::character varying, 'administrativo'::character varying]::text[])),
  subcategoria character varying,
  valor numeric NOT NULL CHECK (valor > 0::numeric),
  forma_pagamento character varying DEFAULT 'Pix'::character varying,
  status character varying DEFAULT 'pago'::character varying CHECK (status::text = ANY (ARRAY['pago'::character varying, 'pendente'::character varying, 'cancelado'::character varying]::text[])),
  data_despesa date NOT NULL,
  comprovante_url character varying,
  observacoes text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT viagem_despesas_pkey PRIMARY KEY (id),
  CONSTRAINT viagem_despesas_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id)
);
CREATE TABLE public.viagem_onibus (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_id uuid NOT NULL,
  tipo_onibus text NOT NULL,
  empresa text NOT NULL,
  capacidade_onibus integer NOT NULL,
  numero_identificacao text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  lugares_extras integer NOT NULL DEFAULT 0,
  CONSTRAINT viagem_onibus_pkey PRIMARY KEY (id),
  CONSTRAINT fk_viagem_onibus_viagem_id FOREIGN KEY (viagem_id) REFERENCES public.viagens(id),
  CONSTRAINT viagem_onibus_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id)
);
CREATE TABLE public.viagem_orcamento (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_id uuid NOT NULL,
  categoria character varying NOT NULL,
  subcategoria character varying,
  descricao character varying NOT NULL,
  valor_orcado numeric NOT NULL CHECK (valor_orcado >= 0::numeric),
  valor_realizado numeric DEFAULT 0 CHECK (valor_realizado >= 0::numeric),
  observacoes text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT viagem_orcamento_pkey PRIMARY KEY (id),
  CONSTRAINT viagem_orcamento_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id)
);
CREATE TABLE public.viagem_parcelamento_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_id uuid NOT NULL UNIQUE,
  desconto_avista_percent numeric DEFAULT 0 CHECK (desconto_avista_percent >= 0::numeric AND desconto_avista_percent <= 100::numeric),
  prazo_limite_dias integer DEFAULT 5 CHECK (prazo_limite_dias > 0),
  intervalo_minimo_dias integer DEFAULT 15 CHECK (intervalo_minimo_dias > 0),
  max_parcelas integer DEFAULT 6 CHECK (max_parcelas > 0),
  ativo boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT viagem_parcelamento_config_pkey PRIMARY KEY (id),
  CONSTRAINT fk_parcelamento_config_viagem FOREIGN KEY (viagem_id) REFERENCES public.viagens(id)
);
CREATE TABLE public.viagem_passageiros (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_id uuid NOT NULL,
  cliente_id uuid NOT NULL,
  setor_maracana text NOT NULL DEFAULT 'Sem ingresso'::text,
  status_pagamento text NOT NULL DEFAULT 'Pendente'::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  valor numeric,
  forma_pagamento text NOT NULL DEFAULT 'Pix'::text,
  desconto numeric DEFAULT 0,
  onibus_id uuid,
  cidade_embarque text NOT NULL DEFAULT 'Blumenau'::text,
  observacoes text,
  status_presenca character varying DEFAULT 'pendente'::character varying CHECK (status_presenca::text = ANY (ARRAY['presente'::character varying, 'ausente'::character varying, 'pendente'::character varying]::text[])),
  is_responsavel_onibus boolean DEFAULT false,
  viagem_paga boolean DEFAULT false,
  passeios_pagos boolean DEFAULT false,
  gratuito boolean DEFAULT false,
  pago_por_credito boolean DEFAULT false,
  credito_origem_id uuid,
  valor_credito_utilizado numeric DEFAULT 0,
  presente boolean,
  CONSTRAINT viagem_passageiros_pkey PRIMARY KEY (id),
  CONSTRAINT viagem_passageiros_credito_origem_id_fkey FOREIGN KEY (credito_origem_id) REFERENCES public.cliente_creditos(id),
  CONSTRAINT fk_viagem_passageiros_onibus_id FOREIGN KEY (onibus_id) REFERENCES public.viagem_onibus(id),
  CONSTRAINT fk_viagem_passageiros_cliente_id FOREIGN KEY (cliente_id) REFERENCES public.clientes(id),
  CONSTRAINT viagem_passageiros_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id),
  CONSTRAINT fk_viagem_passageiros_viagem_id FOREIGN KEY (viagem_id) REFERENCES public.viagens(id),
  CONSTRAINT viagem_passageiros_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id),
  CONSTRAINT viagem_passageiros_onibus_id_fkey FOREIGN KEY (onibus_id) REFERENCES public.viagem_onibus(id)
);
CREATE TABLE public.viagem_passageiros_parcelas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_passageiro_id uuid,
  valor_parcela numeric NOT NULL,
  data_pagamento timestamp with time zone DEFAULT now(),
  forma_pagamento text NOT NULL DEFAULT 'Pix'::text,
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  data_vencimento date NOT NULL DEFAULT CURRENT_DATE,
  numero_parcela integer NOT NULL DEFAULT 1,
  total_parcelas integer NOT NULL DEFAULT 1,
  status character varying DEFAULT 'pendente'::character varying CHECK (status::text = ANY (ARRAY['pendente'::character varying, 'pago'::character varying, 'vencido'::character varying, 'cancelado'::character varying]::text[])),
  tipo_parcelamento character varying DEFAULT 'avista'::character varying CHECK (tipo_parcelamento::text = ANY (ARRAY['avista'::character varying, 'parcelado'::character varying, 'personalizado'::character varying]::text[])),
  desconto_aplicado numeric DEFAULT 0,
  valor_original numeric,
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT viagem_passageiros_parcelas_pkey PRIMARY KEY (id),
  CONSTRAINT viagem_passageiros_parcelas_viagem_passageiro_id_fkey FOREIGN KEY (viagem_passageiro_id) REFERENCES public.viagem_passageiros(id)
);
CREATE TABLE public.viagem_passeios (
  viagem_id uuid,
  passeio_id uuid,
  valor_cobrado numeric,
  CONSTRAINT viagem_passeios_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id),
  CONSTRAINT viagem_passeios_passeio_id_fkey FOREIGN KEY (passeio_id) REFERENCES public.passeios(id)
);
CREATE TABLE public.viagem_receitas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  viagem_id uuid NOT NULL,
  descricao character varying NOT NULL,
  categoria character varying NOT NULL CHECK (categoria::text = ANY (ARRAY['passageiro'::character varying, 'patrocinio'::character varying, 'vendas'::character varying, 'extras'::character varying]::text[])),
  valor numeric NOT NULL CHECK (valor > 0::numeric),
  forma_pagamento character varying DEFAULT 'Pix'::character varying,
  status character varying DEFAULT 'recebido'::character varying CHECK (status::text = ANY (ARRAY['recebido'::character varying, 'pendente'::character varying, 'cancelado'::character varying]::text[])),
  data_recebimento date NOT NULL,
  observacoes text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT viagem_receitas_pkey PRIMARY KEY (id),
  CONSTRAINT viagem_receitas_viagem_id_fkey FOREIGN KEY (viagem_id) REFERENCES public.viagens(id)
);
CREATE TABLE public.viagens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  adversario text NOT NULL,
  data_jogo timestamp with time zone NOT NULL,
  tipo_onibus text NOT NULL,
  empresa text NOT NULL,
  capacidade_onibus integer NOT NULL,
  status_viagem text NOT NULL DEFAULT 'Aberta'::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  logo_adversario text,
  logo_flamengo text DEFAULT 'https://upload.wikimedia.org/wikipedia/commons/4/43/Flamengo_logo.png'::text,
  valor_padrao numeric,
  setor_padrao text,
  cidade_embarque text NOT NULL DEFAULT 'Blumenau'::text,
  passeios_pagos ARRAY DEFAULT '{}'::text[],
  outro_passeio text,
  data_saida timestamp with time zone,
  local_jogo text NOT NULL DEFAULT 'Rio de Janeiro'::text,
  tipo_pagamento character varying DEFAULT 'livre'::character varying CHECK (tipo_pagamento::text = ANY (ARRAY['livre'::character varying, 'parcelado_flexivel'::character varying, 'parcelado_obrigatorio'::character varying]::text[])),
  exige_pagamento_completo boolean DEFAULT false,
  dias_antecedencia integer DEFAULT 5,
  permite_viagem_com_pendencia boolean DEFAULT true,
  nome_estadio text,
  ativa_loja boolean DEFAULT false,
  destaque_loja boolean DEFAULT false,
  descricao_loja text,
  categoria_loja text DEFAULT 'nacional'::text,
  imagens_loja jsonb DEFAULT '[]'::jsonb,
  tags_loja ARRAY DEFAULT '{}'::text[],
  ordem_exibicao integer DEFAULT 0,
  CONSTRAINT viagens_pkey PRIMARY KEY (id)
);
CREATE TABLE public.viagens_ingressos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  adversario character varying NOT NULL,
  data_jogo timestamp with time zone NOT NULL,
  local_jogo character varying NOT NULL CHECK (local_jogo::text = ANY (ARRAY['casa'::character varying, 'fora'::character varying]::text[])),
  logo_adversario text,
  logo_flamengo text DEFAULT 'https://logodetimes.com/times/flamengo/logo-flamengo-256.png'::text,
  valor_padrao numeric DEFAULT 100.00,
  status character varying DEFAULT 'Ativa'::character varying CHECK (status::text = ANY (ARRAY['Ativa'::character varying, 'Finalizada'::character varying, 'Cancelada'::character varying]::text[])),
  editavel boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT viagens_ingressos_pkey PRIMARY KEY (id)
);