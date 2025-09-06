import React from 'react';
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
import { useUserInvitations } from '@/hooks/useUserInvitations';
import { UserInvitation } from '@/hooks/useUserInvitations';

// Extend UserInvitation to include status
interface UserInvitationWithStatus extends UserInvitation {
  status: 'pending' | 'accepted' | 'expired' | 'cancelled';
}
import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { Mail, Clock, CheckCircle, XCircle, RotateCcw } from 'lucide-react';

interface UserInvitationsListProps {
  organizationId?: string;
}

export function UserInvitationsList({ organizationId }: UserInvitationsListProps) {
  const {
    invitations,
    loading,
    resendInvitation,
    cancelInvitation,
    refetch,
  } = useUserInvitations();

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return (
          <Badge variant="outline" className="text-yellow-600 border-yellow-600">
            <Clock className="w-3 h-3 mr-1" />
            Pendente
          </Badge>
        );
      case 'accepted':
        return (
          <Badge variant="outline" className="text-green-600 border-green-600">
            <CheckCircle className="w-3 h-3 mr-1" />
            Aceito
          </Badge>
        );
      case 'expired':
        return (
          <Badge variant="outline" className="text-red-600 border-red-600">
            <XCircle className="w-3 h-3 mr-1" />
            Expirado
          </Badge>
        );
      case 'cancelled':
        return (
          <Badge variant="outline" className="text-gray-600 border-gray-600">
            <XCircle className="w-3 h-3 mr-1" />
            Cancelado
          </Badge>
        );
      default:
        return (
          <Badge variant="outline">
            {status}
          </Badge>
        );
    }
  };

  const getRoleBadge = (role: string) => {
    const roleColors = {
      owner: 'bg-purple-100 text-purple-800',
      admin: 'bg-blue-100 text-blue-800',
      user: 'bg-green-100 text-green-800',
      viewer: 'bg-gray-100 text-gray-800',
    };

    const roleLabels = {
      owner: 'Proprietário',
      admin: 'Administrador',
      user: 'Usuário',
      viewer: 'Visualizador',
    };

    return (
      <Badge className={roleColors[role as keyof typeof roleColors] || 'bg-gray-100 text-gray-800'}>
        {roleLabels[role as keyof typeof roleLabels] || role}
      </Badge>
    );
  };

  const handleResend = async (invitationId: string) => {
    await resendInvitation(invitationId);
    refetch();
  };

  const handleCancel = async (invitationId: string) => {
    await cancelInvitation(invitationId);
    refetch();
  };

  // Helper function to determine invitation status
  const getInvitationStatus = (invitation: UserInvitation): 'pending' | 'accepted' | 'expired' | 'cancelled' => {
    if (invitation.accepted_at) return 'accepted';
    if (new Date(invitation.expires_at) < new Date()) return 'expired';
    return 'pending';
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!invitations || invitations.length === 0) {
    return (
      <div className="text-center p-8 text-gray-500">
        <Mail className="w-12 h-12 mx-auto mb-4 text-gray-400" />
        <p>Nenhum convite encontrado</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold">Convites Pendentes</h3>
        <Button
          variant="outline"
          size="sm"
          onClick={refetch}
          disabled={loading}
        >
          <RotateCcw className="w-4 h-4 mr-2" />
          Atualizar
        </Button>
      </div>

      <div className="border rounded-lg">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Email</TableHead>
              <TableHead>Função</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Enviado</TableHead>
              <TableHead>Expira em</TableHead>
              <TableHead className="text-right">Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {invitations.map((invitation: UserInvitation) => (
              <TableRow key={invitation.id}>
                <TableCell className="font-medium">
                  {invitation.email}
                </TableCell>
                <TableCell>
                  {getRoleBadge(invitation.role)}
                </TableCell>
                <TableCell>
                  {getStatusBadge(getInvitationStatus(invitation))}
                </TableCell>
                <TableCell>
                  {invitation.created_at
                    ? formatDistanceToNow(new Date(invitation.created_at), {
                        addSuffix: true,
                        locale: ptBR,
                      })
                    : '-'
                  }
                </TableCell>
                <TableCell>
                  {invitation.expires_at
                    ? formatDistanceToNow(new Date(invitation.expires_at), {
                        addSuffix: true,
                        locale: ptBR,
                      })
                    : '-'
                  }
                </TableCell>
                <TableCell className="text-right">
                  <div className="flex items-center justify-end space-x-2">
                    {getInvitationStatus(invitation) === 'pending' && (
                      <>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => handleResend(invitation.id)}
                        >
                          <Mail className="w-4 h-4 mr-1" />
                          Reenviar
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => handleCancel(invitation.id)}
                          className="text-red-600 hover:text-red-700"
                        >
                          <XCircle className="w-4 h-4 mr-1" />
                          Cancelar
                        </Button>
                      </>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}