-- =====================================================
-- MIGRAÇÃO: empresa_config → organization_settings
-- =====================================================
-- Este script migra os dados da tabela empresa_config para organization_settings
-- garantindo que cada organização tenha suas configurações editáveis

-- =====================================================
-- 1. VERIFICAR ESTRUTURAS EXISTENTES
-- =====================================================

-- Verificar se empresa_config existe
SELECT 
    'empresa_config' as tabela,
    COUNT(*) as registros
FROM empresa_config;

-- Verificar se organization_settings existe
SELECT 
    'organization_settings' as tabela,
    COUNT(*) as registros
FROM organization_settings;

-- Verificar organizações existentes
SELECT 
    'organizations' as tabela,
    COUNT(*) as registros
FROM organizations;

-- =====================================================
-- 2. MIGRAR DADOS PARA ORGANIZATION_SETTINGS
-- =====================================================

-- Para cada organização, criar configurações baseadas em empresa_config
INSERT INTO organization_settings (
    organization_id,
    
    -- Branding e Visual
    logo_empresa_url,
    cor_primaria,
    cor_secundaria,
    
    -- Informações da Empresa
    nome_empresa,
    endereco_completo,
    telefone,
    email_contato,
    site_url,
    cnpj,
    
    -- Configurações de Notificações
    whatsapp_numero,
    
    -- Configurações Regionais (padrões)
    timezone,
    moeda,
    idioma,
    formato_data,
    
    -- Configurações de Pagamento (padrões)
    aceita_pix,
    aceita_cartao,
    aceita_dinheiro,
    taxa_cartao,
    
    -- Configurações de Relatórios (padrões)
    incluir_logo_relatorios
)
SELECT 
    o.id as organization_id,
    
    -- Branding e Visual
    ec.logo_url as logo_empresa_url,
    '#000000' as cor_primaria, -- Padrão
    '#ffffff' as cor_secundaria, -- Padrão
    
    -- Informações da Empresa
    COALESCE(ec.nome, ec.nome_fantasia, o.name) as nome_empresa,
    CONCAT_WS(', ', ec.endereco, ec.cidade, ec.estado, ec.cep) as endereco_completo,
    ec.telefone,
    ec.email as email_contato,
    ec.site as site_url,
    ec.cnpj,
    
    -- Configurações de Notificações
    ec.whatsapp as whatsapp_numero,
    
    -- Configurações Regionais (padrões brasileiros)
    'America/Sao_Paulo' as timezone,
    'BRL' as moeda,
    'pt-BR' as idioma,
    'DD/MM/YYYY' as formato_data,
    
    -- Configurações de Pagamento (padrões)
    true as aceita_pix,
    true as aceita_cartao,
    true as aceita_dinheiro,
    0 as taxa_cartao,
    
    -- Configurações de Relatórios (padrões)
    true as incluir_logo_relatorios
    
FROM organizations o
CROSS JOIN (
    SELECT * FROM empresa_config 
    WHERE ativo = true 
    LIMIT 1
) ec
WHERE NOT EXISTS (
    SELECT 1 FROM organization_settings os 
    WHERE os.organization_id = o.id
);

-- =====================================================
-- 3. VERIFICAR MIGRAÇÃO
-- =====================================================

-- Verificar se todas as organizações têm configurações
SELECT 
    o.name as organizacao,
    o.id as organization_id,
    CASE 
        WHEN os.id IS NOT NULL THEN '✅ Configurado'
        ELSE '❌ Sem configurações'
    END as status,
    os.nome_empresa,
    os.email_contato,
    os.telefone
FROM organizations o
LEFT JOIN organization_settings os ON o.id = os.organization_id
ORDER BY o.name;

-- =====================================================
-- 4. DADOS PARA TESTE
-- =====================================================

-- Mostrar exemplo de configurações migradas
SELECT 
    'Exemplo de configurações migradas:' as info;
    
SELECT 
    os.nome_empresa,
    os.cnpj,
    os.email_contato,
    os.telefone,
    os.whatsapp_numero,
    os.endereco_completo,
    os.site_url,
    os.logo_empresa_url,
    os.cor_primaria,
    os.cor_secundaria,
    os.timezone,
    os.moeda
FROM organization_settings os
LIMIT 3;

-- =====================================================
-- 5. PRÓXIMOS PASSOS
-- =====================================================

/*
APÓS EXECUTAR ESTA MIGRAÇÃO:

1. ✅ Cada organização terá suas próprias configurações em organization_settings
2. ✅ Os dados da empresa_config foram preservados e adaptados
3. ✅ Configurações padrão foram aplicadas onde necessário

PRÓXIMOS PASSOS:

1. 🔄 Testar a interface de configurações organizacionais
2. 🔄 Verificar se os clientes conseguem editar suas configurações
3. 🔄 Adaptar componentes que ainda usam empresa_config
4. 🔄 Implementar validações específicas por organização
5. 🔄 Configurar backup automático das configurações

COMPONENTES A ADAPTAR:
- EmpresaConfig.tsx → usar organization_settings
- useEmpresa.ts → usar useOrganizationSettings
- Relatórios que usam dados da empresa

TABELA empresa_config:
- ⚠️  Pode ser mantida para compatibilidade temporária
- ⚠️  Ou removida após confirmação de que tudo funciona
*/

-- Verificação final
SELECT 
    'Migração concluída! Verifique os resultados acima.' as status,
    COUNT(*) as organizacoes_configuradas
FROM organization_settings;