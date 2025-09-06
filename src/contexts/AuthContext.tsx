
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
      console.log('Buscando perfil para usuário:', userId);
      
      // Buscar dados do usuário no auth como fallback
      const { data: { user } } = await supabase.auth.getUser();
      
      if (!user || user.id !== userId) {
        console.error('Usuário não encontrado no auth');
        return null;
      }

      // Tentar buscar perfil usando RPC ou query direta com fallback
      try {
        // Primeiro tentar com query direta usando any para contornar tipos
        const { data, error } = await (supabase as any)
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

        if (data && !error) {
          console.log('Perfil encontrado:', data);
          
          // Buscar organização se existir
          let organization = undefined;
          if (data.organization_id) {
            try {
              const { data: orgData } = await (supabase as any)
                .from('organizations')
                .select('*')
                .eq('id', data.organization_id)
                .single();
              
              if (orgData) {
                organization = {
                  id: orgData.id,
                  name: orgData.name,
                  slug: orgData.name?.toLowerCase().replace(/\s+/g, '-') || '',
                  logo_url: orgData.logo_url,
                  time_casa_padrao: orgData.time_casa_padrao,
                  cor_primaria: orgData.cor_primaria,
                  cor_secundaria: orgData.cor_secundaria
                };
              }
            } catch (orgError) {
              console.log('Erro ao buscar organização:', orgError);
            }
          }
          
          return {
            id: data.id || userId,
            email: data.email || user.email || '',
            full_name: data.full_name || user.user_metadata?.full_name || 'Usuário',
            role: data.role || 'user',
            permissions: data.permissions || {},
            active: data.active ?? true,
            organization_id: data.organization_id,
            organization
          };
        }
      } catch (dbError) {
        console.log('Erro ao buscar perfil no banco:', dbError);
      }

      // Se chegou até aqui, criar perfil básico com dados do auth
      console.log('Criando perfil básico com dados do auth');
      return {
        id: userId,
        email: user.email || '',
        full_name: user.user_metadata?.full_name || user.email?.split('@')[0] || 'Usuário',
        role: 'user',
        permissions: {},
        active: true
      };
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
          
          // Redirecionar apenas se estiver na página de login
          if (window.location.pathname === '/login') {
            navigate("/dashboard");
          }
        } else {
          setSession(null);
          setUser(null);
          setProfile(null);
        }
        
        setIsLoading(false);
      }
    );

    return () => subscription.unsubscribe();
  }, []); // ← Array vazio para evitar loops

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
        // Atualizar metadados do usuário no auth
        const { error: updateError } = await supabase.auth.updateUser({
          data: {
            full_name: nome,
            organization_id: organizationId || null,
            role: organizationId ? 'user' : 'admin'
          }
        });

        if (updateError) {
          console.error('Erro ao atualizar metadados:', updateError);
        }

        if (organizationId) {
          toast.success("Cadastro realizado com sucesso! Verifique seu email para confirmar a conta.");
          navigate("/login");
        } else {
          // Novo tenant - redirecionar para onboarding
          
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
      // Limpar estados locais ANTES do logout do Supabase
      setUser(null);
      setSession(null);
      setProfile(null);
      
      // Fazer logout no Supabase
      const { error } = await supabase.auth.signOut();
      if (error) {
        console.error('Erro no logout:', error);
        throw error;
      }
      
      // Limpar qualquer cache do localStorage relacionado ao Supabase
      const keys = Object.keys(localStorage);
      keys.forEach(key => {
        if (key.startsWith('supabase.auth.token') || key.startsWith('sb-')) {
          localStorage.removeItem(key);
        }
      });
      
      // Aguardar um pouco para garantir que o estado foi limpo
      await new Promise(resolve => setTimeout(resolve, 100));
      
      // Redirecionar para login
      navigate("/login");
    } catch (error) {
      console.error('Erro ao fazer logout:', error);
      // Mesmo com erro, limpar estados e redirecionar
      setUser(null);
      setSession(null);
      setProfile(null);
      navigate("/login");
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
