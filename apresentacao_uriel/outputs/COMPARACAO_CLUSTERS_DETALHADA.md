# Comparação Detalhada: Clustering Com vs Sem Outliers

**Data**: 2025-11-15

---

## Visão Geral das Análises

### Análise 05: Sem Big 5 (K=2)

- **N**: 1,050 bancos
- **Outliers removidos**: Big 5 (BB, Bradesco, Caixa, Itaú, Santander)
- **K**: 2 clusters
- **Silhueta**: 0.968 (excepcional)

### Análise 07: Sem Big 7 + Outliers (K=5)

- **N**: 1,046 bancos
- **Outliers removidos**: Big 7 + RV2 SEP + VUON SCD (9 bancos)
- **K**: 5 clusters
- **Silhueta**: 0.389 (fraco ⚠️)

---

## Análise 05 (K=2): Estrutura Simples

### Visualização

**Plot**: `05_kmeans_plot.pdf`

**O que vemos**:
- **Cluster 1** (vermelho): Nuvem densa à direita (PC1 ≈ 0)
- **Cluster 2** (azul): 2 pontos isolados à esquerda (PC1 ≈ -50)

### Clusters Identificados

#### Cluster 1: "Bancos Normais" (N=1,048 - 99.8%)

**Centróide**:
- Ativo: R$ 4.1 milhões
- Agências: 2.4
- Basileia: 60%

**Composição**: TODOS os bancos exceto BNDES e BTG Pactual

#### Cluster 2: "Grandes Especializados" (N=2 - 0.2%)

**Bancos**:
1. **BNDES** - Banco de desenvolvimento (ativo R$ 716 bilhões)
2. **BTG Pactual** - Banco de investimento (ativo R$ 716 bilhões)

**Centróide**:
- Ativo: R$ 716 bilhões (173x maior que Cluster 1)
- Agências: 35
- Basileia: 22%

### Problema da Análise 05

**BNDES e BTG são outliers tão grandes** quanto os Big 5 foram na análise original!
- Mesmo sem Big 5, ainda há separação extrema (Silhueta 0.968)
- Cluster 1 permanece heterogêneo (mistura médios e pequenos)

---

## Análise 07 (K=5): Estrutura Detalhada

### Visualização

**Plot**: `07_kmeans_K5.pdf`

**O que vemos**:
- **Cluster 1** (vermelho, 8 pontos): Esquerda superior (PC1 ~ -20, PC2 ~ 0)
- **Cluster 2** (azul, 1 ponto): Isolado (outlier)
- **Cluster 3** (verde, 33 pontos): Distribuído (PC1 ~ -10 a 0, PC2 variado)
- **Cluster 4** (roxo, 257 pontos): Direita, PC2 alto (PC1 ~ 0, PC2 ~ 1 a 3)
- **Cluster 5** (laranja, 747 pontos): Massa principal à direita (PC1 ~ 0, PC2 ~ -1 a 1)

### Clusters Identificados (K=5)

#### Cluster 1: "Bancos Médios - Escala Nacional" (N=8 - 0.8%)

**Centróide**:
- Ativo: R$ **161 milhões** (79x maior que Cluster 5)
- Carteira Crédito: R$ 57 milhões
- Agências: **141.9** (muito maior)
- Basileia: **14.9%** (alavancados, como Big 5)
- Imobilização: 14.7%

**Bancos identificados**:
1. **BANCO C6** - Fintech grande
2. **BANRISUL** - Regional público (RS)
3. **BCO DAYCOVAL S.A** - Privado médio
4. **BCO DO NORDESTE DO BRASIL S.A.** - Regional público (NE)
5. **CITIBANK** - Estrangeiro
6. **SAFRA** - Privado médio tradicional
7. **VOTORANTIM** - Grupo industrial
8. **XP** - Fintech/Corretora

**Interpretação**:
Este é o **"middle market" de alto nível**:
- Bancos com escala regional/nacional
- 100-200 agências (vs 2,800 dos Big 5, vs 2 dos pequenos)
- Mix de: fintechs grandes (C6, XP), regionais públicos (Banrisul, BNE), privados médios (Safra, Votorantim, Daycoval), estrangeiro (Citi)

**Perfil**: "Segunda linha" bancária - competem abaixo dos Big 7, mas têm escala significativa.

---

#### Cluster 2: "Outlier Operacional" (N=1 - 0.1%)

**Banco**: **CREFISA S.A. CFI**

**Centróide**:
- Ativo: R$ 8.9 milhões (pequeno)
- Agências: 4
- **Postos**: **1,062** (!!!) ← ANOMALIA
- Basileia: 60.5%

**Interpretação**:
CREFISA tem estrutura **completamente atípica**:
- Pouquíssimas agências formais (4)
- Enorme rede de correspondentes/postos (1,062)
- Modelo de negócio baseado em capilaridade (crédito consignado?)

**Conclusão**: Outlier operacional, não representa cluster. Deveria ser removido.

---

#### Cluster 3: "Bancos Médios - Regional/Cooperativo" (N=33 - 3.2%)

**Centróide**:
- Ativo: R$ **46 milhões** (23x maior que Cluster 5)
- Agências: **22.2** (10x mais que Cluster 5)
- Basileia: **19.5%** (moderadamente alavancados)
- Postos: 31

**Bancos identificados** (amostra):
- **ABC-BRASIL** - Privado médio
- **AGIBANK** - Fintech/banco médio
- **BANCOOB** - Cooperativa grande (nacional)
- **BANESTES** - Regional público (ES)
- **BCO COOPERATIVO SICREDI** - Cooperativa grande (nacional)
- **BCO DA AMAZONIA S.A.** - Regional público (Norte)
- **BCO DO EST. DO PA S.A.** - Regional (Pará)
- **BRB** - Regional público (DF)
- **INTER** - Fintech grande
- **BMG** - Privado médio
- **JP MORGAN CHASE** - Estrangeiro (investimento)
- **GOLDMAN SACHS** - Estrangeiro (investimento)
- **MORGAN STANLEY** - Estrangeiro (investimento)
- **Montadoras**: GM, Honda, Mercedes-Benz, Volkswagen, Volvo, Stellantis
- **Porto Seguro** - Seguradora/banco

**Interpretação**:
Este é o **"middle market amplo"**:
- Mix diverso: cooperativas grandes, regionais públicos, fintechs médias, bancos de montadoras, estrangeiros médios
- Escala intermediária (20-100 agências)
- Basileia ~20% (mais conservadores que Cluster 1, mas não tanto quanto pequenos)

**Perfil**: "Terceira linha" - bancos com presença regional ou nichos específicos.

---

#### Cluster 4: "Pequenos Alavancados / Digitais" (N=257 - 24.6%)

**Centróide**:
- Ativo: R$ **2.0 milhões**
- Agências: **0.4** (maioria digital/sem agências!)
- Basileia: **12.0%** ⚠️ (BAIXO - próximo ao mínimo!)
- Postos: 19.6
- Imobilização: **15.8%** (alta para bancos pequenos)

**Bancos identificados** (amostra dos primeiros 20):
- **SCDs** (Sociedades de Crédito Direto): ALL IN CRED, ARTTA, CDC, etc.
- **Fintechs pequenas**: BANCO DIGIMAIS, BS2
- **Bancos digitais/sem agências**
- **BCO DO EST. DE SE S.A.** - Regional (Sergipe)
- **BCO LUSO BRASILEIRO S.A.**

**Interpretação**:
Este cluster é **SURPREENDENTE**:
- Bancos **pequenos MAS alavancados** (Basileia apenas 12%!)
- **Modelo digital** (média de 0.4 agências = quase zero)
- **Alta imobilização** (15.8%) para bancos sem agências físicas (TI/software?)
- **Perfil de risco diferente** dos bancos pequenos conservadores

**Perfil**: "Fintechs e digitais agressivos" - pequenos em escala, mas com estratégia alavancada (contraintuitivo!).

---

#### Cluster 5: "Pequenos Conservadores / Tradicionais" (N=747 - 71.4%)

**Centróide**:
- Ativo: R$ **1.2 milhões** (MENOR de todos)
- Agências: **0.8** (quase nenhuma)
- Basileia: **71.5%** ⚠️ (ALTÍSSIMO - 6x acima do mínimo!)
- Postos: 4.0
- Imobilização: **2.7%** (muito baixa)

**Composição**: Maioria são cooperativas de crédito pequenas (Sicredi, Sicoob regionais)

**Interpretação**:
Esta é a verdadeira **"cauda longa"**:
- **Bancos menores** de todos
- **Extremamente conservadores** (Basileia 71% - sem alavancagem)
- **Infraestrutura mínima** (< 1 agência em média)
- **Cooperativas locais/regionais**
- **Modelo tradicional de poupança** (baixo risco, baixo retorno)

**Perfil**: "Bancos pequenos tradicionais" - priorizam segurança sobre crescimento.

---

## Comparação: K=2 (Análise 05) vs K=5 (Análise 07)

### Análise 05 (K=2): "Visão Macro"

**Divisão**: Gigantes (BNDES + BTG) vs Resto

**Vantagem**: Silhueta 0.968 (perfeita separação)

**Desvantagem**: Cluster 1 (1,048) é **extremamente heterogêneo** - mistura:
- Bancos médios de 141 agências (C6, Safra, XP)
- Cooperativas nacionais (Sicredi, Bancoob)
- SCDs sem agências
- Micro-cooperativas locais

**Conclusão**: Identifica outliers, mas não revela estrutura interna.

---

### Análise 07 (K=5): "Visão Detalhada"

**Divisão**: 5 camadas de tamanho/alavancagem

**Vantagem**: Revela **estrutura interna** fascinante:
1. Médios grandes (8) - C6, XP, Safra, Banrisul, etc.
2. CREFISA (outlier)
3. Médios regionais (33) - Cooperativas, montadoras, regionais
4. **Pequenos alavancados** (257) - SCDs, digitais com Basileia 12%
5. **Pequenos conservadores** (747) - Cooperativas locais, Basileia 71%

**Desvantagem**: Silhueta 0.389 (fraca) - clusters se sobrepõem parcialmente

**Conclusão**: Estrutura mais rica, mas estatisticamente menos robusta.

---

## Principais Descobertas da Comparação

### 1. Cluster 1 da Análise 07 ≈ "Middle Market Top Tier"

**8 bancos** que emergiram como cluster separado:
- C6, XP (fintechs grandes)
- Safra, Votorantim, Daycoval (privados médios)
- Banrisul, BNE (regionais públicos)
- Citibank (estrangeiro)

**Características distintivas**:
- 140+ agências (vs 20-30 do Cluster 3, vs 0.4-0.8 dos Clusters 4-5)
- Basileia 15% (alavancados como Big 5)
- **Ativo R$ 161 milhões** (79x maior que Cluster 5)

**Interpretação**: São a "segunda linha" que compete nacionalmente. Na Análise 05, estavam **misturados** com 1,048 outros bancos.

---

### 2. Descoberta Surpreendente: Cluster 4 (Pequenos Alavancados)

**257 bancos** com perfil **contra-intuitivo**:
- **Pequenos** (Ativo R$ 2 milhões)
- **MAS alavancados** (Basileia apenas 12% - próximo ao mínimo!)
- **Digitais** (0.4 agências em média)
- **Alta imobilização** (15.8% - investimento em TI?)

**Composição**:
- SCDs (Sociedades de Crédito Direto)
- Fintechs pequenas
- Bancos digitais novos

**Interpretação**:
São **"growth-oriented fintechs"** - sacrificam capital (Basileia baixa) para crescer rápido.

**Contraste com Cluster 5** (conservadores):
- Cluster 4: Basileia 12%, estratégia agressiva
- Cluster 5: Basileia 71%, estratégia conservadora

**ACHADO CRÍTICO**: Dentro dos bancos pequenos, há **2 filosofias opostas**:
1. **Cluster 4**: Alavancagem e crescimento (modelo fintech)
2. **Cluster 5**: Segurança e conservadorismo (modelo cooperativa)

---

### 3. Cluster 3: "Middle Market Amplo"

**33 bancos** com características intermediárias:
- Ativo R$ 46 milhões (23x maior que pequenos)
- 20-30 agências (escala regional)
- Basileia 19.5% (moderado)

**Composição diversa**:
- Cooperativas nacionais (Bancoob, Sicredi central)
- Regionais públicos (Banco da Amazônia, Banco do Pará)
- Bancos de montadoras (GM, Honda, Mercedes, VW, Volvo)
- Estrangeiros médios (JP Morgan, Goldman Sachs, Morgan Stanley)
- Privados médios (ABC, Agibank, BMG, Inter)
- Seguradora (Porto Seguro)

**Interpretação**: "Terceira linha" - bancos especializados ou regionais com presença estabelecida.

---

### 4. Cluster 5: "Cauda Longa Tradicional"

**747 bancos** (71% do dataset):
- **Menores de todos** (Ativo R$ 1.2 milhão)
- **Extremamente conservadores** (Basileia 71% - 7x acima do mínimo!)
- **Infraestrutura mínima** (< 1 agência)

**Composição**: Majoritariamente **cooperativas de crédito locais** (Sicredi e Sicoob regionais)

**Exemplos** (nomes longos típicos de cooperativas):
- "Cooperativa Poupança e Investimento Aliança - Sicredi Aliança PR/SP"
- "Cooperativa de Crédito Rural dos Profissionais da Saúde..."
- Centenas de cooperativas municipais/regionais

**Interpretação**: Base do sistema cooperativo brasileiro - entidades locais, membros específicos, operação conservadora.

---

## Comparação Lado a Lado

| Aspecto | Análise 05 (K=2) | Análise 07 (K=5) |
|---------|------------------|------------------|
| **Silhueta** | 0.968 (excelente) | 0.389 (fraco) |
| **Interpretação** | Simples | Rica |
| **Clusters úteis** | 1 (Cluster 2 são outliers) | 4-5 (Cluster 2 é outlier) |
| **Revelações** | BNDES/BTG são grandes | 5 camadas de tamanho/estratégia |
| **Limitação** | Cluster 1 muito heterogêneo | Clusters 3-5 se sobrepõem |

---

## Estrutura Completa do Setor Bancário Brasileiro

### Camada 0: Big 5 - Oligopólio Dominante
- **N**: 5 bancos (0.5%)
- **Ativo médio**: R$ 2 trilhões
- **Agências**: 2,800
- **Basileia**: 15%
- **Bancos**: BB, Bradesco, Caixa, Itaú, Santander

### Camada 1: Grandes Especializados
- **N**: 2 bancos (0.2%)
- **Ativo médio**: R$ 716 bilhões
- **Bancos**: BNDES (desenvolvimento), BTG Pactual (investimento)

### Camada 2: Middle Market Top Tier
- **N**: 8 bancos (0.8%) ← **CLUSTER 1 da Análise 07**
- **Ativo médio**: R$ 161 milhões
- **Agências**: 140
- **Basileia**: 15%
- **Bancos**: C6, XP, Safra, Votorantim, Banrisul, BNE, Daycoval, Citibank

### Camada 3: Middle Market Amplo
- **N**: 33 bancos (3.2%) ← **CLUSTER 3 da Análise 07**
- **Ativo médio**: R$ 46 milhões
- **Agências**: 22
- **Basileia**: 19.5%
- **Tipos**: Cooperativas grandes, regionais, montadoras, estrangeiros médios

### Camada 4: Pequenos Alavancados (Growth-Oriented)
- **N**: 257 bancos (24.6%) ← **CLUSTER 4 da Análise 07**
- **Ativo médio**: R$ 2 milhões
- **Agências**: 0.4 (digitais)
- **Basileia**: **12%** (BAIXO - agressivos)
- **Tipos**: SCDs, fintechs pequenas, digitais

### Camada 5: Pequenos Conservadores (Cauda Longa)
- **N**: 747 bancos (71.4%) ← **CLUSTER 5 da Análise 07**
- **Ativo médio**: R$ 1.2 milhão
- **Agências**: 0.8
- **Basileia**: **71%** (MUITO ALTO - conservadores)
- **Tipos**: Cooperativas locais, Sicredi/Sicoob regionais

### Outliers Operacionais
- **N**: 1 banco (CREFISA)
- 1,062 postos de atendimento vs 4 agências (estrutura única)

---

## Insights Comparativos

### Insight 1: Gradiente de Alavancagem Inverso ao Tamanho

| Camada | Tamanho | Basileia Médio |
|--------|---------|----------------|
| Big 5 | Gigantes | 15% (alta alavancagem) |
| Middle Top (C1) | Médios grandes | 15% |
| Middle Amplo (C3) | Médios | 19.5% |
| **Pequenos Alavancados (C4)** | Pequenos | **12%** ⚠️ |
| **Pequenos Conservadores (C5)** | Pequenos | **71%** |

**Padrão geral**: Bancos maiores são mais alavancados

**EXCEÇÃO**: Cluster 4 (SCDs/fintechs) - pequenos MAS alavancados (12%)!

**Interpretação**:
- **Modelo tradicional** (Cluster 5): Pequenos = conservadores
- **Modelo fintech** (Cluster 4): Pequenos = agressivos para crescer

---

### Insight 2: Modelo de Negócio vs Tamanho

**Cluster 1 vs Cluster 3** (ambos "médios"):
- **Cluster 1** (8 bancos): Maior escala (141 agências), mais alavancados (15%), nacionais
- **Cluster 3** (33 bancos): Menor escala (22 agências), moderados (19.5%), regionais/especializados

**Diferença**: Cluster 1 compete nacionalmente, Cluster 3 opera em nichos.

**Cluster 4 vs Cluster 5** (ambos "pequenos"):
- **Cluster 4** (257): Digitais (0.4 agências), alavancados (12%), crescimento
- **Cluster 5** (747): Tradicionais (0.8 agências), conservadores (71%), estabilidade

**Diferença**: Filosofia de risco oposta.

---

## Qual Análise Usar?

### Para Relatório Final

**Recomendação**: Apresentar **AMBAS**

#### Seção 1: Análise Completa (N=1,055, K=2)
- **Foco**: Concentração extrema (Big 7 vs Resto)
- **Plot**: 04_kmeans_classico_nomes.pdf (Big 5 separados)
- **Mensagem**: "5 bancos dominam 80% do mercado"

#### Seção 2: Análise sem Big 7 (N=1,046, K=3 ou K=5)

**Opção A**: K=3 (Silhueta 0.785 - bom)
- Cluster 1: Médios grandes (8-15)
- Cluster 2: Médios amplos (15-33)
- Cluster 3: Pequenos (1,000+)

**Opção B**: K=5 (Silhueta 0.389 - fraco, mas informativo)
- Revelar 5 camadas completas
- **Destacar**: Cluster 4 (Pequenos alavancados) vs Cluster 5 (Pequenos conservadores)

### Recomendação Final

**K=3 para relatório principal**:
- Silhueta melhor (0.785)
- Interpretação clara
- 3 clusters é número pedagógico

**K=5 para análise exploratória / apêndice**:
- Riqueza de insights (5 camadas)
- Descoberta do Cluster 4 (pequenos alavancados)
- Trade-off: profundidade vs robustez estatística

---

## Resumo Executivo

### O que Análise 05 (sem Big 5) nos diz:
"Há 2 bancos gigantes especializados (BNDES, BTG) e 1,048 outros"

### O que Análise 07 (sem Big 7, K=5) nos diz:
"Dos 1,046 bancos restantes, há uma estrutura em 5 camadas:
1. **8 médios nacionais** (C6, XP, Safra) - competem nacionalmente
2. **33 médios regionais** (cooperativas grandes, regionais, montadoras)
3. **257 pequenos alavancados** (SCDs, fintechs agressivas, Basileia 12%)
4. **747 pequenos conservadores** (cooperativas locais, Basileia 71%)
5. **1 outlier operacional** (CREFISA - 1,062 postos)"

### Achado Mais Interessante

**Pequenos não são homogêneos!**

Há **2 filosofias** entre bancos pequenos:
- **Cluster 4**: Digitais, alavancados, crescimento (modelo startup)
- **Cluster 5**: Tradicionais, conservadores, estabilidade (modelo cooperativa)

**Basileia médio**: 12% vs 71% (6x de diferença!)

---

**Status**: Comparação completa. Estrutura do setor totalmente revelada.
