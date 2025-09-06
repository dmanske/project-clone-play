import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { OnboardingWizard } from '@/components/onboarding/OnboardingWizard';
import { useAuth } from '@/contexts/AuthContext';
import { Card, CardContent } from '@/components/ui/card';
import { Loader2 } from 'lucide-react';

export const Onboarding: React.FC = () => {
  const navigate = useNavigate();
  const { user, profile, isLoading } = useAuth();

  useEffect(() => {
    // Verificar se o usuário está logado
    if (!isLoading && !user) {
      navigate('/login');
      return;
    }

    // Verificar se o onboarding já foi concluído
    const onboardingCompleted = localStorage.getItem('onboarding_completed');
    if (onboardingCompleted === 'true') {
      navigate('/dashboard');
      return;
    }

    // Verificar se o usuário já tem uma organização configurada
    if (!isLoading && profile?.organization_id) {
      // Se já tem organização, pode pular para o dashboard
      // Mas vamos permitir que complete o onboarding se quiser
    }
  }, [user, profile, isLoading, navigate]);

  const handleOnboardingComplete = (data: any) => {
    console.log('Onboarding completed with data:', data);
    // O wizard já redireciona para o dashboard
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <Card className="w-full max-w-md">
          <CardContent className="p-8 text-center">
            <Loader2 className="w-8 h-8 animate-spin mx-auto mb-4 text-blue-600" />
            <h2 className="text-lg font-semibold mb-2">Carregando...</h2>
            <p className="text-gray-600">Preparando seu onboarding</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (!user) {
    return null; // Será redirecionado para login
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-4xl mx-auto px-4 py-6">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-gray-900">
              Configuração Inicial
            </h1>
            <p className="text-gray-600 mt-2">
              Vamos configurar sua conta em alguns passos simples
            </p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-4xl mx-auto px-4 py-8">
        <OnboardingWizard onComplete={handleOnboardingComplete} />
      </div>

      {/* Footer */}
      <div className="bg-white border-t border-gray-200 mt-12">
        <div className="max-w-4xl mx-auto px-4 py-6">
          <div className="text-center text-sm text-gray-500">
            <p>
              Precisa de ajuda? Entre em contato com nosso suporte técnico.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Onboarding;