# Resultados da Comparação de Tabelas

Este arquivo contém os resultados da execução do script `compare_tables_structure.sql` para comparar as estruturas de tabelas entre o projeto original e o projeto multi-tenant.

## 📊 Resumo Executivo

| Métrica | Projeto Original | Projeto Multi-tenant | Status |
|---------|------------------|---------------------|--------|
| **Total de Tabelas** | 55 tabelas | 25 tabelas | ⚠️ 30 tabelas faltando |
| **Tabelas com Dados** | 7 tabelas (940 clientes) | 1 tabela (1 empresa) | ❌ Migração pendente |
| **Multi-tenant Ready** | 0 tabelas | 9 tabelas | ✅ Core implementado |
| **Funcionalidades** | Sistema completo | Core básico | 🔄 Expansão necessária |

### 🎯 Principais Descobertas:
- ✅ **Sucesso:** Core multi-tenant funcional com 9 tabelas principais
- ❌ **Gap:** 46 tabelas críticas não migradas (financeiro, créditos, produtos, games)
- 📊 **Dados:** 940 clientes no original vs. dados vazios no multi-tenant
- 🔒 **Segurança:** Todas as tabelas migradas possuem isolamento por `organization_id`

## Como usar
1. Execute o script `compare_tables_structure.sql` no banco de dados do projeto original
2. Copie os resultados aqui para análise
3. Execute o mesmo script no banco multi-tenant para comparação

## Resultados do Projeto Original
| table_name                        | table_type | status_tabela       |
| --------------------------------- | ---------- | ------------------- |
| adversarios                       | BASE TABLE | ORIGINAL            |
| categorias_financeiras            | BASE TABLE | ORIGINAL            |
| categorias_produtos               | BASE TABLE | ORIGINAL            |
| cliente_creditos                  | BASE TABLE | ORIGINAL            |
| clientes                          | BASE TABLE | ORIGINAL            |
| contas_pagar                      | BASE TABLE | ORIGINAL            |
| credito_historico                 | BASE TABLE | ORIGINAL            |
| credito_logs                      | BASE TABLE | ORIGINAL            |
| credito_viagem_vinculacoes        | BASE TABLE | ORIGINAL            |
| despesas                          | BASE TABLE | ORIGINAL            |
| empresa_config                    | BASE TABLE | ORIGINAL            |
| game_buses                        | BASE TABLE | ORIGINAL            |
| games                             | BASE TABLE | ORIGINAL            |
| historico_pagamentos_categorizado | BASE TABLE | ORIGINAL            |
| historico_pagamentos_ingressos    | BASE TABLE | ORIGINAL            |
| ingressos                         | BASE TABLE | ORIGINAL            |
| lista_presenca                    | BASE TABLE | ORIGINAL            |
| onibus                            | BASE TABLE | ORIGINAL            |
| onibus_images                     | BASE TABLE | ORIGINAL            |
| parcela_alertas                   | BASE TABLE | ORIGINAL            |
| parcela_historico                 | BASE TABLE | ORIGINAL            |
| passageiro_passeios               | BASE TABLE | ORIGINAL            |
| passeios                          | BASE TABLE | ORIGINAL            |
| passengers                        | BASE TABLE | ORIGINAL            |
| payments                          | BASE TABLE | ORIGINAL            |
| pedido_itens                      | BASE TABLE | ORIGINAL            |
| pedidos                           | BASE TABLE | ORIGINAL            |
| produtos                          | BASE TABLE | ORIGINAL            |
| profiles                          | BASE TABLE | NOVA - Multi-tenant |
| projecoes_fluxo_caixa             | BASE TABLE | ORIGINAL            |
| receitas                          | BASE TABLE | ORIGINAL            |
| setores_maracana                  | BASE TABLE | ORIGINAL            |
| sistema_parametros                | BASE TABLE | ORIGINAL            |
| stripe_customers                  | BASE TABLE | ORIGINAL            |
| system_config                     | BASE TABLE | ORIGINAL            |
| user_profiles                     | BASE TABLE | ORIGINAL            |
| viagem_cobranca_historico         | BASE TABLE | ORIGINAL            |
| viagem_despesas                   | BASE TABLE | ORIGINAL            |
| viagem_onibus                     | BASE TABLE | ORIGINAL            |
| viagem_orcamento                  | BASE TABLE | ORIGINAL            |
| viagem_parcelamento_config        | BASE TABLE | ORIGINAL            |
| viagem_passageiros                | BASE TABLE | ORIGINAL            |
| viagem_passageiros_parcelas       | BASE TABLE | ORIGINAL            |
| viagem_passeios                   | BASE TABLE | ORIGINAL            |
| viagem_receitas                   | BASE TABLE | ORIGINAL            |
| viagens                           | BASE TABLE | ORIGINAL            |
| viagens_ingressos                 | BASE TABLE | ORIGINAL            |

| table_name                        | organization_id_status  |
| --------------------------------- | ----------------------- |
| adversarios                       | NÃO TEM organization_id |
| categorias_financeiras            | NÃO TEM organization_id |
| categorias_produtos               | NÃO TEM organization_id |
| cliente_creditos                  | NÃO TEM organization_id |
| clientes                          | NÃO TEM organization_id |
| contas_pagar                      | NÃO TEM organization_id |
| credito_historico                 | NÃO TEM organization_id |
| credito_logs                      | NÃO TEM organization_id |
| credito_viagem_vinculacoes        | NÃO TEM organization_id |
| despesas                          | NÃO TEM organization_id |
| empresa_config                    | NÃO TEM organization_id |
| game_buses                        | NÃO TEM organization_id |
| games                             | NÃO TEM organization_id |
| historico_pagamentos_categorizado | NÃO TEM organization_id |
| historico_pagamentos_ingressos    | NÃO TEM organization_id |
| ingressos                         | NÃO TEM organization_id |
| lista_presenca                    | NÃO TEM organization_id |
| onibus                            | NÃO TEM organization_id |
| onibus_images                     | NÃO TEM organization_id |
| parcela_alertas                   | NÃO TEM organization_id |
| parcela_historico                 | NÃO TEM organization_id |
| passageiro_passeios               | NÃO TEM organization_id |
| passeios                          | NÃO TEM organization_id |
| passengers                        | NÃO TEM organization_id |
| payments                          | NÃO TEM organization_id |
| pedido_itens                      | NÃO TEM organization_id |
| pedidos                           | NÃO TEM organization_id |
| produtos                          | NÃO TEM organization_id |
| projecoes_fluxo_caixa             | NÃO TEM organization_id |
| receitas                          | NÃO TEM organization_id |
| setores_maracana                  | NÃO TEM organization_id |
| sistema_parametros                | NÃO TEM organization_id |
| stripe_customers                  | NÃO TEM organization_id |
| system_config                     | NÃO TEM organization_id |
| user_profiles                     | NÃO TEM organization_id |
| viagem_cobranca_historico         | NÃO TEM organization_id |
| viagem_despesas                   | NÃO TEM organization_id |
| viagem_onibus                     | NÃO TEM organization_id |
| viagem_orcamento                  | NÃO TEM organization_id |
| viagem_parcelamento_config        | NÃO TEM organization_id |
| viagem_passageiros                | NÃO TEM organization_id |
| viagem_passageiros_parcelas       | NÃO TEM organization_id |
| viagem_passeios                   | NÃO TEM organization_id |
| viagem_receitas                   | NÃO TEM organization_id |
| viagens                           | NÃO TEM organization_id |
| viagens_ingressos                 | NÃO TEM organization_id |

| tabela             | total_registros |
| ------------------ | --------------- |
| clientes           | 940             |
| empresa_config     | 1               |
| ingressos          | 14              |
| onibus             | 15              |
| viagem_passageiros | 708             |
| viagens            | 10              |

| table_name      | observacao                                     |
| --------------- | ---------------------------------------------- |
| viagem_passeios | Tabela vazia - pode ser analisada para remoção |

| tabela_origem                     | coluna_origem        | tabela_referenciada         | coluna_referenciada |
| --------------------------------- | -------------------- | --------------------------- | ------------------- |
| cliente_creditos                  | cliente_id           | clientes                    | id                  |
| credito_historico                 | credito_id           | cliente_creditos            | id                  |
| credito_historico                 | viagem_id            | viagens                     | id                  |
| credito_logs                      | credito_id           | cliente_creditos            | id                  |
| credito_viagem_vinculacoes        | credito_id           | cliente_creditos            | id                  |
| credito_viagem_vinculacoes        | passageiro_id        | clientes                    | id                  |
| credito_viagem_vinculacoes        | viagem_id            | viagens                     | id                  |
| despesas                          | viagem_id            | viagens                     | id                  |
| game_buses                        | game_id              | games                       | id                  |
| historico_pagamentos_categorizado | viagem_passageiro_id | viagem_passageiros          | id                  |
| historico_pagamentos_ingressos    | ingresso_id          | ingressos                   | id                  |
| ingressos                         | cliente_id           | clientes                    | id                  |
| ingressos                         | viagem_id            | viagens                     | id                  |
| ingressos                         | viagem_ingressos_id  | viagens_ingressos           | id                  |
| lista_presenca                    | passageiro_id        | viagem_passageiros          | id                  |
| lista_presenca                    | viagem_id            | viagens                     | id                  |
| onibus_images                     | onibus_id            | onibus                      | id                  |
| parcela_alertas                   | parcela_id           | viagem_passageiros_parcelas | id                  |
| parcela_historico                 | parcela_id           | viagem_passageiros_parcelas | id                  |
| passageiro_passeios               | passeio_id           | passeios                    | id                  |
| passageiro_passeios               | viagem_passageiro_id | viagem_passageiros          | id                  |
| passengers                        | bus_id               | game_buses                  | id                  |
| passengers                        | game_id              | games                       | id                  |
| payments                          | cliente_id           | clientes                    | id                  |
| payments                          | viagem_id            | viagens                     | id                  |
| pedido_itens                      | pedido_id            | pedidos                     | id                  |
| produtos                          | categoria_id         | categorias_produtos         | id                  |
| receitas                          | cliente_id           | clientes                    | id                  |
| receitas                          | viagem_id            | viagens                     | id                  |
| stripe_customers                  | cliente_id           | clientes                    | id                  |
| user_profiles                     | viagem_id            | viagens                     | id                  |
| viagem_cobranca_historico         | viagem_passageiro_id | viagem_passageiros          | id                  |
| viagem_despesas                   | viagem_id            | viagens                     | id                  |
| viagem_onibus                     | viagem_id            | viagens                     | id                  |
| viagem_onibus                     | viagem_id            | viagens                     | id                  |
| viagem_orcamento                  | viagem_id            | viagens                     | id                  |
| viagem_parcelamento_config        | viagem_id            | viagens                     | id                  |
| viagem_passageiros                | cliente_id           | clientes                    | id                  |
| viagem_passageiros                | cliente_id           | clientes                    | id                  |
| viagem_passageiros                | credito_origem_id    | cliente_creditos            | id                  |
| viagem_passageiros                | onibus_id            | viagem_onibus               | id                  |
| viagem_passageiros                | onibus_id            | viagem_onibus               | id                  |
| viagem_passageiros                | viagem_id            | viagens                     | id                  |
| viagem_passageiros                | viagem_id            | viagens                     | id                  |
| viagem_passageiros_parcelas       | viagem_passageiro_id | viagem_passageiros          | id                  |
| viagem_passeios                   | passeio_id           | passeios                    | id                  |
| viagem_passeios                   | viagem_id            | viagens                     | id                  |
| viagem_receitas                   | viagem_id            | viagens                     | id                  |

## Resultados do Projeto Multi-tenant
```
-- Cole aqui os resultados da execução no projeto multi-tenant

| table_name                  | table_type | status_tabela       |
| --------------------------- | ---------- | ------------------- |
| clientes                    | BASE TABLE | ORIGINAL            |
| credito_vinculacoes         | BASE TABLE | ORIGINAL            |
| creditos_clientes           | BASE TABLE | ORIGINAL            |
| empresa_config              | BASE TABLE | ORIGINAL            |
| ingressos                   | BASE TABLE | ORIGINAL            |
| onibus                      | BASE TABLE | ORIGINAL            |
| organization_settings       | BASE TABLE | ORIGINAL            |
| organization_subscriptions  | BASE TABLE | NOVA - Multi-tenant |
| organizations               | BASE TABLE | NOVA - Multi-tenant |
| passeios                    | BASE TABLE | ORIGINAL            |
| profiles                    | BASE TABLE | NOVA - Multi-tenant |
| setores_maracana            | BASE TABLE | ORIGINAL            |
| super_admin_users           | BASE TABLE | NOVA - Multi-tenant |
| system_activity_logs        | BASE TABLE | ORIGINAL            |
| user_invitations            | BASE TABLE | NOVA - Multi-tenant |
| user_permissions            | BASE TABLE | NOVA - Multi-tenant |
| viagem_cobranca_historico   | BASE TABLE | ORIGINAL            |
| viagem_despesas             | BASE TABLE | ORIGINAL            |
| viagem_onibus               | BASE TABLE | ORIGINAL            |
| viagem_orcamento            | BASE TABLE | ORIGINAL            |
| viagem_passageiros          | BASE TABLE | ORIGINAL            |
| viagem_passageiros_parcelas | BASE TABLE | ORIGINAL            |
| viagem_passeios             | BASE TABLE | ORIGINAL            |
| viagem_receitas             | BASE TABLE | ORIGINAL            |
| viagens                     | BASE TABLE | ORIGINAL            |

| table_name                  | organization_id_status |
| --------------------------- | ---------------------- |
| clientes                    | TEM organization_id    |
| credito_vinculacoes         | TEM organization_id    |
| creditos_clientes           | TEM organization_id    |
| empresa_config              | TEM organization_id    |
| ingressos                   | TEM organization_id    |
| onibus                      | TEM organization_id    |
| organization_settings       | TEM organization_id    |
| organization_subscriptions  | TEM organization_id    |
| passeios                    | TEM organization_id    |
| setores_maracana            | TEM organization_id    |
| system_activity_logs        | TEM organization_id    |
| user_invitations            | TEM organization_id    |
| user_permissions            | TEM organization_id    |
| viagem_cobranca_historico   | TEM organization_id    |
| viagem_despesas             | TEM organization_id    |
| viagem_onibus               | TEM organization_id    |
| viagem_orcamento            | TEM organization_id    |
| viagem_passageiros          | TEM organization_id    |
| viagem_passageiros_parcelas | TEM organization_id    |
| viagem_passeios             | TEM organization_id    |
| viagem_receitas             | TEM organization_id    |
| viagens                     | TEM organization_id    |

| tabela             | total_registros |
| ------------------ | --------------- |
| clientes           | 0               |
| empresa_config     | 1               |
| ingressos          | 0               |
| onibus             | 0               |
| viagem_passageiros | 0               |
| viagens            | 0               |

| tabela_origem               | coluna_origem        | tabela_referenciada | coluna_referenciada |
| --------------------------- | -------------------- | ------------------- | ------------------- |
| clientes                    | organization_id      | organizations       | id                  |
| clientes                    | organization_id      | organizations       | id                  |
| credito_vinculacoes         | credito_id           | creditos_clientes   | id                  |
| credito_vinculacoes         | organization_id      | organizations       | id                  |
| credito_vinculacoes         | viagem_id            | viagens             | id                  |
| creditos_clientes           | cliente_id           | clientes            | id                  |
| creditos_clientes           | organization_id      | organizations       | id                  |
| creditos_clientes           | organization_id      | organizations       | id                  |
| empresa_config              | organization_id      | organizations       | id                  |
| ingressos                   | cliente_id           | clientes            | id                  |
| ingressos                   | organization_id      | organizations       | id                  |
| ingressos                   | organization_id      | organizations       | id                  |
| onibus                      | organization_id      | organizations       | id                  |
| onibus                      | organization_id      | organizations       | id                  |
| organization_settings       | organization_id      | organizations       | id                  |
| organization_subscriptions  | organization_id      | organizations       | id                  |
| passeios                    | organization_id      | organizations       | id                  |
| profiles                    | organization_id      | organizations       | id                  |
| setores_maracana            | organization_id      | organizations       | id                  |
| super_admin_users           | created_by           | profiles            | id                  |
| super_admin_users           | user_id              | profiles            | id                  |
| system_activity_logs        | organization_id      | organizations       | id                  |
| user_invitations            | invited_by           | profiles            | id                  |
| user_invitations            | organization_id      | organizations       | id                  |
| user_permissions            | organization_id      | organizations       | id                  |
| user_permissions            | user_id              | profiles            | id                  |
| viagem_cobranca_historico   | organization_id      | organizations       | id                  |
| viagem_cobranca_historico   | viagem_passageiro_id | viagem_passageiros  | id                  |
| viagem_despesas             | organization_id      | organizations       | id                  |
| viagem_despesas             | viagem_id            | viagens             | id                  |
| viagem_onibus               | onibus_id            | onibus              | id                  |
| viagem_onibus               | organization_id      | organizations       | id                  |
| viagem_onibus               | viagem_id            | viagens             | id                  |
| viagem_orcamento            | organization_id      | organizations       | id                  |
| viagem_orcamento            | viagem_id            | viagens             | id                  |
| viagem_passageiros          | cliente_id           | clientes            | id                  |
| viagem_passageiros          | onibus_id            | onibus              | id                  |
| viagem_passageiros          | organization_id      | organizations       | id                  |
| viagem_passageiros          | viagem_id            | viagens             | id                  |
| viagem_passageiros_parcelas | organization_id      | organizations       | id                  |
| viagem_passageiros_parcelas | viagem_passageiro_id | viagem_passageiros  | id                  |
| viagem_passeios             | organization_id      | organizations       | id                  |
| viagem_passeios             | viagem_id            | viagens             | id                  |
| viagem_receitas             | organization_id      | organizations       | id                  |
| viagem_receitas             | viagem_id            | viagens             | id                  |
| viagens                     | onibus_id            | onibus              | id                  |
| viagens                     | organization_id      | organizations       | id                  |
| viagens                     | organization_id      | organizations       | id                  |

## Análise das Diferenças

### ✅ Tabelas presentes apenas no projeto original (46 tabelas):
- **Financeiras:** categorias_financeiras, contas_pagar, despesas, historico_pagamentos_categorizado, historico_pagamentos_ingressos, parcela_alertas, parcela_historico, projecoes_fluxo_caixa, receitas, viagem_receitas
- **Créditos:** cliente_creditos, credito_historico, credito_logs, credito_viagem_vinculacoes
- **Produtos/Loja:** categorias_produtos, pedido_itens, pedidos, produtos
- **Games/Adversários:** adversarios, game_buses, games, passengers, setores_maracana
- **Sistema:** sistema_parametros, system_config, user_profiles
- **Pagamentos:** payments, stripe_customers
- **Outros:** lista_presenca, onibus_images, passageiro_passeios, viagens_ingressos

### ✅ Tabelas presentes apenas no projeto multi-tenant (6 tabelas):
- **Multi-tenant Core:** organizations, profiles, super_admin_users
- **Gestão de Usuários:** user_invitations, user_permissions
- **Configurações:** organization_settings, organization_subscriptions
- **Logs:** system_activity_logs

### ✅ Tabelas comuns em ambos projetos (9 tabelas):
- **Principais:** clientes, viagens, onibus, ingressos, passeios
- **Configuração:** empresa_config
- **Viagem-relacionadas:** viagem_cobranca_historico, viagem_despesas, viagem_onibus, viagem_orcamento, viagem_passageiros, viagem_passageiros_parcelas, viagem_passeios
- **Créditos (adaptado):** creditos_clientes, credito_vinculacoes

### ⚠️ Status da Migração Multi-tenant:
- **✅ SUCESSO:** Todas as 9 tabelas comuns já possuem `organization_id` no projeto multi-tenant
- **❌ FALTANDO:** 46 tabelas do projeto original não foram migradas para o multi-tenant
- **📊 DADOS:** Projeto original tem 940 clientes e dados reais, multi-tenant está vazio (apenas 1 empresa_config)

## 🎯 Próximos Passos Prioritários

### 1. **URGENTE - Migração de Tabelas Críticas**
- [ ] **Financeiras:** Migrar sistema completo de gestão financeira (10 tabelas)
- [ ] **Créditos:** Migrar sistema de créditos de clientes (4 tabelas)
- [ ] **Produtos/Loja:** Migrar e-commerce/loja de produtos (4 tabelas)
- [ ] **Pagamentos:** Migrar integração com Stripe (2 tabelas)

### 2. **IMPORTANTE - Funcionalidades Específicas**
- [ ] **Games/Adversários:** Migrar sistema de jogos/eventos (5 tabelas)
- [ ] **Sistema:** Migrar configurações e parâmetros (3 tabelas)
- [ ] **Outros:** Migrar funcionalidades auxiliares (4 tabelas)

### 3. **MIGRAÇÃO DE DADOS**
- [ ] Criar script para migrar 940 clientes do projeto original
- [ ] Migrar dados de viagens, ônibus e ingressos existentes
- [ ] Configurar organização padrão para dados migrados

### 4. **VALIDAÇÃO E TESTES**
- [ ] Testar isolamento multi-tenant em todas as tabelas migradas
- [ ] Validar políticas RLS (Row Level Security)
- [ ] Testar funcionalidades críticas após migração

### 5. **DOCUMENTAÇÃO**
- [ ] Documentar mapeamento de tabelas migradas
- [ ] Criar guia de migração para novos módulos
- [ ] Atualizar documentação da arquitetura multi-tenant

## Comandos para Execução

### No projeto original:
```bash
# Conectar ao banco original e executar:
psql -h [host] -U [user] -d [database] -f compare_tables_structure.sql
```

### No projeto multi-tenant:
```bash
# Conectar ao banco multi-tenant e executar:
psql -h [host] -U [user] -d [database] -f compare_tables_structure.sql
```

## 🚀 Recomendações Estratégicas

### **Fase 1: Migração Crítica (1-2 semanas)**
1. **Financeiro:** Prioridade máxima - sistema de gestão financeira completo
2. **Créditos:** Sistema de créditos de clientes é funcionalidade core
3. **Dados:** Migrar os 940 clientes existentes para validar o sistema

### **Fase 2: Funcionalidades Comerciais (2-3 semanas)**
1. **Produtos/Loja:** E-commerce para monetização
2. **Pagamentos:** Integração Stripe para processamento
3. **Games/Eventos:** Diferencial competitivo

### **Fase 3: Otimização (1 semana)**
1. **Sistema:** Configurações e parâmetros avançados
2. **Logs:** Auditoria e monitoramento
3. **Performance:** Otimização de queries multi-tenant

### **Riscos Identificados:**
- ⚠️ **Alto:** 46 tabelas faltando podem impactar funcionalidades críticas
- ⚠️ **Médio:** Dados vazios no multi-tenant impedem testes reais
- ⚠️ **Baixo:** Algumas funcionalidades podem ter dependências não mapeadas

### **Benefícios Esperados:**
- ✅ **Isolamento:** Cada cliente terá seus dados completamente isolados
- ✅ **Escalabilidade:** Arquitetura preparada para milhares de organizações
- ✅ **Segurança:** RLS garante que clientes não vejam dados de outros
- ✅ **Monetização:** Sistema de assinaturas e billing por organização

---
*Análise completa da comparação entre as estruturas de tabelas dos projetos original e multi-tenant.*
*Última atualização: $(date)*