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
          foto: string | null
          id: string
          indicacao_nome: string | null
          nome: string
          numero: string
          observacoes: string | null
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
          foto?: string | null
          id?: string
          indicacao_nome?: string | null
          nome: string
          numero: string
          observacoes?: string | null
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
          foto?: string | null
          id?: string
          indicacao_nome?: string | null
          nome?: string
          numero?: string
          observacoes?: string | null
          telefone?: string
        }
        Relationships: []
      }
      credito_vinculacoes: {
        Row: {
          created_at: string | null
          credito_id: string
          data_uso: string | null
          id: string
          observacoes: string | null
          valor_usado: number
          viagem_id: string
        }
        Insert: {
          created_at?: string | null
          credito_id: string
          data_uso?: string | null
          id?: string
          observacoes?: string | null
          valor_usado: number
          viagem_id: string
        }
        Update: {
          created_at?: string | null
          credito_id?: string
          data_uso?: string | null
          id?: string
          observacoes?: string | null
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
          site?: string | null
          telefone?: string | null
          updated_at?: string | null
          whatsapp?: string | null
        }
        Relationships: []
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
          lucro: number | null
          margem_percentual: number | null
          metodo_pagamento: string | null
          observacoes: string | null
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
          lucro?: number | null
          margem_percentual?: number | null
          metodo_pagamento?: string | null
          observacoes?: string | null
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
          lucro?: number | null
          margem_percentual?: number | null
          metodo_pagamento?: string | null
          observacoes?: string | null
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
        }
        Relationships: [
          {
            foreignKeyName: "ingressos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
        ]
      }
      onibus: {
        Row: {
          capacidade: number
          created_at: string | null
          empresa: string
          id: string
          numero_identificacao: string | null
          tipo_onibus: string
          updated_at: string | null
        }
        Insert: {
          capacidade: number
          created_at?: string | null
          empresa: string
          id?: string
          numero_identificacao?: string | null
          tipo_onibus: string
          updated_at?: string | null
        }
        Update: {
          capacidade?: number
          created_at?: string | null
          empresa?: string
          id?: string
          numero_identificacao?: string | null
          tipo_onibus?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      setores_maracana: {
        Row: {
          ativo: boolean | null
          created_at: string | null
          descricao: string | null
          disponivel: boolean | null
          id: string
          nome: string
          preco_base: number
        }
        Insert: {
          ativo?: boolean | null
          created_at?: string | null
          descricao?: string | null
          disponivel?: boolean | null
          id?: string
          nome: string
          preco_base: number
        }
        Update: {
          ativo?: boolean | null
          created_at?: string | null
          descricao?: string | null
          disponivel?: boolean | null
          id?: string
          nome?: string
          preco_base?: number
        }
        Relationships: []
      }
      viagem_cobranca_historico: {
        Row: {
          created_at: string | null
          data_tentativa: string | null
          id: string
          observacoes: string | null
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
          status_envio?: string | null
          template_usado?: string | null
          tipo_contato?: string
          viagem_passageiro_id?: string
        }
        Relationships: [
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
          status?: string | null
          subcategoria?: string | null
          updated_at?: string | null
          valor?: number
          viagem_id?: string
        }
        Relationships: [
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
          id: string
          lugares_extras: number | null
          observacoes: string | null
          onibus_id: string
          viagem_id: string
        }
        Insert: {
          capacidade_onibus?: number
          created_at?: string | null
          id?: string
          lugares_extras?: number | null
          observacoes?: string | null
          onibus_id: string
          viagem_id: string
        }
        Update: {
          capacidade_onibus?: number
          created_at?: string | null
          id?: string
          lugares_extras?: number | null
          observacoes?: string | null
          onibus_id?: string
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
          subcategoria?: string | null
          updated_at?: string | null
          valor_orcado?: number
          valor_realizado?: number | null
          viagem_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "viagem_orcamento_viagem_id_fkey"
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
          data_inscricao: string | null
          forma_pagamento: string | null
          id: string
          observacoes: string | null
          onibus_id: string | null
          setor_maracana: string | null
          status_pagamento: string | null
          valor: number | null
          valor_pago: number
          viagem_id: string
        }
        Insert: {
          cidade_embarque?: string | null
          cliente_id: string
          data_inscricao?: string | null
          forma_pagamento?: string | null
          id?: string
          observacoes?: string | null
          onibus_id?: string | null
          setor_maracana?: string | null
          status_pagamento?: string | null
          valor?: number | null
          valor_pago: number
          viagem_id: string
        }
        Update: {
          cidade_embarque?: string | null
          cliente_id?: string
          data_inscricao?: string | null
          forma_pagamento?: string | null
          id?: string
          observacoes?: string | null
          onibus_id?: string | null
          setor_maracana?: string | null
          status_pagamento?: string | null
          valor?: number | null
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
            foreignKeyName: "viagem_passageiros_onibus_id_fkey"
            columns: ["onibus_id"]
            isOneToOne: false
            referencedRelation: "onibus"
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
          passeio_id?: string
          valor?: number
          viagem_id?: string
        }
        Relationships: [
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
          status?: string | null
          updated_at?: string | null
          valor?: number
          viagem_id?: string
        }
        Relationships: [
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
          created_at: string | null
          data_ida: string
          data_jogo: string | null
          data_volta: string
          destino: string
          id: string
          local_jogo: string | null
          observacoes: string | null
          onibus_id: string | null
          preco_individual: number
          status_viagem: string | null
          tem_passeios: boolean | null
          updated_at: string | null
          vagas_disponiveis: number
          valor_padrao: number | null
        }
        Insert: {
          adversario?: string | null
          capacidade_onibus?: number | null
          created_at?: string | null
          data_ida: string
          data_jogo?: string | null
          data_volta: string
          destino: string
          id?: string
          local_jogo?: string | null
          observacoes?: string | null
          onibus_id?: string | null
          preco_individual: number
          status_viagem?: string | null
          tem_passeios?: boolean | null
          updated_at?: string | null
          vagas_disponiveis: number
          valor_padrao?: number | null
        }
        Update: {
          adversario?: string | null
          capacidade_onibus?: number | null
          created_at?: string | null
          data_ida?: string
          data_jogo?: string | null
          data_volta?: string
          destino?: string
          id?: string
          local_jogo?: string | null
          observacoes?: string | null
          onibus_id?: string | null
          preco_individual?: number
          status_viagem?: string | null
          tem_passeios?: boolean | null
          updated_at?: string | null
          vagas_disponiveis?: number
          valor_padrao?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "viagens_onibus_id_fkey"
            columns: ["onibus_id"]
            isOneToOne: false
            referencedRelation: "onibus"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
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
