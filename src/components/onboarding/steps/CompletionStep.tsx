import React from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { CheckCircle, ArrowRight, Users, Calendar, Settings, BarChart3 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

interface CompletionStepProps {
  onComplete: (data: any) => void;
  data?: any;
  allData?: any;
}

const nextSteps = [
  {
    icon: Users,
    title: 'Cadastrar Passageiros',
    description: 'Comece adicionando seus primeiros passageiros ao sistema',
    action: 'Ir para Passageiros',
    route: '/passageiros'
  },
  {
    icon: Calendar,
    title: 'Criar Primeira Viagem',
    description: 'Configure sua primeira viagem ou evento',
    action: 'Criar Viagem',
    route: '/viagens/nova'
  },
  {
    icon: Settings,
    title: 'Personalizar Configurações',
    description: 'Ajuste as configurações avançadas da sua organização',
    action: 'Ver Configurações',
    route: '/configuracoes'
  },
  {
    icon: BarChart3,
    title: 'Explorar Relatórios',
    description: 'Conheça os relatórios disponíveis para sua gestão',
    action: 'Ver Relatórios',
    route: '/relatorios'
  }
];

export const CompletionStep: React.FC<CompletionStepProps> = ({ onComplete, data, allData }) => {
  const navigate = useNavigate();

  const handleFinishOnboarding = () => {
    // Marcar onboarding como concluído
    localStorage.setItem('onboarding_completed', 'true');
    
    onComplete({
      completed: true,
      completedAt: new Date().toISOString(),
    });

    // Redirecionar para o dashboard
    navigate('/dashboard');
  };

  const handleQuickAction = (route: string) => {
    // Marcar onboarding como concluído antes de navegar
    localStorage.setItem('onboarding_completed', 'true');
    navigate(route);
  };

  const getCompletedSteps = () => {
    const steps = [];
    if (allData?.welcome) steps.push('Boas-vindas');
    if (allData?.organization) steps.push('Configuração da Organização');
    if (allData?.user) steps.push('Perfil do Usuário');
    if (allData?.trial) steps.push('Período Trial');
    return steps;
  };

  return (
    <div className="space-y-6">
      {/* Success Header */}
      <div className="text-center">
        <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <CheckCircle className="w-12 h-12 text-green-600" />
        </div>
        <h2 className="text-3xl font-bold text-gray-900 mb-2">
          Parabéns! 🎉
        </h2>
        <p className="text-xl text-gray-600 mb-4">
          Sua conta foi configurada com sucesso!
        </p>
        <p className="text-gray-600 max-w-2xl mx-auto">
          Você completou todos os passos necessários para começar a usar o sistema. 
          Agora você pode explorar todas as funcionalidades e começar a gerenciar 
          suas caravanas de forma eficiente.
        </p>
      </div>

      {/* Setup Summary */}
      <Card className="bg-green-50 border-green-200">
        <CardContent className="p-6">
          <h3 className="text-lg font-semibold text-green-900 mb-4">
            Configuração Concluída
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {allData?.organization && (
              <div className="space-y-2">
                <h4 className="font-medium text-green-800">Organização</h4>
                <div className="text-sm text-green-700">
                  <p><span className="font-medium">Nome:</span> {allData.organization.name}</p>
                  <p><span className="font-medium">Slug:</span> {allData.organization.slug}</p>
                  {allData.organization.email && (
                    <p><span className="font-medium">Email:</span> {allData.organization.email}</p>
                  )}
                </div>
              </div>
            )}
            
            {allData?.user && (
              <div className="space-y-2">
                <h4 className="font-medium text-green-800">Administrador</h4>
                <div className="text-sm text-green-700">
                  <p><span className="font-medium">Nome:</span> {allData.user.full_name}</p>
                  <p><span className="font-medium">Papel:</span> {allData.user.role}</p>
                  {allData.user.phone && (
                    <p><span className="font-medium">Telefone:</span> {allData.user.phone}</p>
                  )}
                </div>
              </div>
            )}
          </div>
          
          <div className="mt-4 pt-4 border-t border-green-200">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-green-800">Status do Trial:</span>
              <Badge className="bg-green-100 text-green-800 border-green-300">
                Ativo - 30 dias restantes
              </Badge>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Next Steps */}
      <Card>
        <CardContent className="p-6">
          <h3 className="text-lg font-semibold mb-4">
            Próximos Passos Recomendados
          </h3>
          <p className="text-gray-600 mb-6">
            Escolha uma das opções abaixo para começar a usar o sistema:
          </p>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {nextSteps.map((step, index) => {
              const Icon = step.icon;
              return (
                <div 
                  key={index} 
                  className="border rounded-lg p-4 hover:border-blue-300 hover:bg-blue-50 transition-colors cursor-pointer group"
                  onClick={() => handleQuickAction(step.route)}
                >
                  <div className="flex items-start space-x-3">
                    <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center group-hover:bg-blue-200 transition-colors">
                      <Icon className="w-5 h-5 text-blue-600" />
                    </div>
                    <div className="flex-1">
                      <h4 className="font-medium text-gray-900 mb-1">
                        {step.title}
                      </h4>
                      <p className="text-sm text-gray-600 mb-3">
                        {step.description}
                      </p>
                      <div className="flex items-center text-sm text-blue-600 group-hover:text-blue-700">
                        <span>{step.action}</span>
                        <ArrowRight className="w-4 h-4 ml-1" />
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Support Information */}
      <Card className="bg-blue-50 border-blue-200">
        <CardContent className="p-6">
          <h3 className="text-lg font-semibold text-blue-900 mb-3">
            Precisa de Ajuda?
          </h3>
          <div className="space-y-2 text-sm text-blue-800">
            <p>• Acesse nossa documentação completa no sistema</p>
            <p>• Entre em contato com nosso suporte técnico</p>
            <p>• Explore os tutoriais disponíveis em cada seção</p>
            <p>• Lembre-se: você tem 30 dias de trial para explorar tudo!</p>
          </div>
        </CardContent>
      </Card>

      {/* Action Buttons */}
      <div className="flex flex-col sm:flex-row gap-4 justify-center">
        <Button 
          onClick={handleFinishOnboarding}
          size="lg" 
          className="px-8"
        >
          Ir para Dashboard
        </Button>
        <Button 
          onClick={() => handleQuickAction('/passageiros')}
          variant="outline" 
          size="lg" 
          className="px-8"
        >
          Começar com Passageiros
        </Button>
      </div>

      {/* Completed Steps Summary */}
      <div className="text-center">
        <p className="text-sm text-gray-500">
          Passos concluídos: {getCompletedSteps().join(', ')}
        </p>
      </div>
    </div>
  );
};