import { useState, useCallback } from 'react';
import { supabase } from '@/lib/supabase';
import { useTenant } from '@/contexts/TenantContext';

interface Cliente {
  id: string;
  nome: string;
  telefone?: string;
  email?: string;
  cpf?: string;
  data_nascimento?: string;
  created_at: string;
}

export function useClientes() {
  const [clientes, setClientes] = useState<Cliente[]>([]);
  const [carregando, setCarregando] = useState(false);
  const { tenant } = useTenant();

  // Função para buscar clientes
  const buscarClientes = useCallback(async (limite?: number) => {
    if (!tenant?.organization.id) {
      setClientes([]);
      return;
    }

    setCarregando(true);

    try {
      let query = supabase
        .from('clientes')
        .select('id, nome, telefone, email, cpf, data_nascimento, created_at')
        .eq('organization_id', tenant.organization.id)
        .order('nome');

      if (limite) {
        query = query.limit(limite);
      }

      const { data, error } = await query;

      if (error) {
        console.error('Erro ao buscar clientes:', error);
        return;
      }

      setClientes(data || []);
    } catch (error) {
      console.error('Erro inesperado ao buscar clientes:', error);
    } finally {
      setCarregando(false);
    }
  }, [tenant?.organization.id]);

  // Função para buscar cliente por ID
  const buscarClientePorId = useCallback(async (id: string): Promise<Cliente | null> => {
    if (!tenant?.organization.id) {
      return null;
    }

    try {
      const { data, error } = await supabase
        .from('clientes')
        .select('*')
        .eq('id', id)
        .eq('organization_id', tenant.organization.id)
        .single();

      if (error) {
        console.error('Erro ao buscar cliente:', error);
        return null;
      }

      return data;
    } catch (error) {
      console.error('Erro inesperado ao buscar cliente:', error);
      return null;
    }
  }, []);

  return {
    clientes,
    carregando,
    buscarClientes,
    buscarClientePorId
  };
}