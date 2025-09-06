import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Calendar, Clock, CreditCard, CheckCircle, Star } from 'lucide-react';

interface TrialInfoStepProps {
  onComplete: (data: any) => void;
  data?: any;
  allData?: any;
}

const features = [
  {
    icon: CheckCircle,
    title: 'Gestão Completa de Passageiros',
    description: 'Cadastro, edição e controle de todos os passageiros'
  },
  {
    icon: CheckCircle,
    title: 'Organização de Viagens',
    description: 'Planejamento e gestão completa de viagens e eventos'
  },
  {
    icon: CheckCircle,
    title: 'Relatórios Detalhados',
    description: 'Relatórios financeiros e operacionais em tempo real'
  },
  {
    icon: CheckCircle,
    title: 'Configurações Personalizadas',
    description: 'Branding personalizado e configurações flexíveis'
  },
  {
    icon: CheckCircle,
    title: 'Suporte Técnico',
    description: 'Suporte completo durante todo o período trial'
  }
];

export const TrialInfoStep: React.FC<TrialInfoStepProps> = ({ onComplete, data, allData }) => {
  const [isLoading, setIsLoading] = useState(false);
  
  // Simular informações do trial por enquanto
  const trialInfo = {
    status: 'TRIAL',
    trial_start: new Date().toISOString(),
    trial_end: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 dias
  };

  const handleContinue = () => {
    onComplete({
      trialActivated: true,
      trialInfo,
      timestamp: new Date().toISOString(),
    });
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
  };

  const getDaysRemaining = () => {
    if (!trialInfo?.trial_end) return 30;
    const today = new Date();
    const trialEnd = new Date(trialInfo.trial_end);
    const diffTime = trialEnd.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return Math.max(0, diffDays);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="text-center">
        <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Star className="w-10 h-10 text-green-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Período Trial Ativado!
        </h2>
        <p className="text-gray-600 max-w-2xl mx-auto">
          Você tem acesso completo a todas as funcionalidades do sistema por 30 dias, 
          totalmente gratuito. Explore todas as ferramentas e veja como podemos 
          ajudar a transformar sua gestão de caravanas.
        </p>
      </div>

      {/* Trial Status Card */}
      <Card className="border-green-200 bg-green-50">
        <CardContent className="p-6">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center space-x-3">
              <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                <Calendar className="w-6 h-6 text-green-600" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-green-900">
                  Período Trial
                </h3>
                <p className="text-sm text-green-700">
                  Acesso completo por 30 dias
                </p>
              </div>
            </div>
            <Badge variant="secondary" className="bg-green-100 text-green-800">
              {trialInfo?.status || 'TRIAL'}
            </Badge>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="text-center p-3 bg-white rounded-lg">
              <Clock className="w-5 h-5 text-green-600 mx-auto mb-1" />
              <p className="text-sm font-medium text-gray-900">
                {getDaysRemaining()} dias restantes
              </p>
              <p className="text-xs text-gray-500">do período trial</p>
            </div>
            <div className="text-center p-3 bg-white rounded-lg">
              <Calendar className="w-5 h-5 text-green-600 mx-auto mb-1" />
              <p className="text-sm font-medium text-gray-900">
                Início: {formatDate(trialInfo.trial_start)}
              </p>
              <p className="text-xs text-gray-500">data de ativação</p>
            </div>
            <div className="text-center p-3 bg-white rounded-lg">
              <CreditCard className="w-5 h-5 text-green-600 mx-auto mb-1" />
              <p className="text-sm font-medium text-gray-900">
                Fim: {formatDate(trialInfo.trial_end)}
              </p>
              <p className="text-xs text-gray-500">sem cobrança até lá</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Features Included */}
      <Card>
        <CardContent className="p-6">
          <h3 className="text-lg font-semibold mb-4">O que está incluído no seu trial:</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div key={index} className="flex items-start space-x-3">
                  <Icon className="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium text-gray-900">
                      {feature.title}
                    </h4>
                    <p className="text-sm text-gray-600">
                      {feature.description}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Next Steps */}
      <Card className="bg-blue-50 border-blue-200">
        <CardContent className="p-6">
          <h3 className="text-lg font-semibold text-blue-900 mb-3">
            Próximos Passos
          </h3>
          <div className="space-y-2 text-sm text-blue-800">
            <p>• Explore todas as funcionalidades do sistema</p>
            <p>• Configure suas viagens e cadastre passageiros</p>
            <p>• Personalize as configurações da sua organização</p>
            <p>• Entre em contato conosco se tiver dúvidas</p>
            <p>• Antes do fim do trial, escolha um plano que atenda suas necessidades</p>
          </div>
        </CardContent>
      </Card>

      {/* Organization Summary */}
      {allData?.organization && (
        <Card className="bg-gray-50">
          <CardContent className="p-6">
            <h3 className="text-lg font-semibold mb-4">Resumo da Configuração</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              <div>
                <span className="font-medium text-gray-700">Organização:</span>
                <span className="ml-2">{allData.organization.name}</span>
              </div>
              <div>
                <span className="font-medium text-gray-700">Administrador:</span>
                <span className="ml-2">{allData.user?.full_name}</span>
              </div>
              <div>
                <span className="font-medium text-gray-700">Status:</span>
                <span className="ml-2">
                  <Badge variant="secondary" className="bg-green-100 text-green-800">
                    Trial Ativo
                  </Badge>
                </span>
              </div>
              <div>
                <span className="font-medium text-gray-700">Dias restantes:</span>
                <span className="ml-2">{getDaysRemaining()} dias</span>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      <div className="text-center">
        <Button onClick={handleContinue} size="lg" className="px-8">
          Continuar para Finalização
        </Button>
      </div>
    </div>
  );
};