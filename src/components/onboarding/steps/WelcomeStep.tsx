import React from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Rocket, Users, Settings, BarChart3 } from 'lucide-react';

interface WelcomeStepProps {
  onComplete: (data: any) => void;
  data?: any;
}

const features = [
  {
    icon: Users,
    title: 'Gestão de Passageiros',
    description: 'Controle completo de clientes e passageiros'
  },
  {
    icon: BarChart3,
    title: 'Relatórios Detalhados',
    description: 'Acompanhe o desempenho do seu negócio'
  },
  {
    icon: Settings,
    title: 'Configurações Flexíveis',
    description: 'Personalize o sistema conforme suas necessidades'
  },
  {
    icon: Rocket,
    title: 'Período Trial',
    description: '30 dias gratuitos para testar todas as funcionalidades'
  }
];

export const WelcomeStep: React.FC<WelcomeStepProps> = ({ onComplete }) => {
  const handleContinue = () => {
    onComplete({ welcomed: true, timestamp: new Date().toISOString() });
  };

  return (
    <div className="space-y-6">
      <div className="text-center">
        <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Rocket className="w-10 h-10 text-blue-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Bem-vindo ao Sistema de Gestão de Caravanas!
        </h2>
        <p className="text-gray-600 max-w-2xl mx-auto">
          Você está prestes a configurar sua organização em nosso sistema completo de gestão. 
          Em poucos minutos, você terá acesso a todas as ferramentas necessárias para 
          gerenciar suas viagens e passageiros de forma eficiente.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {features.map((feature, index) => {
          const Icon = feature.icon;
          return (
            <Card key={index} className="border-l-4 border-l-blue-500">
              <CardContent className="p-4">
                <div className="flex items-start space-x-3">
                  <div className="w-10 h-10 bg-blue-50 rounded-lg flex items-center justify-center flex-shrink-0">
                    <Icon className="w-5 h-5 text-blue-600" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-1">
                      {feature.title}
                    </h3>
                    <p className="text-sm text-gray-600">
                      {feature.description}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex items-start space-x-3">
          <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
            <span className="text-blue-600 font-bold text-sm">!</span>
          </div>
          <div>
            <h4 className="font-semibold text-blue-900 mb-1">
              Período Trial de 30 Dias
            </h4>
            <p className="text-sm text-blue-700">
              Você terá acesso completo a todas as funcionalidades por 30 dias. 
              Após esse período, você poderá escolher um plano que melhor se adequa às suas necessidades.
            </p>
          </div>
        </div>
      </div>

      <div className="text-center">
        <Button onClick={handleContinue} size="lg" className="px-8">
          Vamos Começar!
        </Button>
      </div>
    </div>
  );
};