
import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { TenantProtection } from "./TenantProtection";

export const ProtectedRoute = () => {
  const { user, isLoading } = useAuth();
  
  // Enquanto está carregando, não toma nenhuma decisão
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
  
  // Se não estiver logado, redireciona para a página de login
  if (!user) {
    return <Navigate to="/login" replace />;
  }
  
  // Se estiver logado, protege com verificação de tenant
  return (
    <TenantProtection>
      <Outlet />
    </TenantProtection>
  );
};
