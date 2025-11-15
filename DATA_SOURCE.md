# Fonte dos Dados - IF.data (Banco Central do Brasil)

**URL**: https://www3.bcb.gov.br/ifdata/

**Data de Extração**: Março/2025

---

## O que é o IF.data?

O **IF.data** (Sistema de Informações Financeiras) é a plataforma oficial do Banco Central do Brasil (BCB) para divulgação de dados financeiros de instituições autorizadas a funcionar no país.

### Características Principais:

- **Cobertura**: Todas as instituições financeiras e não-financeiras sob supervisão do BCB
- **Atualização**: Trimestral (março, junho, setembro, dezembro)
- **Formato**: Exportação em CSV, Excel e outros formatos
- **Idiomas**: Português e Inglês
- **Acesso**: Público e gratuito

---

## Dados Disponibilizados

O sistema oferece três categorias principais de informações:

### 1. Informações Contábeis e de Capital
- Balanço patrimonial (ativos e passivos)
- Demonstração de resultados
- Patrimônio de referência e índices de capital
- Índices de Basileia
- Índices de imobilização

### 2. Informações de Crédito
- Carteira de crédito por modalidade
- Segmentação por atividade econômica
- Distribuição geográfica
- Qualidade de crédito

### 3. Informações de Câmbio
- Movimentações cambiais trimestrais
- Posições em moeda estrangeira

---

## Instituições Cobertas

O IF.data abrange:

- **Bancos Múltiplos**: Itaú, Bradesco, Banco do Brasil, Caixa, Santander, etc.
- **Bancos Comerciais**: Bancos regionais e locais
- **Bancos de Investimento**: BTG Pactual, XP, etc.
- **Bancos de Desenvolvimento**: BNDES, agências de fomento
- **Cooperativas de Crédito**: Sicredi, Sicoob, etc.
- **Fintechs**: Nubank, Inter, C6, PagBank, etc.
- **Outras Instituições**: Administradoras de consórcio, instituições de pagamento, securitizadoras

### Total de Instituições (Março/2025):
- **Dataset original**: 1,414 instituições
- **Após limpeza**: 1,055 instituições analisadas

---

## Perspectivas de Consulta

O IF.data permite três visões diferentes:

1. **Instituições Individuais**: Dados de cada instituição isoladamente
2. **Conglomerados Prudenciais**: Agrupamento para fins de supervisão prudencial
3. **Conglomerados Financeiros**: Consolidação de grupos econômicos

**Neste projeto**: Utilizamos dados de **instituições individuais**.

---

## Periodicidade e Prazos de Divulgação

| Período de Referência | Prazo de Divulgação |
|----------------------|---------------------|
| Março, Junho, Setembro | Até 60 dias após o encerramento |
| Dezembro | Até 90 dias após o encerramento |

**Dados utilizados**: Posição de **Março/2025**

---

## Padrão Contábil

### Importante - Mudança em 2025:

Em 2025, o BCB implementou o novo **Padrão Contábil das Instituições Reguladas pelo Banco Central (Cosif)**, alterando principalmente:
- Classificação de ativos
- Estrutura de demonstrações de resultado
- Metodologia de cálculo de alguns indicadores

**Impacto no projeto**: Dados de março/2025 já seguem o novo padrão contábil.

---

## Variáveis Extraídas para este Projeto

### Dados Contábeis:
1. **Ativo Total** (em R$ mil): Total de ativos da instituição
2. **Carteira de Crédito** (em R$ mil): Volume total de operações de crédito ativas
3. **Patrimônio Líquido** (em R$ mil): Capital próprio da instituição
4. **Lucro Líquido** (em R$ mil): Resultado financeiro do período

### Indicadores Regulatórios:
5. **Índice de Basileia** (%): Razão entre capital e ativos ponderados pelo risco (RWA)
   - Mínimo regulatório: 10.5%
   - Valores altos indicam maior solidez de capital
6. **Índice de Imobilização** (%): Proporção de ativos imobilizados em relação ao patrimônio
   - Limite regulatório: 50%
   - Valores baixos indicam maior liquidez

### Dados Operacionais:
7. **Número de Agências**: Quantidade de agências bancárias (rede física)
8. **Número de Postos de Atendimento**: PABs, PAEs e outros pontos de atendimento

---

## Metodologia de Extração

### 1. Acesso ao IF.data:
- Portal: https://www3.bcb.gov.br/ifdata/
- Seleção: "Informações Contábeis e de Capital"
- Período: Março/2025
- Perspectiva: Instituições Individuais

### 2. Filtros Aplicados:
- Todas as instituições autorizadas a funcionar
- Dados consolidados (não individualizados por agência)
- Posição: Trimestre encerrado em março/2025

### 3. Exportação:
- Formato: CSV com separador ponto-e-vírgula (;)
- Encoding: UTF-8
- Formato numérico brasileiro: vírgula decimal, ponto separador de milhar

### 4. Limpeza:
- Remoção de instituições com dados "NI" (Não Informado)
- Remoção de valores ausentes (NA)
- Conversão de formato brasileiro para padrão internacional
- **Retenção**: 1,055 de 1,414 instituições (74.6%)

---

## Qualidade dos Dados

### ✅ Pontos Fortes:
- **Fonte Oficial**: Dados auditados e supervisionados pelo BCB
- **Padronização**: Metodologia contábil uniforme (Cosif)
- **Completude**: Informações abrangentes de múltiplas dimensões
- **Atualidade**: Dados recentes (março/2025)
- **Confiabilidade**: Sujeitos a supervisão prudencial

### ⚠️ Limitações:
- **Valores ausentes**: 359 instituições (25.4%) removidas por dados incompletos
- **Outliers**: Concentração de mercado gera outliers extremos (grandes bancos)
- **Assimetria**: Distribuições altamente assimétricas à direita
- **Heterogeneidade**: Inclui instituições de naturezas muito diferentes (bancos comerciais vs cooperativas vs fintechs)

---

## Representatividade da Amostra

### Instituições por Tipo (estimado):
- Bancos Comerciais e Múltiplos: ~150
- Cooperativas de Crédito: ~600
- Bancos de Investimento: ~30
- Sociedades de Crédito/Financiamento: ~100
- Fintechs e Bancos Digitais: ~50
- Outros (consórcios, securitizadoras): ~125

### Concentração de Mercado:
- **Top 5 bancos** (Itaú, BB, Caixa, Bradesco, Santander): ~70% dos ativos totais do sistema
- **Top 10**: ~80% dos ativos
- **Demais 1,045 instituições**: ~20% dos ativos

**Implicação**: Dataset captura toda a diversidade do sistema financeiro brasileiro, desde gigantes até pequenas cooperativas locais.

---

## Variáveis Adicionais Disponíveis (não utilizadas)

O IF.data oferece centenas de outras variáveis que não foram incluídas neste estudo:

### Ativos:
- Disponibilidades
- Aplicações interfinanceiras
- Títulos e valores mobiliários (TVM)
- Operações de crédito por segmento
- Outros ativos

### Passivos:
- Depósitos à vista
- Depósitos a prazo
- Captações no mercado aberto
- Obrigações por empréstimos
- Instrumentos híbridos de capital

### Resultados:
- Receitas de intermediação financeira
- Despesas de intermediação financeira
- Resultado de operações com TVM
- Despesas administrativas
- Provisões

### Indicadores de Risco:
- RWA (Risk Weighted Assets)
- Índice de Liquidez de Curto Prazo (LCR)
- Índice de Liquidez Estrutural (NSFR)
- Exposições a risco de mercado

**Razão para não inclusão**: Foco em variáveis fundamentais para análise multivariada de tamanho, performance e risco.

---

## Referências Regulatórias

### Índice de Basileia:
- **Regulamentação**: Resolução CMN nº 4.193/2013 e posteriores
- **Cálculo**: Patrimônio de Referência (PR) / RWA
- **Mínimo**: 10.5% (8% Basileia III + 2.5% buffer de conservação)
- **Interpretação**:
  - < 10.5%: Abaixo do mínimo regulatório
  - 10.5-15%: Adequado
  - > 15%: Bem capitalizado

### Índice de Imobilização:
- **Regulamentação**: Resolução CMN nº 2.669/1999
- **Cálculo**: Ativo Permanente / Patrimônio de Referência
- **Limite**: 50%
- **Interpretação**:
  - < 30%: Baixa imobilização (mais líquido)
  - 30-50%: Imobilização moderada
  - > 50%: Acima do limite (requer ação corretiva)

---

## Informações sobre os Dados deste Projeto

### Arquivo: `dados.csv`
- **Fonte**: IF.data - Banco Central do Brasil
- **URL**: https://www3.bcb.gov.br/ifdata/
- **Período de Referência**: Março/2025
- **Data de Extração**: 2025
- **Perspectiva**: Instituições Individuais
- **Formato Original**: CSV (separador ;, decimal vírgula)
- **Tamanho**: 246.8 KB
- **Observações Originais**: 1,414 instituições
- **Observações Após Limpeza**: 1,055 instituições (74.6% retenção)

### Variáveis Selecionadas para Análise:
8 variáveis (de 22 disponíveis no arquivo original):
1. ativo_total
2. carteira_de_credito
3. patrimonio_liquido
4. lucro_liquido
5. indice_de_basileia
6. indice_de_imobilizacao
7. numero_de_agencias
8. numero_de_postos_de_atendimento

### Critério de Seleção:
- Variáveis representativas de tamanho, performance e risco
- Remoção de variáveis altamente correlacionadas (r > 0.95)
- Foco em indicadores-chave para análise multivariada

---

## Licença e Uso dos Dados

### Termos de Uso:
- **Dados públicos**: Disponibilizados pelo Banco Central do Brasil
- **Acesso livre**: Sem necessidade de autenticação
- **Uso acadêmico**: Permitido para fins educacionais e de pesquisa
- **Citação recomendada**:

```
Banco Central do Brasil (2025). IF.data - Sistema de Informações Financeiras.
Dados referentes a março/2025. Disponível em: https://www3.bcb.gov.br/ifdata/
Acesso em: [data de acesso].
```

---

## Notas Importantes

1. **Sigilo Bancário**: IF.data divulga apenas dados agregados e consolidados, respeitando o sigilo de operações individuais de clientes.

2. **Padrão Contábil**: Dados de março/2025 seguem o novo Cosif (Plano Contábil das Instituições do SFN).

3. **Valores Negativos**: Alguns bancos podem apresentar:
   - Lucro líquido negativo (prejuízo)
   - Patrimônio líquido negativo (patrimônio insuficiente)
   - Índice de Basileia negativo (déficit de capital)

   Estes casos representam instituições em dificuldade financeira.

4. **NI (Não Informado)**: Algumas instituições não reportam todos os dados, resultando em valores "NI" que foram removidos na limpeza.

5. **Frequência Zero em Agências**: Mais de 50% dos bancos têm zero agências físicas, refletindo:
   - Crescimento de bancos digitais (fintechs)
   - Cooperativas sem rede própria
   - Instituições de nicho (private banking, investment banks)

---

## Reprodutibilidade

Para reproduzir a extração dos dados:

1. Acesse: https://www3.bcb.gov.br/ifdata/
2. Selecione: "Informações Contábeis e de Capital"
3. Período: Março/2025
4. Perspectiva: "Instituições Individuais"
5. Variáveis: Selecionar as 22 colunas conforme arquivo original
6. Exportar: CSV (separador ponto-e-vírgula)
7. Salvar como: `dados.csv`

**Nota**: Dados podem variar levemente entre extrações devido a revisões e atualizações posteriores pelo BCB.

---

## Contato e Suporte

Para dúvidas sobre os dados ou metodologia do IF.data:

- **Portal BCB**: https://www.bcb.gov.br
- **FAQ IF.data**: https://www3.bcb.gov.br/ifdata/
- **Ouvidoria BCB**: https://www.bcb.gov.br/acessoinformacao/ouvidoria

---

**Documento Criado**: 2025-11-15
**Projeto**: Análise Multivariada de Dados Bancários
**Disciplina**: Aprendizado de Máquina Não Supervisionado
