
import React, { createContext, useState, useEffect, useContext } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { toast } from "sonner";

// Tipos básicos para substituir os do Supabase
interface User {
  id: string;
  email?: string;
  user_metadata?: any;
}

interface Session {
  user: User;
  access_token: string;
}

interface AuthContextType {
  user: User | null;
  session: Session | null;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, nome: string) => Promise<void>;
  signOut: () => Promise<void>;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    // Simula verificação de sessão sem Supabase
    const checkSession = () => {
      const savedSession = localStorage.getItem('mock_session');
      if (savedSession) {
        try {
          const session = JSON.parse(savedSession);
          setSession(session);
          setUser(session.user);
          
          if (location.pathname === '/login') {
            navigate("/dashboard");
          }
        } catch (error) {
          localStorage.removeItem('mock_session');
        }
      }
      setIsLoading(false);
    };

    checkSession();
  }, [navigate, location.pathname]);

  const signIn = async (email: string, password: string) => {
    try {
      setIsLoading(true);
      
      // Simula login - aceita qualquer email/senha para desenvolvimento
      const mockUser: User = {
        id: '1',
        email: email,
        user_metadata: { nome: 'Usuário Teste' }
      };
      
      const mockSession: Session = {
        user: mockUser,
        access_token: 'mock_token'
      };
      
      // Salva no localStorage
      localStorage.setItem('mock_session', JSON.stringify(mockSession));
      
      setUser(mockUser);
      setSession(mockSession);

      toast.success("Login realizado com sucesso!");
      navigate("/dashboard");
    } catch (error: any) {
      console.error("Erro ao fazer login:", error);
      toast.error("Erro ao fazer login. Tente novamente.");
    } finally {
      setIsLoading(false);
    }
  };

  const signUp = async (email: string, password: string, nome: string) => {
    try {
      setIsLoading(true);
      
      // Simula cadastro
      toast.success("Cadastro realizado com sucesso! Por favor, faça login.");
      navigate("/login");
    } catch (error: any) {
      console.error("Erro ao cadastrar:", error);
      toast.error("Erro ao cadastrar. Tente novamente.");
    } finally {
      setIsLoading(false);
    }
  };

  const signOut = async () => {
    try {
      setIsLoading(true);
      
      // Remove sessão do localStorage
      localStorage.removeItem('mock_session');
      
      setUser(null);
      setSession(null);

      toast.success("Logout realizado com sucesso!");
      navigate("/login");
    } catch (error: any) {
      console.error("Erro ao fazer logout:", error);
      toast.error("Erro ao fazer logout.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AuthContext.Provider value={{ user, session, signIn, signUp, signOut, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  
  if (context === undefined) {
    throw new Error("useAuth deve ser usado dentro de um AuthProvider");
  }
  
  return context;
};
