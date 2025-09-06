import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { CheckCircle, Circle, ArrowRight, ArrowLeft } from 'lucide-react';
import {
  WelcomeStep,
  OrganizationSetupStep,
  UserSetupStep,
  TrialInfoStep,
  CompletionStep
} from './steps';

interface OnboardingWizardProps {
  onComplete: (data?: any) => void;
}

interface StepConfig {
  id: string;
  title: string;
  description: string;
  component: React.ComponentType<any>;
  required: boolean;
}

const ONBOARDING_STEPS: StepConfig[] = [
  {
    id: 'welcome',
    title: 'Bem-vindo',
    description: 'Introdução ao sistema',
    component: WelcomeStep,
    required: true
  },
  {
    id: 'organization',
    title: 'Configurar Organização',
    description: 'Informações básicas da sua empresa',
    component: OrganizationSetupStep,
    required: true
  },
  {
    id: 'user',
    title: 'Perfil do Usuário',
    description: 'Configurar seu perfil de administrador',
    component: UserSetupStep,
    required: true
  },
  {
    id: 'trial',
    title: 'Período Trial',
    description: 'Informações sobre seu período de teste',
    component: TrialInfoStep,
    required: false
  },
  {
    id: 'completion',
    title: 'Concluído',
    description: 'Setup finalizado com sucesso',
    component: CompletionStep,
    required: true
  }
];

export const OnboardingWizard: React.FC<OnboardingWizardProps> = ({ onComplete }) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [completedSteps, setCompletedSteps] = useState<Set<string>>(new Set());
  const [stepData, setStepData] = useState<Record<string, any>>({});

  const currentStepConfig = ONBOARDING_STEPS[currentStep];
  const progress = ((currentStep + 1) / ONBOARDING_STEPS.length) * 100;

  const handleStepComplete = (stepId: string, data: any) => {
    setCompletedSteps(prev => new Set([...prev, stepId]));
    setStepData(prev => ({ ...prev, [stepId]: data }));
  };

  const handleNext = () => {
    if (currentStep < ONBOARDING_STEPS.length - 1) {
      setCurrentStep(prev => prev + 1);
    } else {
      onComplete();
    }
  };

  const handlePrevious = () => {
    if (currentStep > 0) {
      setCurrentStep(prev => prev - 1);
    }
  };

  const canProceed = () => {
    const step = ONBOARDING_STEPS[currentStep];
    return !step.required || completedSteps.has(step.id);
  };

  const StepComponent = currentStepConfig.component;

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="w-full max-w-4xl">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Configuração Inicial
          </h1>
          <p className="text-gray-600">
            Vamos configurar sua organização em alguns passos simples
          </p>
        </div>

        {/* Progress Bar */}
        <div className="mb-8">
          <div className="flex justify-between items-center mb-4">
            <span className="text-sm font-medium text-gray-700">
              Passo {currentStep + 1} de {ONBOARDING_STEPS.length}
            </span>
            <span className="text-sm text-gray-500">
              {Math.round(progress)}% concluído
            </span>
          </div>
          <Progress value={progress} className="h-2" />
        </div>

        {/* Steps Navigation */}
        <div className="flex justify-center mb-8">
          <div className="flex items-center space-x-4">
            {ONBOARDING_STEPS.map((step, index) => {
              const isCompleted = completedSteps.has(step.id);
              const isCurrent = index === currentStep;
              const isPast = index < currentStep;
              
              return (
                <div key={step.id} className="flex items-center">
                  <div className="flex flex-col items-center">
                    <div className={`
                      w-10 h-10 rounded-full flex items-center justify-center border-2 transition-colors
                      ${
                        isCompleted || isPast
                          ? 'bg-green-500 border-green-500 text-white'
                          : isCurrent
                          ? 'bg-blue-500 border-blue-500 text-white'
                          : 'bg-white border-gray-300 text-gray-400'
                      }
                    `}>
                      {isCompleted || isPast ? (
                        <CheckCircle className="w-5 h-5" />
                      ) : (
                        <Circle className="w-5 h-5" />
                      )}
                    </div>
                    <span className={`
                      text-xs mt-2 text-center max-w-20
                      ${
                        isCurrent
                          ? 'text-blue-600 font-medium'
                          : isCompleted || isPast
                          ? 'text-green-600'
                          : 'text-gray-400'
                      }
                    `}>
                      {step.title}
                    </span>
                  </div>
                  {index < ONBOARDING_STEPS.length - 1 && (
                    <ArrowRight className="w-4 h-4 text-gray-300 mx-2 mt-[-20px]" />
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Main Content */}
        <Card className="shadow-lg">
          <CardHeader>
            <CardTitle className="text-xl">
              {currentStepConfig.title}
            </CardTitle>
            <CardDescription>
              {currentStepConfig.description}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <StepComponent
              onComplete={(data: any) => handleStepComplete(currentStepConfig.id, data)}
              data={stepData[currentStepConfig.id]}
              allData={stepData}
            />
          </CardContent>
        </Card>

        {/* Navigation Buttons */}
        <div className="flex justify-between mt-8">
          <Button
            variant="outline"
            onClick={handlePrevious}
            disabled={currentStep === 0}
            className="flex items-center gap-2"
          >
            <ArrowLeft className="w-4 h-4" />
            Anterior
          </Button>
          
          <Button
            onClick={handleNext}
            disabled={!canProceed()}
            className="flex items-center gap-2"
          >
            {currentStep === ONBOARDING_STEPS.length - 1 ? 'Finalizar' : 'Próximo'}
            <ArrowRight className="w-4 h-4" />
          </Button>
        </div>
      </div>
    </div>
  );
};