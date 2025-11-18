# Dicionário de Dados - IF.data (Banco Central do Brasil)

**Fonte**: IF.data - Sistema de Informações Financeiras (BCB)
**URL**: https://www3.bcb.gov.br/ifdata/
**Período**: Março/2025
**Arquivo**: `apresentacao_uriel/dados.csv`
**Total de Colunas**: 22 (21 informativas + 1 vazia)
**Total de Observações**: 1,414 instituições (1,055 após limpeza)

---

## Colunas do Dataset Original

### 1. Instituição
- **Tipo**: Texto (string)
- **Descrição**: Nome da instituição financeira ou conglomerado prudencial
- **Formato**: Nome completo conforme registro no BCB, seguido de " - PRUDENCIAL" para conglomerados
- **Exemplos**:
  - "ITAU - PRUDENCIAL"
  - "BB - PRUDENCIAL" (Banco do Brasil)
  - "CAIXA - PRUDENCIAL"
  - "NUBANK"
- **Observações**:
  - Conglomerados prudenciais agregam múltiplas instituições do mesmo grupo
  - Nomes padronizados pelo BCB
- **Usado nas análises**: Sim (variável `bancos` para identificação)

---

### 2. Código
- **Tipo**: Numérico (inteiro)
- **Descrição**: Código único da instituição no sistema BCB
- **Formato**: 10 dígitos
- **Exemplos**:
  - 1000080099 (Itaú)
  - 1000080329 (Banco do Brasil)
- **Observações**: Identificador único para cada instituição/conglomerado
- **Usado nas análises**: Não (apenas para referência)

---

### 3. TCB (Tipo de Consolidado Bancário)
- **Tipo**: Texto (código)
- **Descrição**: Classificação do tipo de instituição
- **Valores possíveis**:
  - `b1`: Banco Comercial, Banco Múltiplo com Carteira Comercial ou Caixas Econômicas
  - `b2`: Banco Múltiplo sem Carteira Comercial ou Banco de Câmbio ou Banco de Investimento
  - `b3S`: Cooperativa de Crédito Singular
  - `b3C`: Central e Confederação de Cooperativas de Crédito
  - `b4`: Banco de Desenvolvimento
  - `n1`: Não bancário de Crédito
  - `n2`: Não bancário do Mercado de Capitais
  - `n4`: Instituições de Pagamento
- **Exemplos**:
  - "b1" (Itaú, Bradesco, BB, Caixa - maioria dos grandes bancos)
  - "b3S" (cooperativas singulares)
  - "n4" (fintechs, instituições de pagamento)
- **Usado nas análises**: Não

---

### 4. SR (Segmento Regulatório)
- **Tipo**: Texto (código)
- **Descrição**: Segmento de supervisão do BCB (Framework de Supervisão Proporcional - Resolução nº 4.553/2017)
- **Valores possíveis**:
  - `S1`: Bancos múltiplos, bancos comerciais, bancos de investimento, bancos de câmbio e caixas econômicas que:
    - (i) tenham porte (Exposição/PIB) superior a 10%; ou
    - (ii) exerçam atividade internacional relevante (ativos no exterior > US$ 10 bilhões)
  - `S2`:
    - (i) Bancos múltiplos, bancos comerciais, bancos de investimento, bancos de câmbio e caixas econômicas de porte inferior a 10% e igual ou superior a 1%; e
    - (ii) Demais instituições autorizadas a funcionar pelo BCB de porte igual ou superior a 1% do PIB
  - `S3`: Instituições de porte inferior a 1% e igual ou superior a 0,1% do PIB
  - `S4`: Instituições de porte inferior a 0,1% do PIB
  - `S5`: Composto por:
    - (i) Instituições de porte inferior a 0,1% que utilizem metodologia facultativa simplificada para apuração dos requerimentos mínimos de PR, exceto bancos múltiplos, bancos comerciais, bancos de investimento, bancos de câmbio e caixas econômicas; e
    - (ii) Instituições não sujeitas a apuração de PR
- **Exemplos**:
  - "S1" (Itaú, BB, Caixa, Bradesco, Santander - porte > 10% PIB)
  - "S4" ou "S5" (bancos pequenos e cooperativas - porte < 0,1% PIB)
- **Observações**: Determina intensidade de supervisão e requisitos regulatórios pelo BCB
- **Usado nas análises**: Não (mas poderia ser usado para estratificação)

---

### 5. TD (Tipo de Consolidação)
- **Tipo**: Texto (código)
- **Descrição**: Indica se os dados são de instituição individual ou conglomerado prudencial
- **Valores possíveis**:
  - `I`: Instituição Independente (dados da instituição individualmente)
  - `C`: Conglomerado (dados consolidados do conglomerado prudencial)
- **Exemplos**:
  - "C" (ITAU - PRUDENCIAL, BB - PRUDENCIAL, CAIXA - PRUDENCIAL - conglomerados consolidados)
  - "I" (instituições individuais não parte de conglomerado ou reportadas separadamente)
- **Observações**: Conglomerados prudenciais agregam múltiplas instituições do mesmo grupo econômico para fins de supervisão
- **Usado nas análises**: Não (mas importante para entender a natureza dos dados)

---

### 6. TC (Tipo de Controle)
- **Tipo**: Numérico (código)
- **Descrição**: Natureza do controle acionário
- **Valores possíveis**:
  - `1`: Público Federal
  - `2`: Privado Nacional
  - `3`: Privado Controle Estrangeiro
  - `4`: Público Estadual
  - `5`: Público Municipal
- **Exemplos**:
  - 1 (BB, Caixa, BNDES)
  - 2 (Itaú, Bradesco, Nubank)
  - 3 (Santander, HSBC, Citibank)
- **Usado nas análises**: Não

---

### 7. Cidade
- **Tipo**: Texto (string)
- **Descrição**: Cidade da sede da instituição
- **Formato**: Nome da cidade em maiúsculas
- **Exemplos**:
  - "SAO PAULO"
  - "BRASILIA"
  - "RIO DE JANEIRO"
- **Usado nas análises**: Não (poderia ser usado para análise geográfica)

---

### 8. UF
- **Tipo**: Texto (código)
- **Descrição**: Unidade da Federação (estado) da sede
- **Formato**: Sigla de 2 letras
- **Exemplos**: "SP", "DF", "RJ", "MG", "RS"
- **Distribuição**: Concentração em SP (maioria dos bancos)
- **Usado nas análises**: Não

---

### 9. Data
- **Tipo**: Texto (data)
- **Descrição**: Período de referência dos dados
- **Formato**: MM/YYYY (mês/ano)
- **Valor neste dataset**: "03/2025" (março de 2025)
- **Observações**: Dados trimestrais divulgados pelo BCB
- **Usado nas análises**: Não (todas observações do mesmo período)

---

### 10. Ativo Total
- **Tipo**: Numérico (valores em R$ mil)
- **Descrição**: Total de ativos da instituição (balanço patrimonial)
- **Fórmula COSIF**: [1000000009] + [2000000008]
  - [1000000009]: Ativo Circulante
  - [2000000008]: Ativo Não Circulante
- **Formato Original**: Brasileiro (ponto separador de milhar, sem decimais)
- **Unidade**: Milhares de Reais (R$ mil)
- **Exemplos**:
  - 2.500.942.812 (Itaú - R$ 2,5 trilhões)
  - 373.787 (mediana - R$ 373 milhões)
- **Range observado**: 236 (mín) a 2.500.942.812 (máx)
- **Usado nas análises**: ✅ **SIM** (variável central)
- **Transformação**: Conversão para numérico padrão + padronização (Z-score)

---

### 11. Carteira de Crédito
- **Tipo**: Numérico (valores em R$ mil)
- **Descrição**: Volume total de operações de crédito ativas (empréstimos e financiamentos)
- **Fórmula COSIF**: [1600000007] + [1741000007] + [1810000000] + [1887900009] + [1899600005]
  - [1600000007]: Operações de Crédito
  - [1741000007]: Arrendamento Mercantil
  - [1810000000]: Operações de Crédito - Exterior
  - [1887900009]: Operações de Crédito - Outras
  - [1899600005]: Provisões para Operações de Crédito (ajustes)
- **Formato Original**: Brasileiro (ponto separador de milhar)
- **Unidade**: Milhares de Reais (R$ mil)
- **Exemplos**:
  - 1.140.591.528 (Itaú - R$ 1,1 trilhão)
  - 158.294 (mediana - R$ 158 milhões)
- **Range observado**: 0 (alguns bancos sem carteira) a 1.213.628.393 (máx)
- **Correlação com Ativo**: r = 0.991 (quase perfeita!)
- **Usado nas análises**: ✅ **SIM**
- **Transformação**: Conversão + padronização

---

### 12. Títulos e Valores Mobiliários
- **Tipo**: Numérico (valores em R$ mil)
- **Descrição**: Investimentos em títulos públicos e privados, ações, fundos, etc.
- **Fórmula COSIF**: [1300000008] - [1330000009]
  - [1300000008]: Títulos e Valores Mobiliários e Instrumentos Financeiros Derivativos
  - [1330000009]: Instrumentos Financeiros Derivativos (excluídos do total)
- **Formato Original**: Brasileiro (ponto separador de milhar)
- **Unidade**: Milhares de Reais (R$ mil)
- **Exemplos**:
  - 557.919.816 (Itaú - R$ 557 bilhões)
- **Observações**: Importante para bancos de investimento
- **Usado nas análises**: ❌ **NÃO** (removido por alta correlação com Ativo Total)

---

### 13. Passivo Exigível
- **Tipo**: Numérico (valores em R$ mil)
- **Descrição**: Total de obrigações da instituição (passivo circulante + não circulante)
- **Fórmula COSIF**: [4000000006]
  - [4000000006]: Passivo Exigível Total (Passivo Circulante + Passivo Não Circulante)
- **Formato Original**: Brasileiro (ponto separador de milhar)
- **Unidade**: Milhares de Reais (R$ mil)
- **Relação**: Ativo Total ≈ Passivo Exigível + Patrimônio Líquido (equação contábil fundamental)
- **Usado nas análises**: ❌ **NÃO** (redundante com Ativo e Patrimônio)

---

### 14. Captações
- **Tipo**: Numérico (valores em R$ mil)
- **Descrição**: Total de recursos captados (depósitos à vista, a prazo, poupança, etc.)
- **Fórmula COSIF**: [4100000009] + [4200000002] + [4300000005] - [4391000007] - [4392000006] + [4600000004]
  - [4100000009]: Depósitos à Vista
  - [4200000002]: Depósitos de Poupança
  - [4300000005]: Depósitos a Prazo
  - [4391000007]: (-) Depósitos de Instituições Financeiras (dedução)
  - [4392000006]: (-) Depósitos de Instituições Oficiais (dedução)
  - [4600000004]: Captações no Mercado Aberto
- **Formato Original**: Brasileiro (ponto separador de milhar)
- **Unidade**: Milhares de Reais (R$ mil)
- **Exemplos**:
  - 1.904.144.152 (Itaú - R$ 1,9 trilhão em depósitos)
- **Observações**: Subconjunto do Passivo Exigível (representa a principal fonte de funding dos bancos)
- **Usado nas análises**: ❌ **NÃO** (alta correlação com Ativo)

---

### 15. Patrimônio Líquido
- **Tipo**: Numérico (valores em R$ mil)
- **Descrição**: Capital próprio da instituição (Ativo - Passivo)
- **Fórmula COSIF**: [6000000004] + [7000000003] + [8000000002]
  - [6000000004]: Patrimônio Líquido (conta principal)
  - [7000000003]: Resultado de Exercícios Futuros
  - [8000000002]: Lucros/Prejuízos Acumulados
- **Formato Original**: Brasileiro (ponto separador de milhar)
- **Unidade**: Milhares de Reais (R$ mil)
- **Exemplos**:
  - 204.014.774 (Itaú - R$ 204 bilhões)
  - 64.043 (mediana - R$ 64 milhões)
- **Range observado**: -646 (patrimônio negativo!) a 204.014.774
- **Valores negativos**: Indicam instituições em dificuldade (passivo > ativo, passivo a descoberto)
- **Usado nas análises**: ✅ **SIM**
- **Transformação**: Conversão + padronização

---

### 16. Lucro Líquido
- **Tipo**: Numérico (valores em R$ mil)
- **Descrição**: Resultado líquido do período (trimestre)
- **Fórmula COSIF**: [7000000003] + [8000000002]
  - [7000000003]: Resultado de Exercícios Futuros
  - [8000000002]: Lucros ou Prejuízos Acumulados
- **Formato Original**: Brasileiro (ponto separador de milhar)
- **Unidade**: Milhares de Reais (R$ mil)
- **Exemplos**:
  - 11.133.252 (Itaú - R$ 11,1 bilhões de lucro trimestral)
  - 1.420 (mediana - R$ 1,4 milhão)
- **Range observado**: -134.669 (prejuízo) a 11.133.252
- **Valores negativos**: Prejuízo no período (legítimo)
- **Usado nas análises**: ✅ **SIM**
- **Transformação**: Conversão + padronização

---

### 17. Patrimônio de Referência para Comparação com o RWA (e)
- **Tipo**: Numérico (valores em R$ mil)
- **Descrição**: Patrimônio de Referência (PR) usado para cálculo do Índice de Basileia
- **Formato Original**: Brasileiro (ponto separador de milhar)
- **Unidade**: Milhares de Reais (R$ mil)
- **Fórmula**: PR = Capital Nível I + Capital Nível II (regulamentação de Basileia)
- **Uso**: Numerador do Índice de Basileia (PR / RWA)
- **Exemplos**:
  - 224.092.080 (Itaú - R$ 224 bilhões)
- **Usado nas análises**: ❌ **NÃO** (redundante com Patrimônio Líquido)
- **Observação**: RWA = Risk-Weighted Assets (ativos ponderados pelo risco)

---

### 18. Índice de Basileia
- **Tipo**: Numérico (percentual)
- **Descrição**: Razão entre Patrimônio de Referência (PR) e ativos ponderados pelo risco (RWA)
- **Formato Original**: Percentual brasileiro (vírgula decimal, símbolo %)
- **Fórmula**: (PR / RWA) × 100%
- **Exemplos**:
  - "15,64%" (Itaú)
  - "14,14%" (BB)
- **Range observado**: -32.87% a 69.84%
- **Interpretação**:
  - < 10.5%: Abaixo do mínimo regulatório ⚠️
  - 10.5-15%: Adequado ✓
  - 15-20%: Bem capitalizado ✓✓
  - > 20%: Fortemente capitalizado ✓✓✓
  - Negativo: Déficit de capital (situação crítica)
- **Regulamentação**: Resolução CMN nº 4.193/2013 (Basileia III)
- **Mínimo exigido**: 10.5% (8% + 2.5% buffer de conservação)
- **Usado nas análises**: ✅ **SIM** (indicador de solidez financeira)
- **Transformação**: Conversão para decimal (15,64% → 0.1564) + padronização

---

### 19. Índice de Imobilização
- **Tipo**: Numérico (percentual)
- **Descrição**: Proporção de ativos permanentes (imobilizado) em relação ao Patrimônio de Referência
- **Formato Original**: Percentual brasileiro (vírgula decimal, símbolo %)
- **Fórmula**: (Ativo Permanente / Patrimônio de Referência) × 100%
- **Exemplos**:
  - "17,05%" (Itaú)
  - "16,47%" (BB)
- **Range observado**: 0% a 167.62%
- **Interpretação**:
  - < 30%: Baixa imobilização (ativos líquidos) ✓
  - 30-50%: Imobilização moderada ⚠️
  - > 50%: Acima do limite regulatório ❌ (requer ação corretiva)
  - > 100%: Situação irregular
- **Regulamentação**: Resolução CMN nº 2.669/1999
- **Limite regulatório**: 50%
- **Usado nas análises**: ✅ **SIM** (indicador de liquidez/risco)
- **Transformação**: Conversão para decimal (17,05% → 0.1705) + padronização

---

### 20. Número de Agências
- **Tipo**: Numérico (inteiro)
- **Descrição**: Quantidade de agências bancárias físicas da instituição, incluídas as sedes (exceto para cooperativas)
- **Fonte**: Dados operacionais reportados ao BCB (não é conta COSIF)
- **Formato Original**: Número inteiro separado por ponto (milhar)
- **Exemplos**:
  - 1.990 (Itaú)
  - 4.006 (BB - maior rede do Brasil)
  - 0 (mediana - maioria dos bancos!)
- **Range observado**: 0 a 4.006
- **Distribuição**:
  - Mediana = 0 (>50% dos bancos sem agências)
  - Média = 15.7
  - Assimetria extrema
- **Interpretação**:
  - 0: Banco digital, fintech, ou cooperativa sem rede própria
  - 1-100: Banco regional ou rede pequena
  - 100-1000: Grande rede regional/nacional
  - > 1000: Mega rede nacional (BB, Caixa, Bradesco)
- **Observações**: Para cooperativas, o critério de contagem pode diferir (excluídas as sedes administrativas)
- **Usado nas análises**: ✅ **SIM** (indicador de presença física/infraestrutura)
- **Transformação**: Conversão + padronização

---

### 21. Número de Postos de Atendimento
- **Tipo**: Numérico (inteiro)
- **Descrição**: Quantidade de postos de atendimento (PAB, PAE, PAA, etc.) além de agências
- **Fonte**: Dados operacionais reportados ao BCB (não é conta COSIF)
- **Formato Original**: Número inteiro separado por ponto (milhar)
- **Definição BCB** (tipos de postos incluídos):
  - **PAB**: Posto de Atendimento Bancário (dentro de empresa, shopping, etc.)
  - **PAE**: Posto de Atendimento Eletrônico (caixas automáticos)
  - **PAA**: Posto de Atendimento Avançado (áreas de difícil acesso)
- **Exemplos**:
  - 1.153 (Itaú)
  - 483 (BB)
  - 1 (mediana)
- **Range observado**: 0 a 1.544
- **Correlação com Agências**: r = 0.745 (alta mas não perfeita)
- **Usado nas análises**: ✅ **SIM**
- **Transformação**: Conversão + padronização

---

### 22. [Coluna Vazia]
- **Tipo**: Lógico (NA)
- **Descrição**: Coluna vazia sem nome, provavelmente artefato de exportação
- **Nome no R**: `...22` ou `x22`
- **Valores**: Todos NA (vazios)
- **Usado nas análises**: ❌ **NÃO** (removida na limpeza)

---

## Resumo: Variáveis Utilizadas nas Análises

### ✅ Variáveis Selecionadas (8 de 22):

| # | Nome Original | Nome Padronizado (R) | Tipo | Razão para Inclusão |
|---|--------------|---------------------|------|---------------------|
| 10 | Ativo Total | `ativo_total` | Financeiro | Tamanho do banco |
| 11 | Carteira de Crédito | `carteira_de_credito` | Financeiro | Atividade de crédito |
| 15 | Patrimônio Líquido | `patrimonio_liquido` | Financeiro | Solidez patrimonial |
| 16 | Lucro Líquido | `lucro_liquido` | Financeiro | Performance |
| 18 | Índice de Basileia | `indice_de_basileia` | Regulatório | Adequação de capital |
| 19 | Índice de Imobilização | `indice_de_imobilizacao` | Regulatório | Liquidez |
| 20 | Número de Agências | `numero_de_agencias` | Operacional | Infraestrutura |
| 21 | Postos de Atendimento | `numero_de_postos_de_atendimento` | Operacional | Rede distribuição |

### ❌ Variáveis Removidas (14 de 22):

| Nome | Razão para Remoção |
|------|-------------------|
| Instituição | Usada apenas para identificação (variável `bancos`) |
| Código, TCB, SR, TD, TC | Metadados, não analíticos |
| Cidade, UF | Não utilizadas (análise não geográfica) |
| Data | Todas observações do mesmo período |
| Títulos e Valores Mobiliários | Alta correlação com Ativo Total (r > 0.9) |
| Passivo Exigível | Redundante (Ativo - Patrimônio) |
| Captações | Alta correlação com Ativo Total |
| Patrimônio de Referência | Redundante com Patrimônio Líquido |
| [Coluna vazia] | Sem dados |

---

## Transformações Aplicadas

### 1. Limpeza de Nomes
```r
clean_names()  # janitor package
```
- Converte para snake_case
- Remove caracteres especiais
- Exemplo: "Ativo Total" → "ativo_total"

### 2. Conversão de Formato Brasileiro
```r
gsub("\\.", "", .)      # Remove pontos (separador de milhar)
gsub(",", ".", .)       # Vírgula → ponto (decimal)
gsub("%", "", .)        # Remove símbolo de percentual
as.numeric()            # Converte para numérico
```
- Exemplo: "15,64%" → 15.64 → 0.1564 (dividido por 100)

### 3. Remoção de Valores Ausentes
```r
filter(if_all(everything(), ~ . != "NI"))  # Remove "NI" (Não Informado)
na.omit()                                   # Remove NAs
```
- Retenção: 1,055 de 1,414 (74.6%)

### 4. Padronização (Z-scores)
```r
scale(df_limpo)
```
- Fórmula: z = (x - μ) / σ
- Resultado: média = 0, desvio padrão = 1
- **Crítico para**: PCA, K-Means (sensíveis à escala)

---

## Tipos de Instituições no Dataset

Baseado nas características dos dados:

### Por Tipo (TCB):
- **Bancos Múltiplos/Comerciais (b1)**: ~150 (Itaú, Bradesco, etc.)
- **Cooperativas de Crédito (cf)**: ~600 (Sicredi, Sicoob, etc.)
- **Bancos de Investimento (b2)**: ~30 (BTG, XP, etc.)
- **Bancos de Desenvolvimento (b3)**: ~10 (BNDES, agências de fomento)
- **Outros**: ~200 (fintechs, SCM, SCFI, etc.)

### Por Controle (TC):
- **Público Federal (1)**: ~10 (BB, Caixa, BNDES, etc.)
- **Privado Nacional (2)**: ~800 (Itaú, Bradesco, cooperativas, fintechs)
- **Privado Estrangeiro (3)**: ~40 (Santander, Citibank, HSBC, etc.)
- **Público Estadual (4)**: ~20 (Banrisul, BRB, etc.)

### Por Tamanho (Ativo Total):
- **Top 5** (> R$ 1 trilhão): Itaú, BB, Caixa, Bradesco, Santander
- **Grandes** (R$ 100bi - R$ 1tri): ~20 bancos
- **Médios** (R$ 10bi - R$ 100bi): ~50 bancos
- **Pequenos** (< R$ 10bi): ~980 bancos (93%)

---

## Qualidade e Limitações dos Dados

### ✅ Qualidade:
- **Fonte oficial**: Banco Central do Brasil (auditado)
- **Padronização**: Cosif (Plano Contábil das Instituições)
- **Completude**: Dados obrigatórios para instituições supervisionadas
- **Atualidade**: Março/2025 (recente)

### ⚠️ Limitações:
- **25.4% de perda**: 359 instituições removidas por dados incompletos ("NI")
- **Assimetria extrema**: Distribuições altamente concentradas (poucos gigantes)
- **Heterogeneidade**: Mistura bancos comerciais, cooperativas, fintechs, etc.
- **Valores negativos**: Legítimos mas complicam algumas análises (log impossível)
- **Outliers**: 12-16% são outliers legítimos (grandes bancos)

---

## Referências

### Regulamentações Citadas:
- **Resolução CMN nº 4.193/2013**: Índice de Basileia e adequação de capital
- **Resolução CMN nº 2.669/1999**: Índice de Imobilização
- **Cosif 2025**: Novo Plano Contábil das Instituições do SFN

### Documentação BCB:
- **IF.data Manual**: https://www3.bcb.gov.br/ifdata/
- **Glossário BCB**: Definições oficiais de termos bancários
- **Relatórios de Estabilidade Financeira**: Contexto do setor bancário brasileiro

---

**Documento Criado**: 2025-11-15
**Última Atualização**: 2025-11-15
**Versão**: 1.0
