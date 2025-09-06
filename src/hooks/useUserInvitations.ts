import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import { toast } from 'sonner';
import { useAuth } from '@/contexts/AuthContext';

export interface UserInvitation {
  id: string;
  organization_id: string;
  email: string;
  role: 'admin' | 'user' | 'viewer';
  invited_by: string;
  token: string;
  expires_at: string;
  accepted_at?: string;
  created_at: string;
  updated_at: string;
  invited_by_profile?: {
    full_name: string;
    email: string;
  };
}

export interface CreateInvitationData {
  email: string;
  role: 'admin' | 'user' | 'viewer';
}

export function useUserInvitations() {
  const [invitations, setInvitations] = useState<UserInvitation[]>([]);
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  // Removido useToast - usando toast do sonner diretamente
  const { user, profile } = useAuth();

  // Buscar convites da organização
  const fetchInvitations = async () => {
    if (!profile?.organization_id) return;

    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('user_invitations')
        .select(`
          *,
          invited_by_profile:profiles!user_invitations_invited_by_fkey(
            full_name,
            email
          )
        `)
        .eq('organization_id', profile.organization_id)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setInvitations(data || []);
    } catch (error) {
      console.error('Erro ao buscar convites:', error);
      toast.error('Não foi possível carregar os convites.');
    } finally {
      setLoading(false);
    }
  };

  // Criar novo convite
  const createInvitation = async (data: CreateInvitationData) => {
    if (!profile?.organization_id || !user?.id) {
      toast.error('Usuário não autenticado ou sem organização.');
      return false;
    }

    try {
      setCreating(true);

      // Verificar se já existe um convite pendente para este email
      const { data: existingInvitation } = await supabase
        .from('user_invitations')
        .select('id, accepted_at')
        .eq('organization_id', profile.organization_id)
        .eq('email', data.email)
        .is('accepted_at', null)
        .single();

      if (existingInvitation) {
        toast.error('Já existe um convite pendente para este email.');
        return false;
      }

      // Verificar se o usuário já está na organização
      const { data: existingUser } = await supabase
        .from('profiles')
        .select('id')
        .eq('email', data.email)
        .eq('organization_id', profile.organization_id)
        .single();

      if (existingUser) {
        toast.error('Este usuário já faz parte da organização.');
        return false;
      }

      // Criar o convite
      const { error } = await supabase
        .from('user_invitations')
        .insert({
          organization_id: profile.organization_id,
          email: data.email,
          role: data.role,
          invited_by: user.id,
        });

      if (error) throw error;

      toast.success(`Convite enviado para ${data.email} com sucesso.`);

      // Recarregar a lista
      await fetchInvitations();
      return true;
    } catch (error) {
      console.error('Erro ao criar convite:', error);
      toast.error('Não foi possível enviar o convite.');
      return false;
    } finally {
      setCreating(false);
    }
  };

  // Cancelar convite
  const cancelInvitation = async (invitationId: string) => {
    try {
      const { error } = await supabase
        .from('user_invitations')
        .delete()
        .eq('id', invitationId);

      if (error) throw error;

      toast.success('O convite foi cancelado com sucesso.');

      // Recarregar a lista
      await fetchInvitations();
      return true;
    } catch (error) {
      console.error('Erro ao cancelar convite:', error);
      toast.error('Não foi possível cancelar o convite.');
      return false;
    }
  };

  // Reenviar convite (atualizar token e data de expiração)
  const resendInvitation = async (invitationId: string) => {
    try {
      const { error } = await supabase
        .from('user_invitations')
        .update({
          token: null, // Será gerado automaticamente pelo trigger
          expires_at: null, // Será definido automaticamente pelo trigger
          updated_at: new Date().toISOString(),
        })
        .eq('id', invitationId);

      if (error) throw error;

      toast.success('O convite foi reenviado com sucesso.');

      // Recarregar a lista
      await fetchInvitations();
      return true;
    } catch (error) {
      console.error('Erro ao reenviar convite:', error);
      toast.error('Não foi possível reenviar o convite.');
      return false;
    }
  };

  // Aceitar convite (usado na página de aceitação)
  const acceptInvitation = async (token: string) => {
    try {
      // Buscar o convite pelo token
      const { data: invitation, error: fetchError } = await supabase
        .from('user_invitations')
        .select('*')
        .eq('token', token)
        .is('accepted_at', null)
        .gt('expires_at', new Date().toISOString())
        .single();

      if (fetchError || !invitation) {
        throw new Error('Convite inválido ou expirado');
      }

      // Verificar se o usuário atual tem o mesmo email do convite
      if (user?.email !== invitation.email) {
        throw new Error('Este convite não é para o usuário atual');
      }

      // Atualizar o perfil do usuário com a organização e role
      const { error: updateError } = await supabase
        .from('profiles')
        .update({
          organization_id: invitation.organization_id,
          role: invitation.role,
        })
        .eq('id', user.id);

      if (updateError) throw updateError;

      // Marcar o convite como aceito
      const { error: acceptError } = await supabase
        .from('user_invitations')
        .update({
          accepted_at: new Date().toISOString(),
        })
        .eq('id', invitation.id);

      if (acceptError) throw acceptError;

      toast.success('Você foi adicionado à organização com sucesso.');

      return true;
    } catch (error) {
      console.error('Erro ao aceitar convite:', error);
      toast.error(error instanceof Error ? error.message : 'Não foi possível aceitar o convite.');
      return false;
    }
  };

  // Verificar se um convite é válido
  const validateInvitation = async (token: string) => {
    try {
      const { data, error } = await supabase
        .from('user_invitations')
        .select(`
          *,
          organization:organizations(name)
        `)
        .eq('token', token)
        .is('accepted_at', null)
        .gt('expires_at', new Date().toISOString())
        .single();

      if (error || !data) {
        return null;
      }

      return data;
    } catch (error) {
      console.error('Erro ao validar convite:', error);
      return null;
    }
  };

  useEffect(() => {
    if (profile?.organization_id) {
      fetchInvitations();
    }
  }, [profile?.organization_id]);

  return {
    invitations,
    loading,
    creating,
    createInvitation,
    cancelInvitation,
    resendInvitation,
    acceptInvitation,
    validateInvitation,
    refetch: fetchInvitations,
  };
}