
import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { TenantProtection } from "./TenantProtection";
import { useEffect, useState } from "react";

export const ProtectedRoute = () => {
  const { user, isLoading, session, profile } = useAuth();
  const [shouldRedirect, setShouldRedirect] = useState(false);
  
  // Verificar se deve redirecionar após um delay para evitar flickers
  useEffect(() => {
    if (!isLoading && !user && !session) {
      const timer = setTimeout(() => {
        setShouldRedirect(true);
      }, 100); // Pequeno delay para evitar redirecionamentos prematuros
      
      return () => clearTimeout(timer);
    } else {
      setShouldRedirect(false);
    }
  }, [user, session, isLoading]);
  
  // Enquanto está carregando, mostrar loading
  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto mb-2"></div>
          <p className="text-gray-600">Carregando...</p>
        </div>
      </div>
    );
  }
  
  // Se deve redirecionar (após verificação), redirecionar para login
  if (shouldRedirect || (!isLoading && !user)) {
    return <Navigate to="/login" replace />;
  }

  // Se o usuário está logado mas não tem organização, redirecionar para onboarding
  if (user && profile && !profile.organization_id) {
    return <Navigate to="/onboarding" replace />;
  }

  // Se estiver logado, protege com verificação de tenant
  return (
    <TenantProtection 
      requireActive={true}
      fallback={
        <div className="flex justify-center items-center h-screen">
          <div className="text-center space-y-4">
            <div className="text-red-600">
              <p className="text-lg font-semibold">Erro de Autenticação</p>
              <p className="text-sm text-gray-600">Não foi possível carregar os dados da organização.</p>
            </div>
            <button 
              onClick={() => window.location.href = '/login'}
              className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              Fazer Login Novamente
            </button>
          </div>
        </div>
      }
    >
      <Outlet />
    </TenantProtection>
  );
};
