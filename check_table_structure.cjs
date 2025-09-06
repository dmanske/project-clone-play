const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkTableStructure() {
  try {
    console.log('Checking organization_settings table structure...');
    
    // Tentar fazer uma query simples para ver a estrutura
    const { data, error } = await supabase
      .from('organization_settings')
      .select('*')
      .limit(1);
    
    if (error) {
      console.error('Error querying organization_settings:', error);
    } else {
      console.log('Sample data from organization_settings:');
      console.log(data);
      
      if (data && data.length > 0) {
        console.log('\nColumns found in organization_settings:');
        console.log(Object.keys(data[0]));
      } else {
        console.log('No data found in organization_settings table');
      }
    }
    
    // Verificar se a tabela organizations existe
    const { data: orgData, error: orgError } = await supabase
      .from('organizations')
      .select('*')
      .limit(1);
    
    if (orgError) {
      console.error('\nError querying organizations:', orgError);
    } else {
      console.log('\nSample data from organizations:');
      console.log(orgData);
      
      if (orgData && orgData.length > 0) {
        console.log('\nColumns found in organizations:');
        console.log(Object.keys(orgData[0]));
      }
    }
    
  } catch (err) {
    console.error('Unexpected error:', err);
  }
}

checkTableStructure();