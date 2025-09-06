import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkOrganizationSettings() {
  console.log('🔍 Verificando estrutura da tabela organization_settings...');
  
  try {
    // Tentar buscar dados da tabela para ver a estrutura
    const { data, error } = await supabase
      .from('organization_settings')
      .select('*')
      .limit(1);
    
    if (error) {
      console.error('❌ Erro ao acessar organization_settings:', error.message);
      
      // Se a tabela não existir, vamos verificar se existe alguma tabela similar
      console.log('\n🔍 Verificando tabelas disponíveis...');
      const { data: tables, error: tablesError } = await supabase.rpc('get_tables');
      
      if (tablesError) {
        console.log('Não foi possível listar tabelas automaticamente.');
      } else {
        console.log('Tabelas encontradas:', tables);
      }
    } else {
      console.log('✅ Tabela organization_settings encontrada!');
      console.log('📊 Estrutura dos dados:');
      
      if (data && data.length > 0) {
        console.log('Colunas disponíveis:', Object.keys(data[0]));
        console.log('Exemplo de dados:', data[0]);
      } else {
        console.log('Tabela existe mas está vazia.');
        
        // Tentar inserir um registro de teste para ver quais colunas são aceitas
        console.log('\n🧪 Testando inserção para descobrir estrutura...');
        const { error: insertError } = await supabase
          .from('organization_settings')
          .insert({ test: 'test' });
        
        if (insertError) {
          console.log('Erro de inserção (isso nos ajuda a entender a estrutura):');
          console.log(insertError.message);
        }
      }
    }
    
    // Verificar se existe tabela organizations
    console.log('\n🔍 Verificando tabela organizations...');
    const { data: orgData, error: orgError } = await supabase
      .from('organizations')
      .select('*')
      .limit(1);
    
    if (orgError) {
      console.error('❌ Erro ao acessar organizations:', orgError.message);
    } else {
      console.log('✅ Tabela organizations encontrada!');
      if (orgData && orgData.length > 0) {
        console.log('Colunas da organizations:', Object.keys(orgData[0]));
      }
    }
    
  } catch (err) {
    console.error('❌ Erro geral:', err.message);
  }
}

checkOrganizationSettings();