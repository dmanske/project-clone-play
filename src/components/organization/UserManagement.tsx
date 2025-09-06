import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { MoreHorizontal, Plus, UserPlus, Mail, Shield, Trash2 } from 'lucide-react';
import { useUserManagement, OrganizationUser } from '@/hooks/useUserManagement';
import { useUserInvitations } from '@/hooks/useUserInvitations';
import { InviteUserForm } from './InviteUserForm';
import { EditUserForm } from './EditUserForm';
import { UserInvitationsList } from './UserInvitationsList';
import { toast } from 'sonner';

const roleLabels = {
  owner: 'Proprietário',
  admin: 'Administrador',
  user: 'Usuário',
  viewer: 'Visualizador',
};

const roleColors = {
  owner: 'bg-purple-100 text-purple-800',
  admin: 'bg-blue-100 text-blue-800',
  user: 'bg-green-100 text-green-800',
  viewer: 'bg-gray-100 text-gray-800',
};

export function UserManagement() {
  const [showInviteDialog, setShowInviteDialog] = useState(false);
  const [showEditDialog, setShowEditDialog] = useState(false);
  const [selectedUser, setSelectedUser] = useState<OrganizationUser | null>(null);
  const [activeTab, setActiveTab] = useState<'users' | 'invitations'>('users');

  const {
    users,
    loading,
    updating,
    removeUser,
    canManageUsers,
    canEditUser,
    canRemoveUser,
    refetch,
  } = useUserManagement();

  const { invitations, loading: invitationsLoading } = useUserInvitations();

  const handleRemoveUser = async (user: OrganizationUser) => {
    if (!confirm(`Tem certeza que deseja remover ${user.full_name || user.email} da organização?`)) {
      return;
    }

    const success = await removeUser(user.id);
    if (success) {
      toast.success('Usuário removido com sucesso.');
    }
  };

  const handleEditUser = (user: OrganizationUser) => {
    setSelectedUser(user);
    setShowEditDialog(true);
  };

  const handleEditSuccess = () => {
    setShowEditDialog(false);
    setSelectedUser(null);
    refetch();
  };

  const handleInviteSuccess = () => {
    setShowInviteDialog(false);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando usuários...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">Gestão de Usuários</h2>
          <p className="text-muted-foreground">
            Gerencie usuários e convites da sua organização
          </p>
        </div>
        {canManageUsers() && (
          <Dialog open={showInviteDialog} onOpenChange={setShowInviteDialog}>
            <DialogTrigger asChild>
              <Button>
                <UserPlus className="mr-2 h-4 w-4" />
                Convidar Usuário
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Convidar Novo Usuário</DialogTitle>
                <DialogDescription>
                  Envie um convite para adicionar um novo usuário à sua organização.
                </DialogDescription>
              </DialogHeader>
              <InviteUserForm onSuccess={handleInviteSuccess} />
            </DialogContent>
          </Dialog>
        )}
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => setActiveTab('users')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'users'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            <Shield className="mr-2 h-4 w-4 inline" />
            Usuários ({users.length})
          </button>
          <button
            onClick={() => setActiveTab('invitations')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'invitations'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            <Mail className="mr-2 h-4 w-4 inline" />
            Convites ({invitations.length})
          </button>
        </nav>
      </div>

      {/* Content */}
      {activeTab === 'users' && (
        <Card>
          <CardHeader>
            <CardTitle>Usuários da Organização</CardTitle>
            <CardDescription>
              Lista de todos os usuários que fazem parte da sua organização.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {users.length === 0 ? (
              <div className="text-center py-8">
                <Shield className="mx-auto h-12 w-12 text-gray-400" />
                <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum usuário</h3>
                <p className="mt-1 text-sm text-gray-500">
                  Comece convidando usuários para sua organização.
                </p>
                {canManageUsers() && (
                  <div className="mt-6">
                    <Button onClick={() => setShowInviteDialog(true)}>
                      <UserPlus className="mr-2 h-4 w-4" />
                      Convidar Primeiro Usuário
                    </Button>
                  </div>
                )}
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Usuário</TableHead>
                    <TableHead>Role</TableHead>
                    <TableHead>Data de Criação</TableHead>
                    {canManageUsers() && <TableHead className="w-[70px]">Ações</TableHead>}
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {users.map((user) => (
                    <TableRow key={user.id}>
                      <TableCell>
                        <div>
                          <div className="font-medium">{user.full_name || 'Nome não informado'}</div>
                          <div className="text-sm text-gray-500">{user.email}</div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge className={roleColors[user.role]}>
                          {roleLabels[user.role]}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        {new Date(user.created_at).toLocaleDateString('pt-BR')}
                      </TableCell>
                      {canManageUsers() && (
                        <TableCell>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" className="h-8 w-8 p-0">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              {canEditUser(user) && (
                                <DropdownMenuItem onClick={() => handleEditUser(user)}>
                                  Editar
                                </DropdownMenuItem>
                              )}
                              {canRemoveUser(user) && (
                                <DropdownMenuItem
                                  onClick={() => handleRemoveUser(user)}
                                  className="text-red-600"
                                >
                                  <Trash2 className="mr-2 h-4 w-4" />
                                  Remover
                                </DropdownMenuItem>
                              )}
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      )}
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>
      )}

      {activeTab === 'invitations' && (
        <UserInvitationsList />
      )}

      {/* Edit User Dialog */}
      <Dialog open={showEditDialog} onOpenChange={setShowEditDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Editar Usuário</DialogTitle>
            <DialogDescription>
              Altere as permissões e role do usuário.
            </DialogDescription>
          </DialogHeader>
          {selectedUser && (
            <EditUserForm
              user={selectedUser}
              onSuccess={handleEditSuccess}
              onCancel={() => setShowEditDialog(false)}
            />
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}