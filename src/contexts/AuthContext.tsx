
import React, { createContext, useState, useEffect, useContext } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import type { User, Session } from "@supabase/supabase-js";

// Tipos para o perfil do usuário
interface UserProfile {
  id: string;
  organization_id?: string;
  email: string;
  full_name: string;
  avatar_url?: string;
  role: string;
  permissions: any;
  active: boolean;
  organization?: {
    id: string;
    name: string;
    slug: string;
    logo_url?: string;
    time_casa_padrao?: string;
    cor_primaria?: string;
    cor_secundaria?: string;
  };
}

interface AuthContextType {
  user: User | null;
  session: Session | null;
  profile: UserProfile | null;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, nome: string, organizationId?: string) => Promise<void>;
  signOut: () => Promise<void>;
  isLoading: boolean;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();

  // Função para buscar o perfil do usuário
  const fetchUserProfile = async (userId: string): Promise<UserProfile | null> => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select(`
          *,
          organization:organizations(
            id,
            name,
            logo_url,
            time_casa_padrao,
            cor_primaria,
            cor_secundaria
          )
        `)
        .eq('id', userId)
        .single();

      if (error) {
        console.error('Erro ao buscar perfil:', error);
        return null;
      }

      // Garantir que as propriedades obrigatórias existam
      const profile: UserProfile = {
        ...data,
        permissions: (data as any).permissions || {},
        active: (data as any).active ?? true,
        organization: data.organization ? {
          ...data.organization,
          slug: data.organization.name?.toLowerCase().replace(/\s+/g, '-') || ''
        } : undefined
      };

      return profile;
    } catch (error) {
      console.error('Erro ao buscar perfil:', error);
      return null;
    }
  };

  const refreshProfile = async () => {
    if (user) {
      const userProfile = await fetchUserProfile(user.id);
      setProfile(userProfile);
    }
  };

  useEffect(() => {
    // Verificar sessão atual
    const checkSession = async () => {
      try {
        const { data: { session }, error } = await supabase.auth.getSession();
        
        if (error) {
          console.error('Erro ao verificar sessão:', error);
          setIsLoading(false);
          return;
        }

        if (session) {
          setSession(session);
          setUser(session.user);
          
          // Buscar perfil do usuário
          const userProfile = await fetchUserProfile(session.user.id);
          setProfile(userProfile);
          
          if (location.pathname === '/login') {
            navigate("/dashboard");
          }
        }
      } catch (error) {
        console.error('Erro ao verificar sessão:', error);
      } finally {
        setIsLoading(false);
      }
    };

    checkSession();

    // Escutar mudanças de autenticação
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        console.log('Auth state changed:', event, session);
        
        if (session) {
          setSession(session);
          setUser(session.user);
          
          // Buscar perfil do usuário
          const userProfile = await fetchUserProfile(session.user.id);
          setProfile(userProfile);
        } else {
          setSession(null);
          setUser(null);
          setProfile(null);
        }
        
        setIsLoading(false);
      }
    );

    return () => subscription.unsubscribe();
  }, [navigate, location.pathname]);

  const signIn = async (email: string, password: string) => {
    try {
      setIsLoading(true);
      
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        throw error;
      }

      if (data.user) {
        // Buscar perfil do usuário
        const userProfile = await fetchUserProfile(data.user.id);
        
        if (!userProfile) {
          throw new Error('Perfil de usuário não encontrado');
        }
        
        if (!userProfile.active) {
          throw new Error('Usuário inativo. Entre em contato com o administrador.');
        }
        
        setProfile(userProfile);
      }

      toast.success("Login realizado com sucesso!");
      navigate("/dashboard");
    } catch (error: any) {
      console.error("Erro ao fazer login:", error);
      toast.error(error.message || "Erro ao fazer login. Tente novamente.");
    } finally {
      setIsLoading(false);
    }
  };

  const signUp = async (email: string, password: string, nome: string, organizationId?: string) => {
    try {
      setIsLoading(true);
      
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: nome,
          }
        }
      });

      if (error) {
        throw error;
      }

      if (data.user) {
        if (organizationId) {
          // Criar perfil do usuário para organização existente
          const { error: profileError } = await supabase
            .from('profiles')
            .insert({
              id: data.user.id,
              email: email,
              full_name: nome,
              organization_id: organizationId,
              role: 'user',
              active: true
            });

          if (profileError) {
            console.error('Erro ao criar perfil:', profileError);
          }
          
          toast.success("Cadastro realizado com sucesso! Verifique seu email para confirmar a conta.");
          navigate("/login");
        } else {
          // Novo tenant - criar perfil básico e redirecionar para onboarding
          const { error: profileError } = await supabase
            .from('profiles')
            .insert({
              id: data.user.id,
              email: email,
              full_name: nome,
              role: 'admin',
              active: true
            });

          if (profileError) {
            console.error('Erro ao criar perfil:', profileError);
          }
          
          toast.success("Cadastro realizado com sucesso! Verifique seu email e complete a configuração.");
          navigate("/onboarding");
        }
      }
    } catch (error: any) {
      console.error("Erro ao cadastrar:", error);
      toast.error(error.message || "Erro ao cadastrar. Tente novamente.");
    } finally {
      setIsLoading(false);
    }
  };

  const signOut = async () => {
    try {
      setIsLoading(true);
      
      const { error } = await supabase.auth.signOut();
      
      if (error) {
        throw error;
      }
      
      setUser(null);
      setSession(null);
      setProfile(null);

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
    <AuthContext.Provider value={{ user, session, profile, signIn, signUp, signOut, isLoading, refreshProfile }}>
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
