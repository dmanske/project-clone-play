import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import { toast } from 'sonner';
import { useAuth } from '@/contexts/AuthContext';
import { UserPermissions } from '@/types/multi-tenant';

export interface OrganizationUser {
  id: string;
  email: string;
  full_name: string;
  role: 'owner' | 'admin' | 'user' | 'viewer';
  organization_id: string;
  created_at: string;
  updated_at: string;
  permissions?: UserPermissions;
}

interface UserPermissionRecord {
  id: string;
  user_id: string;
  organization_id: string;
  permissions: UserPermissions;
  created_at: string;
  updated_at: string;
}

export interface UpdateUserData {
  role?: 'admin' | 'user' | 'viewer';
  permissions?: UserPermissions;
}

export function useUserManagement() {
  const [users, setUsers] = useState<OrganizationUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  // Removido useToast - usando toast do sonner diretamente
  const { profile } = useAuth();

  // Buscar usuários da organização
  const fetchUsers = async () => {
    if (!profile?.organization_id) return;

    try {
      setLoading(true);
      
      // Buscar usuários da organização
      const { data: profilesData, error: profilesError } = await supabase
        .from('profiles')
        .select('*')
        .eq('organization_id', profile.organization_id)
        .order('created_at', { ascending: false });

      if (profilesError) throw profilesError;

      // Buscar permissões dos usuários usando query SQL direta
      const userIds = profilesData?.map(p => p.id) || [];
      let permissionsData: UserPermissionRecord[] = [];
      
      if (userIds.length > 0) {
        const { data, error: permissionsError } = await supabase
          .rpc('get_user_permissions', { user_ids: userIds }) as { data: UserPermissionRecord[] | null, error: any };
        
        if (!permissionsError && data) {
          permissionsData = data;
        }
      }

      // Combinar dados
      const usersWithPermissions: OrganizationUser[] = profilesData?.map(profile => {
        const userPermissions = permissionsData?.find(p => p.user_id === profile.id);
        return {
          id: profile.id,
          email: profile.email || '',
          full_name: profile.full_name || '',
          role: (profile.role as 'owner' | 'admin' | 'user' | 'viewer') || 'user',
          organization_id: profile.organization_id || '',
          created_at: profile.created_at,
          updated_at: profile.updated_at,
          permissions: userPermissions?.permissions || undefined,
        };
      }) || [];

      setUsers(usersWithPermissions);
    } catch (error) {
      console.error('Erro ao buscar usuários:', error);
      toast.error('Não foi possível carregar os usuários.');
    } finally {
      setLoading(false);
    }
  };

  // Atualizar usuário
  const updateUser = async (userId: string, data: UpdateUserData) => {
    if (!profile?.organization_id) {
      toast.error('Usuário não autenticado ou sem organização.');
      return false;
    }

    try {
      setUpdating(true);

      // Atualizar role no perfil se fornecido
      if (data.role) {
        const { error: profileError } = await supabase
          .from('profiles')
          .update({ role: data.role })
          .eq('id', userId)
          .eq('organization_id', profile.organization_id);

        if (profileError) throw profileError;
      }

      // Atualizar permissões se fornecidas usando função SQL
      if (data.permissions) {
        const { error: permissionsError } = await supabase
          .rpc('upsert_user_permissions', {
            p_user_id: userId,
            p_organization_id: profile.organization_id,
            p_permissions: data.permissions,
          }) as { error: any };

        if (permissionsError) throw permissionsError;
      }

      toast.success('As informações do usuário foram atualizadas com sucesso.');

      // Recarregar a lista
      await fetchUsers();
      return true;
    } catch (error) {
      console.error('Erro ao atualizar usuário:', error);
      toast.error('Não foi possível atualizar o usuário.');
      return false;
    } finally {
      setUpdating(false);
    }
  };

  // Remover usuário da organização
  const removeUser = async (userId: string) => {
    if (!profile?.organization_id) {
      toast.error('Usuário não autenticado ou sem organização.');
      return false;
    }

    try {
      setUpdating(true);

      // Verificar se não é o próprio usuário
      if (userId === profile.id) {
        toast.error('Você não pode remover a si mesmo da organização.');
        return false;
      }

      // Verificar se não é o owner
      const user = users.find(u => u.id === userId);
      if (user?.role === 'owner') {
        toast.error('Não é possível remover o proprietário da organização.');
        return false;
      }

      // Remover permissões do usuário usando função SQL
      const { error: permissionsError } = await supabase
        .rpc('delete_user_permissions', {
          p_user_id: userId,
          p_organization_id: profile.organization_id,
        }) as { error: any };

      if (permissionsError) throw permissionsError;

      // Remover usuário da organização (definir organization_id como null)
      const { error: profileError } = await supabase
        .from('profiles')
        .update({ 
          organization_id: null,
          role: 'user' // Reset para role padrão
        })
        .eq('id', userId);

      if (profileError) throw profileError;

      toast.success('O usuário foi removido da organização com sucesso.');

      // Recarregar a lista
      await fetchUsers();
      return true;
    } catch (error) {
      console.error('Erro ao remover usuário:', error);
      toast.error('Não foi possível remover o usuário.');
      return false;
    } finally {
      setUpdating(false);
    }
  };

  // Buscar permissões de um usuário específico
  const getUserPermissions = async (userId: string): Promise<UserPermissions | null> => {
    if (!profile?.organization_id) return null;

    try {
      const { data, error } = await supabase
        .rpc('get_user_permissions_by_id', {
          p_user_id: userId,
          p_organization_id: profile.organization_id,
        }) as { data: UserPermissions | null, error: any };

      if (error) {
        console.error('Erro ao buscar permissões:', error);
        // Retornar permissões padrão em caso de erro
        return {
          viagens: { read: true, write: false, delete: false },
          clientes: { read: true, write: false, delete: false },
          onibus: { read: true, write: false, delete: false },
          financeiro: { read: false, write: false, delete: false },
          relatorios: { read: true, write: false, delete: false },
          configuracoes: { read: false, write: false, delete: false },
          usuarios: { read: false, write: false, delete: false },
        };
      }

      return data || {
        viagens: { read: true, write: false, delete: false },
        clientes: { read: true, write: false, delete: false },
        onibus: { read: true, write: false, delete: false },
        financeiro: { read: false, write: false, delete: false },
        relatorios: { read: true, write: false, delete: false },
        configuracoes: { read: false, write: false, delete: false },
        usuarios: { read: false, write: false, delete: false },
      };
    } catch (error) {
      console.error('Erro ao buscar permissões do usuário:', error);
      return null;
    }
  };

  // Verificar se o usuário atual pode gerenciar outros usuários
  const canManageUsers = () => {
    return profile?.role === 'owner' || profile?.role === 'admin';
  };

  // Verificar se pode editar um usuário específico
  const canEditUser = (targetUser: OrganizationUser) => {
    if (!canManageUsers()) return false;
    
    // Owner pode editar qualquer um exceto outros owners
    if (profile?.role === 'owner') {
      return targetUser.role !== 'owner' || targetUser.id === profile.id;
    }
    
    // Admin pode editar apenas users e viewers
    if (profile?.role === 'admin') {
      return ['user', 'viewer'].includes(targetUser.role);
    }
    
    return false;
  };

  // Verificar se pode remover um usuário específico
  const canRemoveUser = (targetUser: OrganizationUser) => {
    if (!canManageUsers()) return false;
    if (targetUser.id === profile?.id) return false; // Não pode remover a si mesmo
    if (targetUser.role === 'owner') return false; // Não pode remover owner
    
    // Owner pode remover qualquer um exceto owners
    if (profile?.role === 'owner') {
      return true;
    }
    
    // Admin pode remover apenas users e viewers
    if (profile?.role === 'admin') {
      return ['user', 'viewer'].includes(targetUser.role);
    }
    
    return false;
  };

  useEffect(() => {
    if (profile?.organization_id) {
      fetchUsers();
    }
  }, [profile?.organization_id]);

  return {
    users,
    loading,
    updating,
    updateUser,
    removeUser,
    getUserPermissions,
    canManageUsers,
    canEditUser,
    canRemoveUser,
    refetch: fetchUsers,
  };
}