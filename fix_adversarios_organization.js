// Script para corrigir a organização dos adversários
// Este script atualiza os adversários para a organização correta do usuário logado

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://your-project.supabase.co'; // Substitua pela sua URL
const supabaseKey = 'your-anon-key'; // Substitua pela sua chave

const supabase = createClient(supabaseUrl, supabaseKey);

async function fixAdversariosOrganization() {
  try {
    console.log('🔍 Verificando adversários...');
    
    // 1. Buscar todos os adversários
    const { data: adversarios, error: adversariosError } = await supabase
      .from('adversarios')
      .select('id, nome, organization_id');
    
    if (adversariosError) {
      console.error('❌ Erro ao buscar adversários:', adversariosError);
      return;
    }
    
    console.log(`📊 Encontrados ${adversarios.length} adversários`);
    
    // 2. Buscar a organização do usuário atual (GoFans Development)
    const targetOrganizationId = '9f3c25e8-7bef-49f3-8528-1f3dbadaea15';
    
    // 3. Atualizar adversários que não estão na organização correta
    const adversariosToUpdate = adversarios.filter(
      adv => adv.organization_id !== targetOrganizationId
    );
    
    if (adversariosToUpdate.length === 0) {
      console.log('✅ Todos os adversários já estão na organização correta!');
      return;
    }
    
    console.log(`🔄 Atualizando ${adversariosToUpdate.length} adversários...`);
    
    // 4. Atualizar cada adversário
    for (const adversario of adversariosToUpdate) {
      const { error: updateError } = await supabase
        .from('adversarios')
        .update({ organization_id: targetOrganizationId })
        .eq('id', adversario.id);
      
      if (updateError) {
        console.error(`❌ Erro ao atualizar ${adversario.nome}:`, updateError);
      } else {
        console.log(`✅ ${adversario.nome} atualizado com sucesso`);
      }
    }
    
    // 5. Verificar resultado
    const { data: adversariosAtualizados } = await supabase
      .from('adversarios')
      .select('id, nome, organization_id')
      .eq('organization_id', targetOrganizationId);
    
    console.log(`🎉 Resultado: ${adversariosAtualizados.length} adversários na organização GoFans Development`);
    
  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

// Executar o script
fixAdversariosOrganization();