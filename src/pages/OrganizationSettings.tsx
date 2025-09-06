import React from 'react';
import { OrganizationSettingsForm } from '@/components/organization/OrganizationSettingsForm';
import { useOrganization } from '@/hooks/useOrganization';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Building2 } from 'lucide-react';

const OrganizationSettings = () => {
  const { organization } = useOrganization();

  if (!organization) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-lg">Carregando organização...</div>
      </div>
    );
  }

  return (
    <div className="container mx-auto py-6 space-y-6">
      {/* Header com informações da organização */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Configurações</h1>
            <p className="text-muted-foreground">
              Gerencie as configurações da sua organização
            </p>
          </div>
          <Badge variant="secondary" className="flex items-center gap-2">
            <Building2 className="h-4 w-4" />
            {organization.name}
          </Badge>
        </div>

        {/* Card com informações básicas da organização */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Building2 className="h-5 w-5" />
              Informações da Organização
            </CardTitle>
            <CardDescription>
              Informações básicas da sua organização atual
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="space-y-2">
                <div className="text-sm font-medium text-muted-foreground">Nome</div>
                <div className="text-lg font-semibold">{organization.name}</div>
              </div>
              <div className="space-y-2">
                <div className="text-sm font-medium text-muted-foreground">Slug</div>
                <div className="text-lg font-mono bg-muted px-2 py-1 rounded">
                  {organization.slug}
                </div>
              </div>
              <div className="space-y-2">
                <div className="text-sm font-medium text-muted-foreground">ID</div>
                <div className="text-sm font-mono bg-muted px-2 py-1 rounded">
                  {organization.id}
                </div>
              </div>
            </div>

            {organization.logo_url && (
              <div className="mt-4 pt-4 border-t">
                <div className="text-sm font-medium text-muted-foreground mb-2">Logo Atual</div>
                <img
                  src={organization.logo_url}
                  alt={`Logo da ${organization.name}`}
                  className="w-20 h-20 object-contain border rounded-lg"
                />
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Formulário de configurações */}
      <OrganizationSettingsForm />
    </div>
  );
};

export default OrganizationSettings;