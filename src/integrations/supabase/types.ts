export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.4"
  }
  public: {
    Tables: {
      adversarios: {
        Row: {
          ativo: boolean | null
          created_at: string | null
          id: string
          logo_url: string | null
          nome: string
        }
        Insert: {
          ativo?: boolean | null
          created_at?: string | null
          id?: string
          logo_url?: string | null
          nome: string
        }
        Update: {
          ativo?: boolean | null
          created_at?: string | null
          id?: string
          logo_url?: string | null
          nome?: string
        }
        Relationships: []
      }
      categorias_financeiras: {
        Row: {
          ativo: boolean | null
          created_at: string | null
          id: string
          nome: string
          organization_id: string
          tipo: string
        }
        Insert: {
          ativo?: boolean | null
          created_at?: string | null
          id?: string
          nome: string
          organization_id: string
          tipo: string
        }
        Update: {
          ativo?: boolean | null
          created_at?: string | null
          id?: string
          nome?: string
          organization_id?: string
          tipo?: string
        }
        Relationships: [
          {
            foreignKeyName: "categorias_financeiras_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      categorias_produtos: {
        Row: {
          ativo: boolean | null
          created_at: string | null
          descricao: string | null
          id: string
          nome: string
          organization_id: string
        }
        Insert: {
          ativo?: boolean | null
          created_at?: string | null
          descricao?: string | null
          id?: string
          nome: string
          organization_id: string
        }
        Update: {
          ativo?: boolean | null
          created_at?: string | null
          descricao?: string | null
          id?: string
          nome?: string
          organization_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "categorias_produtos_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      cliente_creditos: {
        Row: {
          cliente_id: string
          created_at: string | null
          id: string
          limite_credito: number | null
          organization_id: string
          saldo_atual: number | null
          updated_at: string | null
        }
        Insert: {
          cliente_id: string
          created_at?: string | null
          id?: string
          limite_credito?: number | null
          organization_id: string
          saldo_atual?: number | null
          updated_at?: string | null
        }
        Update: {
          cliente_id?: string
          created_at?: string | null
          id?: string
          limite_credito?: number | null
          organization_id?: string
          saldo_atual?: number | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "cliente_creditos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cliente_creditos_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      clientes: {
        Row: {
          bairro: string
          cep: string
          cidade: string
          como_conheceu: string
          complemento: string | null
          cpf: string
          created_at: string | null
          data_nascimento: string
          email: string
          endereco: string
          estado: string
          fonte_cadastro: string | null
          foto: string | null
          id: string
          indicacao_nome: string | null
          nome: string
          numero: string
          observacoes: string | null
          organization_id: string | null
          telefone: string
        }
        Insert: {
          bairro: string
          cep: string
          cidade: string
          como_conheceu: string
          complemento?: string | null
          cpf: string
          created_at?: string | null
          data_nascimento: string
          email: string
          endereco: string
          estado: string
          fonte_cadastro?: string | null
          foto?: string | null
          id?: string
          indicacao_nome?: string | null
          nome: string
          numero: string
          observacoes?: string | null
          organization_id?: string | null
          telefone: string
        }
        Update: {
          bairro?: string
          cep?: string
          cidade?: string
          como_conheceu?: string
          complemento?: string | null
          cpf?: string
          created_at?: string | null
          data_nascimento?: string
          email?: string
          endereco?: string
          estado?: string
          fonte_cadastro?: string | null
          foto?: string | null
          id?: string
          indicacao_nome?: string | null
          nome?: string
          numero?: string
          observacoes?: string | null
          organization_id?: string | null
          telefone?: string
        }
        Relationships: [
          {
            foreignKeyName: "clientes_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_clientes_organization"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      contas_pagar: {
        Row: {
          categoria_id: string | null
          created_at: string | null
          data_pagamento: string | null
          data_vencimento: string
          descricao: string
          id: string
          organization_id: string
          status: string | null
          valor: number
        }
        Insert: {
          categoria_id?: string | null
          created_at?: string | null
          data_pagamento?: string | null
          data_vencimento: string
          descricao: string
          id?: string
          organization_id: string
          status?: string | null
          valor: number
        }
        Update: {
          categoria_id?: string | null
          created_at?: string | null
          data_pagamento?: string | null
          data_vencimento?: string
          descricao?: string
          id?: string
          organization_id?: string
          status?: string | null
          valor?: number
        }
        Relationships: [
          {
            foreignKeyName: "contas_pagar_categoria_id_fkey"
            columns: ["categoria_id"]
            isOneToOne: false
            referencedRelation: "categorias_financeiras"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "contas_pagar_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      credito_historico: {
        Row: {
          cliente_id: string
          created_at: string | null
          descricao: string | null
          id: string
          organization_id: string
          saldo_anterior: number | null
          saldo_atual: number | null
          tipo: string
          valor: number
        }
        Insert: {
          cliente_id: string
          created_at?: string | null
          descricao?: string | null
          id?: string
          organization_id: string
          saldo_anterior?: number | null
          saldo_atual?: number | null
          tipo: string
          valor: number
        }
        Update: {
          cliente_id?: string
          created_at?: string | null
          descricao?: string | null
          id?: string
          organization_id?: string
          saldo_anterior?: number | null
          saldo_atual?: number | null
          tipo?: string
          valor?: number
        }
        Relationships: [
          {
            foreignKeyName: "credito_historico_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credito_historico_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      credito_logs: {
        Row: {
          acao: string
          cliente_id: string
          created_at: string | null
          detalhes: Json | null
          id: string
          organization_id: string
          usuario_id: string | null
        }
        Insert: {
          acao: string
          cliente_id: string
          created_at?: string | null
          detalhes?: Json | null
          id?: string
          organization_id: string
          usuario_id?: string | null
        }
        Update: {
          acao?: string
          cliente_id?: string
          created_at?: string | null
          detalhes?: Json | null
          id?: string
          organization_id?: string
          usuario_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "credito_logs_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credito_logs_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credito_logs_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      credito_viagem_vinculacoes: {
        Row: {
          ativo: boolean | null
          cliente_id: string
          data_vinculacao: string | null
          id: string
          organization_id: string
          valor_vinculado: number
          viagem_id: string
        }
        Insert: {
          ativo?: boolean | null
          cliente_id: string
          data_vinculacao?: string | null
          id?: string
          organization_id: string
          valor_vinculado: number
          viagem_id: string
        }
        Update: {
          ativo?: boolean | null
          cliente_id?: string
          data_vinculacao?: string | null
          id?: string
          organization_id?: string
          valor_vinculado?: number
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "credito_viagem_vinculacoes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credito_viagem_vinculacoes_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credito_viagem_vinculacoes_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      credito_vinculacoes: {
        Row: {
          created_at: string | null
          credito_id: string
          data_uso: string | null
          id: string
          observacoes: string | null
          organization_id: string | null
          valor_usado: number
          viagem_id: string
        }
        Insert: {
          created_at?: string | null
          credito_id: string
          data_uso?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          valor_usado: number
          viagem_id: string
        }
        Update: {
          created_at?: string | null
          credito_id?: string
          data_uso?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          valor_usado?: number
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "credito_vinculacoes_credito_id_fkey"
            columns: ["credito_id"]
            isOneToOne: false
            referencedRelation: "creditos_clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credito_vinculacoes_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credito_vinculacoes_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      creditos_clientes: {
        Row: {
          ativo: boolean | null
          cliente_id: string
          created_at: string | null
          data_expiracao: string | null
          id: string
          motivo: string
          organization_id: string | null
          saldo_disponivel: number
          updated_at: string | null
          valor_inicial: number
        }
        Insert: {
          ativo?: boolean | null
          cliente_id: string
          created_at?: string | null
          data_expiracao?: string | null
          id?: string
          motivo: string
          organization_id?: string | null
          saldo_disponivel: number
          updated_at?: string | null
          valor_inicial: number
        }
        Update: {
          ativo?: boolean | null
          cliente_id?: string
          created_at?: string | null
          data_expiracao?: string | null
          id?: string
          motivo?: string
          organization_id?: string | null
          saldo_disponivel?: number
          updated_at?: string | null
          valor_inicial?: number
        }
        Relationships: [
          {
            foreignKeyName: "creditos_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "creditos_clientes_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_creditos_organization"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      despesas: {
        Row: {
          categoria_id: string | null
          created_at: string | null
          data_despesa: string
          descricao: string
          id: string
          organization_id: string
          valor: number
          viagem_id: string | null
        }
        Insert: {
          categoria_id?: string | null
          created_at?: string | null
          data_despesa: string
          descricao: string
          id?: string
          organization_id: string
          valor: number
          viagem_id?: string | null
        }
        Update: {
          categoria_id?: string | null
          created_at?: string | null
          data_despesa?: string
          descricao?: string
          id?: string
          organization_id?: string
          valor?: number
          viagem_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "despesas_categoria_id_fkey"
            columns: ["categoria_id"]
            isOneToOne: false
            referencedRelation: "categorias_financeiras"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "despesas_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "despesas_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      empresa_config: {
        Row: {
          ativo: boolean | null
          cep: string | null
          cidade: string | null
          cnpj: string | null
          created_at: string | null
          descricao: string | null
          email: string | null
          endereco: string | null
          estado: string | null
          facebook: string | null
          id: string
          instagram: string | null
          logo_bucket_path: string | null
          logo_url: string | null
          nome: string
          nome_fantasia: string | null
          organization_id: string | null
          site: string | null
          telefone: string | null
          updated_at: string | null
          whatsapp: string | null
        }
        Insert: {
          ativo?: boolean | null
          cep?: string | null
          cidade?: string | null
          cnpj?: string | null
          created_at?: string | null
          descricao?: string | null
          email?: string | null
          endereco?: string | null
          estado?: string | null
          facebook?: string | null
          id?: string
          instagram?: string | null
          logo_bucket_path?: string | null
          logo_url?: string | null
          nome: string
          nome_fantasia?: string | null
          organization_id?: string | null
          site?: string | null
          telefone?: string | null
          updated_at?: string | null
          whatsapp?: string | null
        }
        Update: {
          ativo?: boolean | null
          cep?: string | null
          cidade?: string | null
          cnpj?: string | null
          created_at?: string | null
          descricao?: string | null
          email?: string | null
          endereco?: string | null
          estado?: string | null
          facebook?: string | null
          id?: string
          instagram?: string | null
          logo_bucket_path?: string | null
          logo_url?: string | null
          nome?: string
          nome_fantasia?: string | null
          organization_id?: string | null
          site?: string | null
          telefone?: string | null
          updated_at?: string | null
          whatsapp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "empresa_config_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      fornecedores: {
        Row: {
          ativo: boolean | null
          cnpj: string | null
          contato_principal: string | null
          created_at: string | null
          email: string | null
          endereco: string | null
          id: string
          mensagem_padrao: string | null
          nome: string
          observacoes: string | null
          organization_id: string
          telefone: string | null
          tipo_fornecedor: string
          updated_at: string | null
          whatsapp: string | null
        }
        Insert: {
          ativo?: boolean | null
          cnpj?: string | null
          contato_principal?: string | null
          created_at?: string | null
          email?: string | null
          endereco?: string | null
          id?: string
          mensagem_padrao?: string | null
          nome: string
          observacoes?: string | null
          organization_id: string
          telefone?: string | null
          tipo_fornecedor: string
          updated_at?: string | null
          whatsapp?: string | null
        }
        Update: {
          ativo?: boolean | null
          cnpj?: string | null
          contato_principal?: string | null
          created_at?: string | null
          email?: string | null
          endereco?: string | null
          id?: string
          mensagem_padrao?: string | null
          nome?: string
          observacoes?: string | null
          organization_id?: string
          telefone?: string | null
          tipo_fornecedor?: string
          updated_at?: string | null
          whatsapp?: string | null
        }
        Relationships: []
      }
      game_buses: {
        Row: {
          ativo: boolean | null
          created_at: string | null
          game_id: string
          id: string
          onibus_id: string
          organization_id: string
          preco: number
          vagas_disponiveis: number | null
        }
        Insert: {
          ativo?: boolean | null
          created_at?: string | null
          game_id: string
          id?: string
          onibus_id: string
          organization_id: string
          preco: number
          vagas_disponiveis?: number | null
        }
        Update: {
          ativo?: boolean | null
          created_at?: string | null
          game_id?: string
          id?: string
          onibus_id?: string
          organization_id?: string
          preco?: number
          vagas_disponiveis?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "game_buses_game_id_fkey"
            columns: ["game_id"]
            isOneToOne: false
            referencedRelation: "games"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "game_buses_onibus_id_fkey"
            columns: ["onibus_id"]
            isOneToOne: false
            referencedRelation: "onibus"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "game_buses_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      games: {
        Row: {
          adversario_id: string | null
          ativo: boolean | null
          created_at: string | null
          data_jogo: string
          id: string
          local_jogo: string | null
          nome: string
          organization_id: string
          resultado: string | null
        }
        Insert: {
          adversario_id?: string | null
          ativo?: boolean | null
          created_at?: string | null
          data_jogo: string
          id?: string
          local_jogo?: string | null
          nome: string
          organization_id: string
          resultado?: string | null
        }
        Update: {
          adversario_id?: string | null
          ativo?: boolean | null
          created_at?: string | null
          data_jogo?: string
          id?: string
          local_jogo?: string | null
          nome?: string
          organization_id?: string
          resultado?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "games_adversario_id_fkey"
            columns: ["adversario_id"]
            isOneToOne: false
            referencedRelation: "adversarios"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "games_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      historico_pagamentos_categorizado: {
        Row: {
          categoria: string | null
          data_categorizacao: string | null
          id: string
          organization_id: string
          pagamento_id: string | null
          subcategoria: string | null
          usuario_id: string | null
          valor: number
          valor_pago: number
        }
        Insert: {
          categoria?: string | null
          data_categorizacao?: string | null
          id?: string
          organization_id: string
          pagamento_id?: string | null
          subcategoria?: string | null
          usuario_id?: string | null
          valor: number
          valor_pago?: number
        }
        Update: {
          categoria?: string | null
          data_categorizacao?: string | null
          id?: string
          organization_id?: string
          pagamento_id?: string | null
          subcategoria?: string | null
          usuario_id?: string | null
          valor?: number
          valor_pago?: number
        }
        Relationships: [
          {
            foreignKeyName: "historico_pagamentos_categorizado_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "historico_pagamentos_categorizado_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      historico_pagamentos_ingressos: {
        Row: {
          data_pagamento: string
          id: string
          ingresso_id: string
          metodo_pagamento: string | null
          organization_id: string
          referencia: string | null
          status: string | null
          valor_pago: number
        }
        Insert: {
          data_pagamento: string
          id?: string
          ingresso_id: string
          metodo_pagamento?: string | null
          organization_id: string
          referencia?: string | null
          status?: string | null
          valor_pago: number
        }
        Update: {
          data_pagamento?: string
          id?: string
          ingresso_id?: string
          metodo_pagamento?: string | null
          organization_id?: string
          referencia?: string | null
          status?: string | null
          valor_pago?: number
        }
        Relationships: [
          {
            foreignKeyName: "historico_pagamentos_ingressos_ingresso_id_fkey"
            columns: ["ingresso_id"]
            isOneToOne: false
            referencedRelation: "ingressos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "historico_pagamentos_ingressos_ingresso_id_fkey"
            columns: ["ingresso_id"]
            isOneToOne: false
            referencedRelation: "ingressos_com_cliente"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "historico_pagamentos_ingressos_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      historico_transferencias: {
        Row: {
          data_transferencia: string | null
          id: string
          observacoes: string | null
          onibus_destino_id: string | null
          onibus_origem_id: string | null
          passageiros_movidos: Json
          tipo_operacao: string
          usuario_id: string | null
          viagem_id: string
        }
        Insert: {
          data_transferencia?: string | null
          id?: string
          observacoes?: string | null
          onibus_destino_id?: string | null
          onibus_origem_id?: string | null
          passageiros_movidos: Json
          tipo_operacao: string
          usuario_id?: string | null
          viagem_id: string
        }
        Update: {
          data_transferencia?: string | null
          id?: string
          observacoes?: string | null
          onibus_destino_id?: string | null
          onibus_origem_id?: string | null
          passageiros_movidos?: Json
          tipo_operacao?: string
          usuario_id?: string | null
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "historico_transferencias_onibus_destino_id_fkey"
            columns: ["onibus_destino_id"]
            isOneToOne: false
            referencedRelation: "onibus"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "historico_transferencias_onibus_origem_id_fkey"
            columns: ["onibus_origem_id"]
            isOneToOne: false
            referencedRelation: "onibus"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "historico_transferencias_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      ingressos: {
        Row: {
          adversario: string | null
          cadeira: string | null
          cliente_id: string
          codigo_barras: string | null
          created_at: string | null
          data_evento: string
          desconto: number | null
          detalhes_pagamento: string | null
          evento: string
          fileira: string | null
          id: string
          jogo_data: string | null
          local_jogo: string | null
          logo_adversario: string | null
          lucro: number | null
          margem_percentual: number | null
          metodo_pagamento: string | null
          observacoes: string | null
          organization_id: string | null
          preco_custo: number | null
          preco_face: number | null
          preco_venda: number | null
          setor: string
          setor_estadio: string | null
          situacao_financeira: string | null
          status: string | null
          taxa_servico: number | null
          updated_at: string | null
          valor: number
          valor_final: number | null
          viagem_id: string | null
          viagem_ingressos_id: string | null
        }
        Insert: {
          adversario?: string | null
          cadeira?: string | null
          cliente_id: string
          codigo_barras?: string | null
          created_at?: string | null
          data_evento: string
          desconto?: number | null
          detalhes_pagamento?: string | null
          evento: string
          fileira?: string | null
          id?: string
          jogo_data?: string | null
          local_jogo?: string | null
          logo_adversario?: string | null
          lucro?: number | null
          margem_percentual?: number | null
          metodo_pagamento?: string | null
          observacoes?: string | null
          organization_id?: string | null
          preco_custo?: number | null
          preco_face?: number | null
          preco_venda?: number | null
          setor: string
          setor_estadio?: string | null
          situacao_financeira?: string | null
          status?: string | null
          taxa_servico?: number | null
          updated_at?: string | null
          valor: number
          valor_final?: number | null
          viagem_id?: string | null
          viagem_ingressos_id?: string | null
        }
        Update: {
          adversario?: string | null
          cadeira?: string | null
          cliente_id?: string
          codigo_barras?: string | null
          created_at?: string | null
          data_evento?: string
          desconto?: number | null
          detalhes_pagamento?: string | null
          evento?: string
          fileira?: string | null
          id?: string
          jogo_data?: string | null
          local_jogo?: string | null
          logo_adversario?: string | null
          lucro?: number | null
          margem_percentual?: number | null
          metodo_pagamento?: string | null
          observacoes?: string | null
          organization_id?: string | null
          preco_custo?: number | null
          preco_face?: number | null
          preco_venda?: number | null
          setor?: string
          setor_estadio?: string | null
          situacao_financeira?: string | null
          status?: string | null
          taxa_servico?: number | null
          updated_at?: string | null
          valor?: number
          valor_final?: number | null
          viagem_id?: string | null
          viagem_ingressos_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_ingressos_organization"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ingressos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ingressos_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ingressos_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ingressos_viagem_ingressos_id_fkey"
            columns: ["viagem_ingressos_id"]
            isOneToOne: false
            referencedRelation: "viagens_ingressos"
            referencedColumns: ["id"]
          },
        ]
      }
      lista_presenca: {
        Row: {
          cliente_id: string
          created_at: string | null
          data_checkin: string | null
          id: string
          observacoes: string | null
          organization_id: string
          presente: boolean | null
          viagem_id: string
        }
        Insert: {
          cliente_id: string
          created_at?: string | null
          data_checkin?: string | null
          id?: string
          observacoes?: string | null
          organization_id: string
          presente?: boolean | null
          viagem_id: string
        }
        Update: {
          cliente_id?: string
          created_at?: string | null
          data_checkin?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string
          presente?: boolean | null
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "lista_presenca_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lista_presenca_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lista_presenca_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      message_templates: {
        Row: {
          assunto: string | null
          ativo: boolean | null
          corpo_mensagem: string
          created_at: string | null
          id: string
          nome: string
          organization_id: string
          tipo_fornecedor: string
          updated_at: string | null
          variaveis_disponiveis: string[] | null
        }
        Insert: {
          assunto?: string | null
          ativo?: boolean | null
          corpo_mensagem: string
          created_at?: string | null
          id?: string
          nome: string
          organization_id: string
          tipo_fornecedor: string
          updated_at?: string | null
          variaveis_disponiveis?: string[] | null
        }
        Update: {
          assunto?: string | null
          ativo?: boolean | null
          corpo_mensagem?: string
          created_at?: string | null
          id?: string
          nome?: string
          organization_id?: string
          tipo_fornecedor?: string
          updated_at?: string | null
          variaveis_disponiveis?: string[] | null
        }
        Relationships: []
      }
      onibus: {
        Row: {
          ativo: boolean | null
          capacidade: number
          created_at: string | null
          description: string | null
          empresa: string
          estatisticas: Json | null
          id: string
          image_path: string | null
          numero_identificacao: string | null
          organization_id: string | null
          tipo_onibus: string
          updated_at: string | null
          wifi_password: string | null
          wifi_ssid: string | null
        }
        Insert: {
          ativo?: boolean | null
          capacidade: number
          created_at?: string | null
          description?: string | null
          empresa: string
          estatisticas?: Json | null
          id?: string
          image_path?: string | null
          numero_identificacao?: string | null
          organization_id?: string | null
          tipo_onibus: string
          updated_at?: string | null
          wifi_password?: string | null
          wifi_ssid?: string | null
        }
        Update: {
          ativo?: boolean | null
          capacidade?: number
          created_at?: string | null
          description?: string | null
          empresa?: string
          estatisticas?: Json | null
          id?: string
          image_path?: string | null
          numero_identificacao?: string | null
          organization_id?: string | null
          tipo_onibus?: string
          updated_at?: string | null
          wifi_password?: string | null
          wifi_ssid?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_onibus_organization"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "onibus_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      onibus_audit_log: {
        Row: {
          action_type: string
          created_at: string | null
          id: string
          new_values: Json | null
          old_values: Json | null
          onibus_id: string | null
          organization_id: string | null
          user_id: string | null
        }
        Insert: {
          action_type: string
          created_at?: string | null
          id?: string
          new_values?: Json | null
          old_values?: Json | null
          onibus_id?: string | null
          organization_id?: string | null
          user_id?: string | null
        }
        Update: {
          action_type?: string
          created_at?: string | null
          id?: string
          new_values?: Json | null
          old_values?: Json | null
          onibus_id?: string | null
          organization_id?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "onibus_audit_log_onibus_id_fkey"
            columns: ["onibus_id"]
            isOneToOne: false
            referencedRelation: "onibus"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "onibus_audit_log_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "onibus_audit_log_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      onibus_images: {
        Row: {
          created_at: string | null
          file_size: number | null
          id: string
          image_path: string
          image_url: string
          is_primary: boolean | null
          mime_type: string | null
          onibus_id: string | null
          organization_id: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          file_size?: number | null
          id?: string
          image_path: string
          image_url: string
          is_primary?: boolean | null
          mime_type?: string | null
          onibus_id?: string | null
          organization_id?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          file_size?: number | null
          id?: string
          image_path?: string
          image_url?: string
          is_primary?: boolean | null
          mime_type?: string | null
          onibus_id?: string | null
          organization_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "onibus_images_onibus_id_fkey"
            columns: ["onibus_id"]
            isOneToOne: false
            referencedRelation: "onibus"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "onibus_images_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      organization_settings: {
        Row: {
          configuracoes_relatorio: Json | null
          cor_primaria: string | null
          cor_secundaria: string | null
          created_at: string | null
          email_contato: string | null
          endereco_completo: string | null
          id: string
          logo_empresa_url: string | null
          logo_time_principal_url: string | null
          logo_time_url: string | null
          moeda: string | null
          organization_id: string
          passeios_padrao: Json | null
          setores_personalizados: Json | null
          site_url: string | null
          telefone: string | null
          time_principal: string | null
          timezone: string | null
          updated_at: string | null
        }
        Insert: {
          configuracoes_relatorio?: Json | null
          cor_primaria?: string | null
          cor_secundaria?: string | null
          created_at?: string | null
          email_contato?: string | null
          endereco_completo?: string | null
          id?: string
          logo_empresa_url?: string | null
          logo_time_principal_url?: string | null
          logo_time_url?: string | null
          moeda?: string | null
          organization_id: string
          passeios_padrao?: Json | null
          setores_personalizados?: Json | null
          site_url?: string | null
          telefone?: string | null
          time_principal?: string | null
          timezone?: string | null
          updated_at?: string | null
        }
        Update: {
          configuracoes_relatorio?: Json | null
          cor_primaria?: string | null
          cor_secundaria?: string | null
          created_at?: string | null
          email_contato?: string | null
          endereco_completo?: string | null
          id?: string
          logo_empresa_url?: string | null
          logo_time_principal_url?: string | null
          logo_time_url?: string | null
          moeda?: string | null
          organization_id?: string
          passeios_padrao?: Json | null
          setores_personalizados?: Json | null
          site_url?: string | null
          telefone?: string | null
          time_principal?: string | null
          timezone?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "organization_settings_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: true
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      organization_subscriptions: {
        Row: {
          created_at: string | null
          id: string
          organization_id: string
          status: string
          stripe_customer_id: string | null
          stripe_price_id: string | null
          stripe_subscription_id: string | null
          subscription_end_date: string | null
          subscription_start_date: string | null
          trial_end_date: string | null
          trial_start_date: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          organization_id: string
          status?: string
          stripe_customer_id?: string | null
          stripe_price_id?: string | null
          stripe_subscription_id?: string | null
          subscription_end_date?: string | null
          subscription_start_date?: string | null
          trial_end_date?: string | null
          trial_start_date?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          organization_id?: string
          status?: string
          stripe_customer_id?: string | null
          stripe_price_id?: string | null
          stripe_subscription_id?: string | null
          subscription_end_date?: string | null
          subscription_start_date?: string | null
          trial_end_date?: string | null
          trial_start_date?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "organization_subscriptions_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: true
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      organizations: {
        Row: {
          active: boolean | null
          cep: string | null
          cidade: string | null
          cor_primaria: string | null
          cor_secundaria: string | null
          created_at: string | null
          descricao: string | null
          description: string | null
          domain: string | null
          email_contato: string | null
          endereco: string | null
          estado: string | null
          id: string
          logo_url: string | null
          max_users: number | null
          name: string
          plan: string | null
          settings: Json | null
          slug: string
          telefone: string | null
          time_casa_padrao: string | null
          updated_at: string | null
          website: string | null
          whatsapp: string | null
        }
        Insert: {
          active?: boolean | null
          cep?: string | null
          cidade?: string | null
          cor_primaria?: string | null
          cor_secundaria?: string | null
          created_at?: string | null
          descricao?: string | null
          description?: string | null
          domain?: string | null
          email_contato?: string | null
          endereco?: string | null
          estado?: string | null
          id?: string
          logo_url?: string | null
          max_users?: number | null
          name: string
          plan?: string | null
          settings?: Json | null
          slug: string
          telefone?: string | null
          time_casa_padrao?: string | null
          updated_at?: string | null
          website?: string | null
          whatsapp?: string | null
        }
        Update: {
          active?: boolean | null
          cep?: string | null
          cidade?: string | null
          cor_primaria?: string | null
          cor_secundaria?: string | null
          created_at?: string | null
          descricao?: string | null
          description?: string | null
          domain?: string | null
          email_contato?: string | null
          endereco?: string | null
          estado?: string | null
          id?: string
          logo_url?: string | null
          max_users?: number | null
          name?: string
          plan?: string | null
          settings?: Json | null
          slug?: string
          telefone?: string | null
          time_casa_padrao?: string | null
          updated_at?: string | null
          website?: string | null
          whatsapp?: string | null
        }
        Relationships: []
      }
      parcela_alertas: {
        Row: {
          canal: string | null
          created_at: string | null
          data_envio: string | null
          id: string
          mensagem_enviada: string | null
          organization_id: string
          parcela_id: string
          resposta_recebida: string | null
          status_envio: string | null
          template_usado: string | null
          tentativas: number | null
          tipo_alerta: string
        }
        Insert: {
          canal?: string | null
          created_at?: string | null
          data_envio?: string | null
          id?: string
          mensagem_enviada?: string | null
          organization_id: string
          parcela_id: string
          resposta_recebida?: string | null
          status_envio?: string | null
          template_usado?: string | null
          tentativas?: number | null
          tipo_alerta: string
        }
        Update: {
          canal?: string | null
          created_at?: string | null
          data_envio?: string | null
          id?: string
          mensagem_enviada?: string | null
          organization_id?: string
          parcela_id?: string
          resposta_recebida?: string | null
          status_envio?: string | null
          template_usado?: string | null
          tentativas?: number | null
          tipo_alerta?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_alertas_parcela"
            columns: ["parcela_id"]
            isOneToOne: false
            referencedRelation: "viagem_passageiros_parcelas"
            referencedColumns: ["id"]
          },
        ]
      }
      parcela_historico: {
        Row: {
          acao: string
          created_at: string | null
          id: string
          ip_address: unknown | null
          observacoes: string | null
          organization_id: string
          parcela_id: string
          user_agent: string | null
          usuario_id: string | null
          valor_anterior: Json | null
          valor_novo: Json | null
        }
        Insert: {
          acao: string
          created_at?: string | null
          id?: string
          ip_address?: unknown | null
          observacoes?: string | null
          organization_id: string
          parcela_id: string
          user_agent?: string | null
          usuario_id?: string | null
          valor_anterior?: Json | null
          valor_novo?: Json | null
        }
        Update: {
          acao?: string
          created_at?: string | null
          id?: string
          ip_address?: unknown | null
          observacoes?: string | null
          organization_id?: string
          parcela_id?: string
          user_agent?: string | null
          usuario_id?: string | null
          valor_anterior?: Json | null
          valor_novo?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_historico_parcela"
            columns: ["parcela_id"]
            isOneToOne: false
            referencedRelation: "viagem_passageiros_parcelas"
            referencedColumns: ["id"]
          },
        ]
      }
      passageiro_passeios: {
        Row: {
          created_at: string | null
          id: string
          observacoes: string | null
          organization_id: string
          passeio_id: string
          passeio_nome: string | null
          status: string | null
          updated_at: string | null
          valor_cobrado: number
          viagem_passageiro_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          observacoes?: string | null
          organization_id: string
          passeio_id: string
          passeio_nome?: string | null
          status?: string | null
          updated_at?: string | null
          valor_cobrado?: number
          viagem_passageiro_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string
          passeio_id?: string
          passeio_nome?: string | null
          status?: string | null
          updated_at?: string | null
          valor_cobrado?: number
          viagem_passageiro_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "passageiro_passeios_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "passageiro_passeios_passeio_id_fkey"
            columns: ["passeio_id"]
            isOneToOne: false
            referencedRelation: "passeios"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "passageiro_passeios_viagem_passageiro_id_fkey"
            columns: ["viagem_passageiro_id"]
            isOneToOne: false
            referencedRelation: "backup_viagem_passageiros_state"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "passageiro_passeios_viagem_passageiro_id_fkey"
            columns: ["viagem_passageiro_id"]
            isOneToOne: false
            referencedRelation: "viagem_passageiros"
            referencedColumns: ["id"]
          },
        ]
      }
      passageiro_vinculacoes: {
        Row: {
          ativo: boolean | null
          data_vinculacao: string | null
          id: string
          observacoes: string | null
          passageiro_principal_id: string
          passageiro_vinculado_id: string
          usuario_vinculacao: string | null
          viagem_id: string
        }
        Insert: {
          ativo?: boolean | null
          data_vinculacao?: string | null
          id?: string
          observacoes?: string | null
          passageiro_principal_id: string
          passageiro_vinculado_id: string
          usuario_vinculacao?: string | null
          viagem_id: string
        }
        Update: {
          ativo?: boolean | null
          data_vinculacao?: string | null
          id?: string
          observacoes?: string | null
          passageiro_principal_id?: string
          passageiro_vinculado_id?: string
          usuario_vinculacao?: string | null
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "passageiro_vinculacoes_passageiro_principal_id_fkey"
            columns: ["passageiro_principal_id"]
            isOneToOne: false
            referencedRelation: "backup_viagem_passageiros_state"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "passageiro_vinculacoes_passageiro_principal_id_fkey"
            columns: ["passageiro_principal_id"]
            isOneToOne: false
            referencedRelation: "viagem_passageiros"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "passageiro_vinculacoes_passageiro_vinculado_id_fkey"
            columns: ["passageiro_vinculado_id"]
            isOneToOne: true
            referencedRelation: "backup_viagem_passageiros_state"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "passageiro_vinculacoes_passageiro_vinculado_id_fkey"
            columns: ["passageiro_vinculado_id"]
            isOneToOne: true
            referencedRelation: "viagem_passageiros"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "passageiro_vinculacoes_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      passeios: {
        Row: {
          ativo: boolean | null
          categoria: string | null
          created_at: string | null
          custo_operacional: number | null
          id: string
          nome: string
          organization_id: string
          updated_at: string | null
          valor: number
        }
        Insert: {
          ativo?: boolean | null
          categoria?: string | null
          created_at?: string | null
          custo_operacional?: number | null
          id?: string
          nome: string
          organization_id: string
          updated_at?: string | null
          valor?: number
        }
        Update: {
          ativo?: boolean | null
          categoria?: string | null
          created_at?: string | null
          custo_operacional?: number | null
          id?: string
          nome?: string
          organization_id?: string
          updated_at?: string | null
          valor?: number
        }
        Relationships: [
          {
            foreignKeyName: "passeios_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      passengers: {
        Row: {
          created_at: string | null
          data_nascimento: string | null
          documento: string | null
          email: string | null
          id: string
          nome: string
          organization_id: string
          telefone: string | null
        }
        Insert: {
          created_at?: string | null
          data_nascimento?: string | null
          documento?: string | null
          email?: string | null
          id?: string
          nome: string
          organization_id: string
          telefone?: string | null
        }
        Update: {
          created_at?: string | null
          data_nascimento?: string | null
          documento?: string | null
          email?: string | null
          id?: string
          nome?: string
          organization_id?: string
          telefone?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "passengers_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      payments: {
        Row: {
          cliente_id: string | null
          created_at: string | null
          data_pagamento: string | null
          id: string
          metodo_pagamento: string | null
          organization_id: string
          referencia_externa: string | null
          status: string | null
          valor: number
          viagem_id: string | null
        }
        Insert: {
          cliente_id?: string | null
          created_at?: string | null
          data_pagamento?: string | null
          id?: string
          metodo_pagamento?: string | null
          organization_id: string
          referencia_externa?: string | null
          status?: string | null
          valor: number
          viagem_id?: string | null
        }
        Update: {
          cliente_id?: string | null
          created_at?: string | null
          data_pagamento?: string | null
          id?: string
          metodo_pagamento?: string | null
          organization_id?: string
          referencia_externa?: string | null
          status?: string | null
          valor?: number
          viagem_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "payments_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payments_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payments_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      pedido_itens: {
        Row: {
          id: string
          organization_id: string
          pedido_id: string
          preco_unitario: number
          produto_id: string
          quantidade: number
          subtotal: number
        }
        Insert: {
          id?: string
          organization_id: string
          pedido_id: string
          preco_unitario: number
          produto_id: string
          quantidade: number
          subtotal: number
        }
        Update: {
          id?: string
          organization_id?: string
          pedido_id?: string
          preco_unitario?: number
          produto_id?: string
          quantidade?: number
          subtotal?: number
        }
        Relationships: [
          {
            foreignKeyName: "pedido_itens_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pedido_itens_pedido_id_fkey"
            columns: ["pedido_id"]
            isOneToOne: false
            referencedRelation: "pedidos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pedido_itens_produto_id_fkey"
            columns: ["produto_id"]
            isOneToOne: false
            referencedRelation: "produtos"
            referencedColumns: ["id"]
          },
        ]
      }
      pedidos: {
        Row: {
          cliente_id: string
          data_pedido: string | null
          id: string
          observacoes: string | null
          organization_id: string
          status: string | null
          total: number
        }
        Insert: {
          cliente_id: string
          data_pedido?: string | null
          id?: string
          observacoes?: string | null
          organization_id: string
          status?: string | null
          total: number
        }
        Update: {
          cliente_id?: string
          data_pedido?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string
          status?: string | null
          total?: number
        }
        Relationships: [
          {
            foreignKeyName: "pedidos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pedidos_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      produtos: {
        Row: {
          ativo: boolean | null
          categoria_id: string | null
          created_at: string | null
          descricao: string | null
          estoque: number | null
          id: string
          imagem_url: string | null
          nome: string
          organization_id: string
          preco: number
          updated_at: string | null
        }
        Insert: {
          ativo?: boolean | null
          categoria_id?: string | null
          created_at?: string | null
          descricao?: string | null
          estoque?: number | null
          id?: string
          imagem_url?: string | null
          nome: string
          organization_id: string
          preco: number
          updated_at?: string | null
        }
        Update: {
          ativo?: boolean | null
          categoria_id?: string | null
          created_at?: string | null
          descricao?: string | null
          estoque?: number | null
          id?: string
          imagem_url?: string | null
          nome?: string
          organization_id?: string
          preco?: number
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "produtos_categoria_id_fkey"
            columns: ["categoria_id"]
            isOneToOne: false
            referencedRelation: "categorias_produtos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "produtos_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          active: boolean | null
          avatar_url: string | null
          created_at: string | null
          email: string
          full_name: string | null
          id: string
          last_login: string | null
          organization_id: string | null
          permissions: Json | null
          role: string | null
          updated_at: string | null
        }
        Insert: {
          active?: boolean | null
          avatar_url?: string | null
          created_at?: string | null
          email: string
          full_name?: string | null
          id: string
          last_login?: string | null
          organization_id?: string | null
          permissions?: Json | null
          role?: string | null
          updated_at?: string | null
        }
        Update: {
          active?: boolean | null
          avatar_url?: string | null
          created_at?: string | null
          email?: string
          full_name?: string | null
          id?: string
          last_login?: string | null
          organization_id?: string | null
          permissions?: Json | null
          role?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "profiles_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      projecoes_fluxo_caixa: {
        Row: {
          created_at: string | null
          data_projecao: string
          descricao: string | null
          id: string
          organization_id: string
          tipo: string
          valor_projetado: number
        }
        Insert: {
          created_at?: string | null
          data_projecao: string
          descricao?: string | null
          id?: string
          organization_id: string
          tipo: string
          valor_projetado: number
        }
        Update: {
          created_at?: string | null
          data_projecao?: string
          descricao?: string | null
          id?: string
          organization_id?: string
          tipo?: string
          valor_projetado?: number
        }
        Relationships: [
          {
            foreignKeyName: "projecoes_fluxo_caixa_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      receitas: {
        Row: {
          categoria_id: string | null
          created_at: string | null
          data_receita: string
          descricao: string
          id: string
          organization_id: string
          valor: number
          viagem_id: string | null
        }
        Insert: {
          categoria_id?: string | null
          created_at?: string | null
          data_receita: string
          descricao: string
          id?: string
          organization_id: string
          valor: number
          viagem_id?: string | null
        }
        Update: {
          categoria_id?: string | null
          created_at?: string | null
          data_receita?: string
          descricao?: string
          id?: string
          organization_id?: string
          valor?: number
          viagem_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "receitas_categoria_id_fkey"
            columns: ["categoria_id"]
            isOneToOne: false
            referencedRelation: "categorias_financeiras"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "receitas_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "receitas_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      setores_estadio: {
        Row: {
          ativo: boolean | null
          created_at: string | null
          descricao: string | null
          disponivel: boolean | null
          estadio: string | null
          id: string
          nome: string
          organization_id: string | null
          preco_base: number
          time_casa: string | null
        }
        Insert: {
          ativo?: boolean | null
          created_at?: string | null
          descricao?: string | null
          disponivel?: boolean | null
          estadio?: string | null
          id?: string
          nome: string
          organization_id?: string | null
          preco_base: number
          time_casa?: string | null
        }
        Update: {
          ativo?: boolean | null
          created_at?: string | null
          descricao?: string | null
          disponivel?: boolean | null
          estadio?: string | null
          id?: string
          nome?: string
          organization_id?: string | null
          preco_base?: number
          time_casa?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "setores_maracana_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      sistema_parametros: {
        Row: {
          created_at: string | null
          descricao: string | null
          editavel: boolean | null
          id: string
          organization_id: string
          parametro: string
          tipo: string | null
          updated_at: string | null
          valor: string
        }
        Insert: {
          created_at?: string | null
          descricao?: string | null
          editavel?: boolean | null
          id?: string
          organization_id: string
          parametro: string
          tipo?: string | null
          updated_at?: string | null
          valor: string
        }
        Update: {
          created_at?: string | null
          descricao?: string | null
          editavel?: boolean | null
          id?: string
          organization_id?: string
          parametro?: string
          tipo?: string | null
          updated_at?: string | null
          valor?: string
        }
        Relationships: [
          {
            foreignKeyName: "sistema_parametros_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      stripe_customers: {
        Row: {
          cliente_id: string
          created_at: string | null
          email: string | null
          id: string
          organization_id: string
          stripe_customer_id: string
        }
        Insert: {
          cliente_id: string
          created_at?: string | null
          email?: string | null
          id?: string
          organization_id: string
          stripe_customer_id: string
        }
        Update: {
          cliente_id?: string
          created_at?: string | null
          email?: string | null
          id?: string
          organization_id?: string
          stripe_customer_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "stripe_customers_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stripe_customers_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      super_admin_users: {
        Row: {
          can_access_all_tenants: boolean | null
          can_block_organizations: boolean | null
          can_manage_subscriptions: boolean | null
          can_view_analytics: boolean | null
          created_at: string | null
          created_by: string | null
          id: string
          updated_at: string | null
          user_id: string
        }
        Insert: {
          can_access_all_tenants?: boolean | null
          can_block_organizations?: boolean | null
          can_manage_subscriptions?: boolean | null
          can_view_analytics?: boolean | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          updated_at?: string | null
          user_id: string
        }
        Update: {
          can_access_all_tenants?: boolean | null
          can_block_organizations?: boolean | null
          can_manage_subscriptions?: boolean | null
          can_view_analytics?: boolean | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "super_admin_users_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "super_admin_users_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      system_activity_logs: {
        Row: {
          action_type: string
          created_at: string | null
          description: string
          id: string
          ip_address: unknown | null
          metadata: Json | null
          organization_id: string | null
          resource_id: string | null
          resource_type: string | null
          user_agent: string | null
          user_id: string | null
        }
        Insert: {
          action_type: string
          created_at?: string | null
          description: string
          id?: string
          ip_address?: unknown | null
          metadata?: Json | null
          organization_id?: string | null
          resource_id?: string | null
          resource_type?: string | null
          user_agent?: string | null
          user_id?: string | null
        }
        Update: {
          action_type?: string
          created_at?: string | null
          description?: string
          id?: string
          ip_address?: unknown | null
          metadata?: Json | null
          organization_id?: string | null
          resource_id?: string | null
          resource_type?: string | null
          user_agent?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "system_activity_logs_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      system_config: {
        Row: {
          config_key: string
          config_value: string | null
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          organization_id: string
          updated_at: string | null
        }
        Insert: {
          config_key: string
          config_value?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          organization_id: string
          updated_at?: string | null
        }
        Update: {
          config_key?: string
          config_value?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          organization_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "system_config_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      transfer_data: {
        Row: {
          created_at: string | null
          id: string
          motorista: string | null
          organization_id: string | null
          placa: string | null
          rota: string | null
          updated_at: string | null
          viagem_onibus_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          motorista?: string | null
          organization_id?: string | null
          placa?: string | null
          rota?: string | null
          updated_at?: string | null
          viagem_onibus_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          motorista?: string | null
          organization_id?: string | null
          placa?: string | null
          rota?: string | null
          updated_at?: string | null
          viagem_onibus_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "transfer_data_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "transfer_data_viagem_onibus_id_fkey"
            columns: ["viagem_onibus_id"]
            isOneToOne: true
            referencedRelation: "viagem_onibus"
            referencedColumns: ["id"]
          },
        ]
      }
      transfer_data_simple: {
        Row: {
          created_at: string | null
          id: string
          motorista: string | null
          placa: string | null
          rota: string | null
          updated_at: string | null
          viagem_onibus_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          motorista?: string | null
          placa?: string | null
          rota?: string | null
          updated_at?: string | null
          viagem_onibus_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          motorista?: string | null
          placa?: string | null
          rota?: string | null
          updated_at?: string | null
          viagem_onibus_id?: string
        }
        Relationships: []
      }
      user_invitations: {
        Row: {
          accepted_at: string | null
          created_at: string | null
          email: string
          expires_at: string | null
          id: string
          invited_by: string | null
          organization_id: string
          permissions: Json | null
          role: string
          status: string | null
          token: string
          updated_at: string | null
        }
        Insert: {
          accepted_at?: string | null
          created_at?: string | null
          email: string
          expires_at?: string | null
          id?: string
          invited_by?: string | null
          organization_id: string
          permissions?: Json | null
          role?: string
          status?: string | null
          token: string
          updated_at?: string | null
        }
        Update: {
          accepted_at?: string | null
          created_at?: string | null
          email?: string
          expires_at?: string | null
          id?: string
          invited_by?: string | null
          organization_id?: string
          permissions?: Json | null
          role?: string
          status?: string | null
          token?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_invitations_invited_by_fkey"
            columns: ["invited_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_invitations_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      user_permissions: {
        Row: {
          created_at: string | null
          id: string
          organization_id: string
          permissions: Json
          updated_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          organization_id: string
          permissions?: Json
          updated_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          organization_id?: string
          permissions?: Json
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_permissions_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_permissions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_profiles: {
        Row: {
          avatar_url: string | null
          bio: string | null
          created_at: string | null
          display_name: string | null
          id: string
          organization_id: string
          preferences: Json | null
          updated_at: string | null
          user_id: string
        }
        Insert: {
          avatar_url?: string | null
          bio?: string | null
          created_at?: string | null
          display_name?: string | null
          id?: string
          organization_id: string
          preferences?: Json | null
          updated_at?: string | null
          user_id: string
        }
        Update: {
          avatar_url?: string | null
          bio?: string | null
          created_at?: string | null
          display_name?: string | null
          id?: string
          organization_id?: string
          preferences?: Json | null
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_profiles_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      viagem_cobranca_historico: {
        Row: {
          created_at: string | null
          data_tentativa: string | null
          id: string
          observacoes: string | null
          organization_id: string | null
          status_envio: string | null
          template_usado: string | null
          tipo_contato: string
          viagem_passageiro_id: string
        }
        Insert: {
          created_at?: string | null
          data_tentativa?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          status_envio?: string | null
          template_usado?: string | null
          tipo_contato: string
          viagem_passageiro_id: string
        }
        Update: {
          created_at?: string | null
          data_tentativa?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          status_envio?: string | null
          template_usado?: string | null
          tipo_contato?: string
          viagem_passageiro_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagem_cobranca_historico_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_cobranca_historico_viagem_passageiro_id_fkey"
            columns: ["viagem_passageiro_id"]
            isOneToOne: false
            referencedRelation: "backup_viagem_passageiros_state"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_cobranca_historico_viagem_passageiro_id_fkey"
            columns: ["viagem_passageiro_id"]
            isOneToOne: false
            referencedRelation: "viagem_passageiros"
            referencedColumns: ["id"]
          },
        ]
      }
      viagem_despesas: {
        Row: {
          categoria: string
          comprovante_url: string | null
          created_at: string | null
          data_despesa: string
          forma_pagamento: string | null
          fornecedor: string
          id: string
          observacoes: string | null
          organization_id: string | null
          status: string | null
          subcategoria: string | null
          updated_at: string | null
          valor: number
          viagem_id: string
        }
        Insert: {
          categoria: string
          comprovante_url?: string | null
          created_at?: string | null
          data_despesa: string
          forma_pagamento?: string | null
          fornecedor: string
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          status?: string | null
          subcategoria?: string | null
          updated_at?: string | null
          valor: number
          viagem_id: string
        }
        Update: {
          categoria?: string
          comprovante_url?: string | null
          created_at?: string | null
          data_despesa?: string
          forma_pagamento?: string | null
          fornecedor?: string
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          status?: string | null
          subcategoria?: string | null
          updated_at?: string | null
          valor?: number
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagem_despesas_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_despesas_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      viagem_onibus: {
        Row: {
          capacidade_onibus: number
          created_at: string | null
          empresa: string | null
          id: string
          lugares_extras: number | null
          motorista_transfer: string | null
          numero_identificacao: string | null
          observacoes: string | null
          onibus_id: string
          organization_id: string | null
          placa_transfer: string | null
          responsavel_principal: string | null
          responsavel_secundario: string | null
          rota_transfer: string | null
          telefone_responsavel_principal: string | null
          telefone_responsavel_secundario: string | null
          tipo_onibus: string | null
          viagem_id: string
        }
        Insert: {
          capacidade_onibus?: number
          created_at?: string | null
          empresa?: string | null
          id?: string
          lugares_extras?: number | null
          motorista_transfer?: string | null
          numero_identificacao?: string | null
          observacoes?: string | null
          onibus_id: string
          organization_id?: string | null
          placa_transfer?: string | null
          responsavel_principal?: string | null
          responsavel_secundario?: string | null
          rota_transfer?: string | null
          telefone_responsavel_principal?: string | null
          telefone_responsavel_secundario?: string | null
          tipo_onibus?: string | null
          viagem_id: string
        }
        Update: {
          capacidade_onibus?: number
          created_at?: string | null
          empresa?: string | null
          id?: string
          lugares_extras?: number | null
          motorista_transfer?: string | null
          numero_identificacao?: string | null
          observacoes?: string | null
          onibus_id?: string
          organization_id?: string | null
          placa_transfer?: string | null
          responsavel_principal?: string | null
          responsavel_secundario?: string | null
          rota_transfer?: string | null
          telefone_responsavel_principal?: string | null
          telefone_responsavel_secundario?: string | null
          tipo_onibus?: string | null
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagem_onibus_onibus_id_fkey"
            columns: ["onibus_id"]
            isOneToOne: false
            referencedRelation: "onibus"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_onibus_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_onibus_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      viagem_orcamento: {
        Row: {
          categoria: string
          created_at: string | null
          id: string
          observacoes: string | null
          organization_id: string | null
          subcategoria: string | null
          updated_at: string | null
          valor_orcado: number
          valor_realizado: number | null
          viagem_id: string
        }
        Insert: {
          categoria: string
          created_at?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          subcategoria?: string | null
          updated_at?: string | null
          valor_orcado: number
          valor_realizado?: number | null
          viagem_id: string
        }
        Update: {
          categoria?: string
          created_at?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          subcategoria?: string | null
          updated_at?: string | null
          valor_orcado?: number
          valor_realizado?: number | null
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagem_orcamento_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_orcamento_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      viagem_parcelamento_config: {
        Row: {
          ativo: boolean | null
          created_at: string | null
          data_vencimento_primeira: string
          id: string
          intervalo_dias: number | null
          juros_percentual: number | null
          numero_parcelas: number
          organization_id: string
          valor_parcela: number
          viagem_id: string
        }
        Insert: {
          ativo?: boolean | null
          created_at?: string | null
          data_vencimento_primeira: string
          id?: string
          intervalo_dias?: number | null
          juros_percentual?: number | null
          numero_parcelas: number
          organization_id: string
          valor_parcela: number
          viagem_id: string
        }
        Update: {
          ativo?: boolean | null
          created_at?: string | null
          data_vencimento_primeira?: string
          id?: string
          intervalo_dias?: number | null
          juros_percentual?: number | null
          numero_parcelas?: number
          organization_id?: string
          valor_parcela?: number
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagem_parcelamento_config_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_parcelamento_config_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      viagem_passageiros: {
        Row: {
          cidade_embarque: string | null
          cliente_id: string
          created_at: string | null
          credito_origem_id: string | null
          data_inscricao: string | null
          desconto: number | null
          forma_pagamento: string | null
          id: string
          is_responsavel_onibus: boolean | null
          observacoes: string | null
          onibus_id: string | null
          organization_id: string | null
          pago_por_credito: boolean | null
          setor_maracana: string | null
          status_pagamento: string | null
          status_presenca: string | null
          updated_at: string | null
          valor: number | null
          valor_credito_utilizado: number | null
          valor_pago: number
          viagem_id: string
        }
        Insert: {
          cidade_embarque?: string | null
          cliente_id: string
          created_at?: string | null
          credito_origem_id?: string | null
          data_inscricao?: string | null
          desconto?: number | null
          forma_pagamento?: string | null
          id?: string
          is_responsavel_onibus?: boolean | null
          observacoes?: string | null
          onibus_id?: string | null
          organization_id?: string | null
          pago_por_credito?: boolean | null
          setor_maracana?: string | null
          status_pagamento?: string | null
          status_presenca?: string | null
          updated_at?: string | null
          valor?: number | null
          valor_credito_utilizado?: number | null
          valor_pago: number
          viagem_id: string
        }
        Update: {
          cidade_embarque?: string | null
          cliente_id?: string
          created_at?: string | null
          credito_origem_id?: string | null
          data_inscricao?: string | null
          desconto?: number | null
          forma_pagamento?: string | null
          id?: string
          is_responsavel_onibus?: boolean | null
          observacoes?: string | null
          onibus_id?: string | null
          organization_id?: string | null
          pago_por_credito?: boolean | null
          setor_maracana?: string | null
          status_pagamento?: string | null
          status_presenca?: string | null
          updated_at?: string | null
          valor?: number | null
          valor_credito_utilizado?: number | null
          valor_pago?: number
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagem_passageiros_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passageiros_credito_origem_id_fkey"
            columns: ["credito_origem_id"]
            isOneToOne: false
            referencedRelation: "cliente_creditos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passageiros_onibus_id_fkey"
            columns: ["onibus_id"]
            isOneToOne: false
            referencedRelation: "viagem_onibus"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passageiros_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passageiros_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      viagem_passageiros_parcelas: {
        Row: {
          created_at: string | null
          data_pagamento: string | null
          data_vencimento: string
          forma_pagamento: string | null
          id: string
          numero_parcela: number
          organization_id: string | null
          status: string | null
          tipo_parcelamento: string | null
          total_parcelas: number
          updated_at: string | null
          valor_original: number
          valor_pago: number | null
          valor_parcela: number
          viagem_passageiro_id: string
        }
        Insert: {
          created_at?: string | null
          data_pagamento?: string | null
          data_vencimento: string
          forma_pagamento?: string | null
          id?: string
          numero_parcela: number
          organization_id?: string | null
          status?: string | null
          tipo_parcelamento?: string | null
          total_parcelas: number
          updated_at?: string | null
          valor_original: number
          valor_pago?: number | null
          valor_parcela: number
          viagem_passageiro_id: string
        }
        Update: {
          created_at?: string | null
          data_pagamento?: string | null
          data_vencimento?: string
          forma_pagamento?: string | null
          id?: string
          numero_parcela?: number
          organization_id?: string | null
          status?: string | null
          tipo_parcelamento?: string | null
          total_parcelas?: number
          updated_at?: string | null
          valor_original?: number
          valor_pago?: number | null
          valor_parcela?: number
          viagem_passageiro_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagem_passageiros_parcelas_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passageiros_parcelas_viagem_passageiro_id_fkey"
            columns: ["viagem_passageiro_id"]
            isOneToOne: false
            referencedRelation: "backup_viagem_passageiros_state"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passageiros_parcelas_viagem_passageiro_id_fkey"
            columns: ["viagem_passageiro_id"]
            isOneToOne: false
            referencedRelation: "viagem_passageiros"
            referencedColumns: ["id"]
          },
        ]
      }
      viagem_passeios: {
        Row: {
          ativo: boolean | null
          created_at: string | null
          descricao: string | null
          id: string
          nome: string
          obrigatorio: boolean | null
          organization_id: string
          passeio_id: string
          valor: number
          viagem_id: string
        }
        Insert: {
          ativo?: boolean | null
          created_at?: string | null
          descricao?: string | null
          id?: string
          nome: string
          obrigatorio?: boolean | null
          organization_id: string
          passeio_id: string
          valor?: number
          viagem_id: string
        }
        Update: {
          ativo?: boolean | null
          created_at?: string | null
          descricao?: string | null
          id?: string
          nome?: string
          obrigatorio?: boolean | null
          organization_id?: string
          passeio_id?: string
          valor?: number
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_viagem_passeios_passeio_id"
            columns: ["passeio_id"]
            isOneToOne: false
            referencedRelation: "passeios"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passeios_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passeios_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      viagem_receitas: {
        Row: {
          categoria: string
          created_at: string | null
          data_recebimento: string
          descricao: string
          forma_pagamento: string | null
          id: string
          observacoes: string | null
          organization_id: string | null
          status: string | null
          updated_at: string | null
          valor: number
          viagem_id: string
        }
        Insert: {
          categoria: string
          created_at?: string | null
          data_recebimento: string
          descricao: string
          forma_pagamento?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          status?: string | null
          updated_at?: string | null
          valor: number
          viagem_id: string
        }
        Update: {
          categoria?: string
          created_at?: string | null
          data_recebimento?: string
          descricao?: string
          forma_pagamento?: string | null
          id?: string
          observacoes?: string | null
          organization_id?: string | null
          status?: string | null
          updated_at?: string | null
          valor?: number
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagem_receitas_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_receitas_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      viagens: {
        Row: {
          adversario: string | null
          capacidade_onibus: number | null
          cidade_embarque: string | null
          created_at: string | null
          data_ida: string
          data_jogo: string | null
          data_saida: string | null
          data_volta: string
          destino: string
          dias_antecedencia: number | null
          empresa: string | null
          exige_pagamento_completo: boolean | null
          id: string
          local_jogo: string | null
          logo_adversario: string | null
          logo_flamengo: string | null
          nome_estadio: string | null
          observacoes: string | null
          onibus_id: string | null
          organization_id: string
          outro_passeio: string | null
          permite_viagem_com_pendencia: boolean | null
          preco_individual: number
          setor_padrao: string | null
          status_viagem: string | null
          tem_passeios: boolean | null
          tipo_onibus: string | null
          tipo_pagamento: string | null
          updated_at: string | null
          vagas_disponiveis: number
          valor_padrao: number | null
        }
        Insert: {
          adversario?: string | null
          capacidade_onibus?: number | null
          cidade_embarque?: string | null
          created_at?: string | null
          data_ida: string
          data_jogo?: string | null
          data_saida?: string | null
          data_volta: string
          destino: string
          dias_antecedencia?: number | null
          empresa?: string | null
          exige_pagamento_completo?: boolean | null
          id?: string
          local_jogo?: string | null
          logo_adversario?: string | null
          logo_flamengo?: string | null
          nome_estadio?: string | null
          observacoes?: string | null
          onibus_id?: string | null
          organization_id: string
          outro_passeio?: string | null
          permite_viagem_com_pendencia?: boolean | null
          preco_individual: number
          setor_padrao?: string | null
          status_viagem?: string | null
          tem_passeios?: boolean | null
          tipo_onibus?: string | null
          tipo_pagamento?: string | null
          updated_at?: string | null
          vagas_disponiveis: number
          valor_padrao?: number | null
        }
        Update: {
          adversario?: string | null
          capacidade_onibus?: number | null
          cidade_embarque?: string | null
          created_at?: string | null
          data_ida?: string
          data_jogo?: string | null
          data_saida?: string | null
          data_volta?: string
          destino?: string
          dias_antecedencia?: number | null
          empresa?: string | null
          exige_pagamento_completo?: boolean | null
          id?: string
          local_jogo?: string | null
          logo_adversario?: string | null
          logo_flamengo?: string | null
          nome_estadio?: string | null
          observacoes?: string | null
          onibus_id?: string | null
          organization_id?: string
          outro_passeio?: string | null
          permite_viagem_com_pendencia?: boolean | null
          preco_individual?: number
          setor_padrao?: string | null
          status_viagem?: string | null
          tem_passeios?: boolean | null
          tipo_onibus?: string | null
          tipo_pagamento?: string | null
          updated_at?: string | null
          vagas_disponiveis?: number
          valor_padrao?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_viagens_organization"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagens_onibus_id_fkey"
            columns: ["onibus_id"]
            isOneToOne: false
            referencedRelation: "onibus"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagens_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      viagens_ingressos: {
        Row: {
          created_at: string | null
          id: string
          ingresso_id: string
          organization_id: string
          preco_unitario: number | null
          quantidade: number | null
          viagem_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          ingresso_id: string
          organization_id: string
          preco_unitario?: number | null
          quantidade?: number | null
          viagem_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          ingresso_id?: string
          organization_id?: string
          preco_unitario?: number | null
          quantidade?: number | null
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagens_ingressos_ingresso_id_fkey"
            columns: ["ingresso_id"]
            isOneToOne: false
            referencedRelation: "ingressos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagens_ingressos_ingresso_id_fkey"
            columns: ["ingresso_id"]
            isOneToOne: false
            referencedRelation: "ingressos_com_cliente"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagens_ingressos_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagens_ingressos_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      backup_viagem_passageiros_state: {
        Row: {
          cidade_embarque: string | null
          cliente_id: string | null
          cliente_nome: string | null
          created_at: string | null
          data_jogo: string | null
          id: string | null
          is_responsavel_onibus: boolean | null
          onibus_id: string | null
          onibus_numero: string | null
          setor_maracana: string | null
          status_presenca: string | null
          viagem_destino: string | null
          viagem_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "viagem_passageiros_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passageiros_onibus_id_fkey"
            columns: ["onibus_id"]
            isOneToOne: false
            referencedRelation: "viagem_onibus"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "viagem_passageiros_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
        ]
      }
      ingressos_com_cliente: {
        Row: {
          adversario: string | null
          cliente_email: string | null
          cliente_id: string | null
          cliente_nome: string | null
          cliente_telefone: string | null
          created_at: string | null
          desconto: number | null
          id: string | null
          jogo_data: string | null
          local_jogo: string | null
          logo_adversario: string | null
          lucro: number | null
          margem_percentual: number | null
          observacoes: string | null
          preco_custo: number | null
          preco_venda: number | null
          setor_estadio: string | null
          situacao_financeira: string | null
          updated_at: string | null
          valor_final: number | null
          viagem_id: string | null
          viagem_ingressos_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "ingressos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ingressos_viagem_id_fkey"
            columns: ["viagem_id"]
            isOneToOne: false
            referencedRelation: "viagens"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ingressos_viagem_ingressos_id_fkey"
            columns: ["viagem_ingressos_id"]
            isOneToOne: false
            referencedRelation: "viagens_ingressos"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      auto_allocate_passengers_to_buses: {
        Args: Record<PropertyKey, never>
        Returns: undefined
      }
      calcular_capacidades_onibus: {
        Args: { p_viagem_id: string }
        Returns: Json
      }
      cleanup_orphan_onibus_images: {
        Args: Record<PropertyKey, never>
        Returns: undefined
      }
      create_organization_with_user: {
        Args: {
          cor_prim?: string
          cor_sec?: string
          org_email?: string
          org_name: string
          org_phone?: string
          org_slug: string
          time_casa?: string
          user_id?: string
        }
        Returns: Json
      }
      criar_vinculacao_passageiros: {
        Args: {
          p_cor?: string
          p_nome_grupo?: string
          p_passageiro_ids: string[]
          p_viagem_id?: string
        }
        Returns: Json
      }
      delete_user_permissions: {
        Args: { p_organization_id: string; p_user_id: string }
        Returns: undefined
      }
      desvincular_passageiro: {
        Args: { p_passageiro_id: string; p_usuario_id?: string }
        Returns: Json
      }
      get_user_organization_id: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
      get_user_permissions: {
        Args: { user_ids: string[] }
        Returns: {
          created_at: string
          id: string
          organization_id: string
          permissions: Json
          updated_at: string
          user_id: string
        }[]
      }
      get_user_permissions_by_id: {
        Args: { p_organization_id: string; p_user_id: string }
        Returns: Json
      }
      is_dev_or_admin: {
        Args: Record<PropertyKey, never>
        Returns: boolean
      }
      is_organization_active: {
        Args: { org_id: string }
        Returns: boolean
      }
      log_system_activity: {
        Args: {
          p_action_type: string
          p_description?: string
          p_ip_address?: unknown
          p_metadata?: Json
          p_organization_id: string
          p_resource_id?: string
          p_resource_type?: string
          p_user_agent?: string
          p_user_id: string
        }
        Returns: string
      }
      obter_grupos_vinculacao: {
        Args: { p_viagem_id: string }
        Returns: Json
      }
      obter_historico_transferencias: {
        Args: { p_limite?: number; p_viagem_id: string }
        Returns: Json
      }
      obter_vinculacoes_viagem: {
        Args: { p_viagem_id: string }
        Returns: Json
      }
      pode_vincular_passageiro: {
        Args: { p_passageiro_id: string; p_principal_id: string }
        Returns: Json
      }
      save_transfer_data: {
        Args: {
          motorista?: string
          onibus_id: string
          placa?: string
          rota?: string
        }
        Returns: undefined
      }
      sugerir_transferencias_otimizadas: {
        Args: { p_viagem_id: string }
        Returns: Json
      }
      transferir_passageiros_inteligente: {
        Args: {
          p_incluir_vinculados?: boolean
          p_onibus_destino_id: string
          p_passageiros_destino?: string[]
          p_passageiros_origem: string[]
          p_usuario_id?: string
          p_viagem_id: string
        }
        Returns: Json
      }
      update_transfer_data: {
        Args: {
          p_motorista_transfer?: string
          p_onibus_id: string
          p_placa_transfer?: string
          p_rota_transfer?: string
        }
        Returns: undefined
      }
      upsert_transfer_data: {
        Args: {
          p_motorista?: string
          p_placa?: string
          p_rota?: string
          p_viagem_onibus_id: string
        }
        Returns: undefined
      }
      upsert_user_permissions: {
        Args: {
          p_organization_id: string
          p_permissions: Json
          p_user_id: string
        }
        Returns: undefined
      }
      validar_transferencia: {
        Args: {
          p_incluir_vinculados?: boolean
          p_onibus_destino_id: string
          p_passageiros_origem: string[]
          p_viagem_id: string
        }
        Returns: Json
      }
      vincular_passageiros: {
        Args: {
          p_principal_id: string
          p_usuario_id?: string
          p_viagem_id: string
          p_vinculados: string[]
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
