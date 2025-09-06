import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Checkbox } from '@/components/ui/checkbox';
import { useUserInvitations, CreateInvitationData } from '@/hooks/useUserInvitations';
import { toast } from 'sonner';

interface InviteUserFormProps {
  onSuccess?: () => void;
}

interface FormData extends CreateInvitationData {
  permissions: Record<string, boolean>;
}

const roleOptions = [
  { value: 'admin', label: 'Administrador' },
  { value: 'user', label: 'Usuário' },
  { value: 'viewer', label: 'Visualizador' },
] as const;

const permissionOptions = [
  { key: 'can_manage_users', label: 'Gerenciar usuários' },
  { key: 'can_manage_settings', label: 'Gerenciar configurações' },
  { key: 'can_view_reports', label: 'Visualizar relatórios' },
  { key: 'can_manage_finances', label: 'Gerenciar financeiro' },
  { key: 'can_manage_clients', label: 'Gerenciar clientes' },
  { key: 'can_manage_trips', label: 'Gerenciar viagens' },
  { key: 'can_manage_buses', label: 'Gerenciar ônibus' },
];

export function InviteUserForm({ onSuccess }: InviteUserFormProps) {
  const [formData, setFormData] = useState<FormData>({
    email: '',
    role: 'user',
    permissions: {},
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { createInvitation } = useUserInvitations();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.email.trim()) {
      toast.error('Email é obrigatório');
      return;
    }

    if (!formData.role) {
      toast.error('Role é obrigatório');
      return;
    }

    setIsSubmitting(true);
    
    try {
      const success = await createInvitation(formData);
      if (success) {
        toast.success('Convite enviado com sucesso!');
        setFormData({ email: '', role: 'user', permissions: {} });
        onSuccess?.();
      }
    } catch (error) {
      console.error('Erro ao enviar convite:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handlePermissionChange = (permission: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      permissions: {
        ...prev.permissions,
        [permission]: checked,
      },
    }));
  };

  const handleRoleChange = (role: 'admin' | 'user' | 'viewer') => {
    setFormData(prev => ({ ...prev, role }));
    
    // Set default permissions based on role
    let defaultPermissions: Record<string, boolean> = {};
    if (role === 'admin') {
      defaultPermissions = {
        can_manage_users: true,
        can_manage_settings: true,
        can_view_reports: true,
        can_manage_finances: true,
        can_manage_clients: true,
        can_manage_trips: true,
        can_manage_buses: true,
      };
    } else if (role === 'user') {
      defaultPermissions = {
        can_view_reports: true,
        can_manage_clients: true,
        can_manage_trips: true,
      };
    } else if (role === 'viewer') {
      defaultPermissions = {
        can_view_reports: true,
      };
    }
    
    setFormData(prev => ({ ...prev, permissions: defaultPermissions }));
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          type="email"
          value={formData.email}
          onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
          placeholder="usuario@exemplo.com"
          required
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="role">Role</Label>
        <Select value={formData.role} onValueChange={handleRoleChange}>
          <SelectTrigger>
            <SelectValue placeholder="Selecione um role" />
          </SelectTrigger>
          <SelectContent>
            {roleOptions.map((option) => (
              <SelectItem key={option.value} value={option.value}>
                {option.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="space-y-3">
        <Label>Permissões</Label>
        <div className="grid grid-cols-1 gap-3">
          {permissionOptions.map((permission) => (
            <div key={permission.key} className="flex items-center space-x-2">
              <Checkbox
                id={permission.key}
                checked={formData.permissions[permission.key] || false}
                onCheckedChange={(checked) => 
                  handlePermissionChange(permission.key, checked as boolean)
                }
              />
              <Label
                htmlFor={permission.key}
                className="text-sm font-normal cursor-pointer"
              >
                {permission.label}
              </Label>
            </div>
          ))}
        </div>
      </div>

      <div className="flex justify-end space-x-2 pt-4">
        <Button
          type="button"
          variant="outline"
          onClick={() => onSuccess?.()}
          disabled={isSubmitting}
        >
          Cancelar
        </Button>
        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Enviando...' : 'Enviar Convite'}
        </Button>
      </div>
    </form>
  );
}