// Script to diagnose Supabase schema cache issues
// This helps resolve "Could not find column in schema cache" errors

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = "https://uflozqxlbkkqaghmzsyt.supabase.co";
const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVmbG96cXhsYmtrcWFnaG16c3l0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY3Njg3NzksImV4cCI6MjA3MjM0NDc3OX0.0WOHzhG_g9LGSAhxI0MGGJZ0qhK-4ry-uvNGrAJo-IE";

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function diagnoseSchemaIssue() {
  try {
    console.log('🔍 Diagnosing Supabase schema cache issue...');
    console.log('📋 Testing clientes table access...');
    
    // Test 1: Try to query the table structure
    const { data: tableData, error: tableError } = await supabase
      .from('clientes')
      .select('*')
      .limit(1);
    
    if (tableError) {
      console.error('❌ Error querying clientes table:', tableError.message);
      
      if (tableError.message.includes('fonte_cadastro')) {
        console.log('\n🎯 DIAGNOSIS: Schema cache issue with fonte_cadastro column');
        console.log('\n🔧 SOLUTIONS:');
        console.log('1. The column exists in the database but Supabase cache is outdated');
        console.log('2. Try restarting your development server');
        console.log('3. Check Supabase dashboard for pending schema changes');
        console.log('4. Run the SQL script: fix_fonte_cadastro_cache_issue.sql');
        console.log('5. If using local Supabase, restart with: npx supabase stop && npx supabase start');
      }
    } else {
      console.log('✅ Successfully queried clientes table');
      if (tableData && tableData.length > 0) {
        const columns = Object.keys(tableData[0]);
        console.log('📊 Available columns:', columns.join(', '));
        
        if (columns.includes('fonte_cadastro')) {
          console.log('✅ fonte_cadastro column is available in the response');
          console.log('\n🎯 The column exists and is accessible!');
          console.log('\n💡 If you\'re still getting errors, try:');
          console.log('1. Clear your browser cache');
          console.log('2. Restart your development server');
          console.log('3. Check if you\'re using the correct Supabase client instance');
        } else {
          console.log('❌ fonte_cadastro column is missing from the response');
        }
      } else {
        console.log('ℹ️ Table is empty, cannot check column structure');
      }
    }
    
    // Test 2: Try a simple insert to test the schema
    console.log('\n🧪 Testing insert operation (this will likely fail due to RLS)...');
    const testData = {
      nome: 'Cache Test',
      cpf: '00000000000',
      data_nascimento: '1990-01-01',
      telefone: '11999999999',
      email: 'cache.test@example.com',
      cep: '01234567',
      endereco: 'Test Address',
      numero: '123',
      bairro: 'Test Neighborhood',
      cidade: 'Test City',
      estado: 'SP',
      como_conheceu: 'Test',
      fonte_cadastro: 'admin'
    };
    
    const { data: insertData, error: insertError } = await supabase
      .from('clientes')
      .insert([testData])
      .select();
    
    if (insertError) {
      if (insertError.message.includes('fonte_cadastro')) {
        console.error('❌ Insert failed due to fonte_cadastro column:', insertError.message);
        console.log('\n🎯 CONFIRMED: Schema cache issue with fonte_cadastro');
      } else if (insertError.message.includes('RLS') || insertError.message.includes('policy')) {
        console.log('ℹ️ Insert failed due to RLS policy (expected)');
        console.log('✅ But the schema structure seems correct');
      } else {
        console.error('❌ Insert failed for other reason:', insertError.message);
      }
    } else {
      console.log('✅ Insert test successful (unexpected but good!)');
    }
    
    console.log('\n📋 SUMMARY:');
    console.log('- Check the console output above for specific error messages');
    console.log('- If fonte_cadastro errors persist, run the SQL fix script');
    console.log('- Consider restarting your development environment');
    
  } catch (error) {
    console.error('💥 Unexpected error:', error.message);
  }
}

diagnoseSchemaIssue();