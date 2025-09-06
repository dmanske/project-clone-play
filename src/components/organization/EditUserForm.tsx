import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Checkbox } from '@/components/ui/checkbox';
import { useUserManagement, OrganizationUser } from '@/hooks/useUserManagement';
import { UserPermissions, ModulePermission, DEFAULT_PERMISSIONS, ADMIN_PERMISSIONS } from '@/types/multi-tenant';
import { toast } from 'sonner';

interface EditUserFormProps {
  user: OrganizationUser;
  onSuccess?: () => void;
  onCancel?: () => void;
}

const roleOptions = [
  { value: 'admin', label: 'Administrador' },
  { value: 'user', label: 'Usuário' },
  { value: 'viewer', label: 'Visualizador' },
] as const;

const moduleOptions = [
  { key: 'viagens', label: 'Viagens' },
  { key: 'clientes', label: 'Clientes' },
  { key: 'onibus', label: 'Ônibus' },
  { key: 'financeiro', label: 'Financeiro' },
  { key: 'relatorios', label: 'Relatórios' },
  { key: 'configuracoes', label: 'Configurações' },
  { key: 'usuarios', label: 'Usuários' },
] as const;

export function EditUserForm({ user, onSuccess, onCancel }: EditUserFormProps) {
  const [role, setRole] = useState<'owner' | 'admin' | 'user' | 'viewer'>(user.role);
  const [permissions, setPermissions] = useState<UserPermissions>(user.permissions || DEFAULT_PERMISSIONS);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { updateUser } = useUserManagement();

  useEffect(() => {
    setRole(user.role);
    setPermissions(user.permissions || DEFAULT_PERMISSIONS);
  }, [user]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    setIsSubmitting(true);
    
    try {
      // Only allow editing if not owner
      if (role !== 'owner') {
        const success = await updateUser(user.id, {
          role: role as 'admin' | 'user' | 'viewer',
          permissions,
        });
        
        if (success) {
          toast.success('Usuário atualizado com sucesso!');
          onSuccess?.();
        }
      } else {
        toast.error('Não é possível editar o proprietário da organização.');
      }
    } catch (error) {
      console.error('Erro ao atualizar usuário:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handlePermissionChange = (module: keyof UserPermissions, action: keyof ModulePermission, checked: boolean) => {
    setPermissions(prev => ({
      ...prev,
      [module]: {
        ...prev[module],
        [action]: checked,
      },
    }));
  };

  const handleRoleChange = (newRole: 'owner' | 'admin' | 'user' | 'viewer') => {
    setRole(newRole);
    
    // Set default permissions based on role
    let defaultPermissions: UserPermissions;
    if (newRole === 'admin') {
      defaultPermissions = ADMIN_PERMISSIONS;
    } else if (newRole === 'user') {
      defaultPermissions = {
        viagens: { read: true, write: true, delete: false },
        clientes: { read: true, write: true, delete: false },
        onibus: { read: true, write: false, delete: false },
        financeiro: { read: false, write: false, delete: false },
        relatorios: { read: true, write: false, delete: false },
        configuracoes: { read: false, write: false, delete: false },
        usuarios: { read: false, write: false, delete: false },
      };
    } else if (newRole === 'viewer') {
      defaultPermissions = DEFAULT_PERMISSIONS;
    } else {
      defaultPermissions = DEFAULT_PERMISSIONS;
    }
    
    setPermissions(defaultPermissions);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label>Usuário</Label>
        <div className="p-3 bg-gray-50 rounded-md">
          <div className="font-medium">{user.full_name || 'Nome não informado'}</div>
          <div className="text-sm text-gray-500">{user.email}</div>
        </div>
      </div>

      <div className="space-y-2">
        <Label htmlFor="role">Role</Label>
        <Select value={role} onValueChange={handleRoleChange}>
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
        <Label>Permissões por Módulo</Label>
        <div className="space-y-4">
          {moduleOptions.map((module) => (
            <div key={module.key} className="border rounded-lg p-4">
              <h4 className="font-medium mb-3">{module.label}</h4>
              <div className="grid grid-cols-3 gap-3">
                <div className="flex items-center space-x-2">
                  <Checkbox
                    id={`${module.key}-read`}
                    checked={permissions[module.key]?.read || false}
                    onCheckedChange={(checked) => 
                      handlePermissionChange(module.key, 'read', checked as boolean)
                    }
                  />
                  <Label
                    htmlFor={`${module.key}-read`}
                    className="text-sm font-normal cursor-pointer"
                  >
                    Visualizar
                  </Label>
                </div>
                <div className="flex items-center space-x-2">
                  <Checkbox
                    id={`${module.key}-write`}
                    checked={permissions[module.key]?.write || false}
                    onCheckedChange={(checked) => 
                      handlePermissionChange(module.key, 'write', checked as boolean)
                    }
                  />
                  <Label
                    htmlFor={`${module.key}-write`}
                    className="text-sm font-normal cursor-pointer"
                  >
                    Editar
                  </Label>
                </div>
                <div className="flex items-center space-x-2">
                  <Checkbox
                    id={`${module.key}-delete`}
                    checked={permissions[module.key]?.delete || false}
                    onCheckedChange={(checked) => 
                      handlePermissionChange(module.key, 'delete', checked as boolean)
                    }
                  />
                  <Label
                    htmlFor={`${module.key}-delete`}
                    className="text-sm font-normal cursor-pointer"
                  >
                    Excluir
                  </Label>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="flex justify-end space-x-2 pt-4">
        <Button
          type="button"
          variant="outline"
          onClick={onCancel}
          disabled={isSubmitting}
        >
          Cancelar
        </Button>
        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Salvando...' : 'Salvar Alterações'}
        </Button>
      </div>
    </form>
  );
}