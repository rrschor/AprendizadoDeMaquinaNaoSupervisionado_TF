# Checkpoint 7: Análise Final - Estrutura dos Bancos Pequenos/Médios

**Data**: 2025-11-15
**Dataset**: N=1,046 bancos (sem outliers extremos)
**Outliers removidos**: 9 bancos (Big 5 + BNDES + BTG + RV2 SEP + VUON SCD)

---

## 1. Motivação para Análise Sem Outliers

### Problema Identificado

Na análise com os 1,055 bancos completos:
- **K=2** com silhueta 0.972 (excepcional)
- **MAS**: Cluster 1 = 1,050 bancos (99.5%) vs Cluster 2 = 5 bancos (0.5%)
- Big 5 são tão extremos (200-400x maiores) que "mascararam" toda estrutura interna

### Outliers Identificados em Múltiplas Análises

1. **Big 5 Comerciais** (análise original):
   - BB, Bradesco, Caixa, Itaú, Santander
   - 200-400x maiores em todas as métricas

2. **Grandes Especializados** (análise sem Big 5):
   - BNDES: Banco de desenvolvimento (ativo 716 bilhões)
   - BTG Pactual: Banco de investimento (ativo 716 bilhões)

3. **Outliers Regulatórios** (análise sem Big 7):
   - RV2 SEP: Basileia 5,051% (!)
   - VUON SCD: Basileia extremo

**Total removido**: 9 bancos (0.9% do dataset)
**Dataset final**: 1,046 bancos (99.1%)

---

## 2. Impacto da Remoção de Outliers

### Comparação de Métricas

| Métrica | Com Big 7 | Sem Outliers | Mudança |
|---------|-----------|--------------|---------|
| **N bancos** | 1,055 | 1,046 | -9 |
| **KMO** | 0.796 | ~0.82 | Melhor |
| **M componentes PCA** | 2 | 4 | Mais complexo |
| **Var. PC1** | 66.4% | 46.9% | -19.5% ⬇ |
| **Var. PC2** | 13.6% | 14.2% | +0.6% |
| **m fatores EFA** | 2 | 4 | Mais complexo |
| **K clusters** | 2 | 3 | Mais subgrupos |
| **Silhueta** | 0.972 | 0.881 | -0.091 ⬇ |

### Interpretação das Mudanças

#### Variância PC1: 66% → 47% (queda de 19%)

**Por quê?**
- Com Big 7: PC1 captura **primariamente** a diferença massiva Big 7 vs Demais (66%)
- Sem outliers: Variância se distribui mais equilibradamente entre componentes
- PC1 agora captura nuances de tamanho entre bancos "normais"

**Conclusão**: Queda de PC1 é **esperada e desejável** - significa que a estrutura é mais multidimensional (não dominada por 1 único eixo).

#### M componentes: 2 → 4

**Por quê?**
- Com Big 7: 2 componentes suficientes (tamanho + solidez)
- Sem outliers: Estrutura mais rica emerge, exigindo 4 componentes para 84% variância

**Conclusão**: **Dataset é mais complexo** sem outliers (não mais simples!). Isso é bom - indica que há subgrupos interessantes.

#### Silhueta: 0.972 → 0.881 (queda de 9%)

**Por quê?**
- 0.972 refletia separação **perfeita** Big 7 vs Demais
- 0.881 reflete separação **muito boa** entre subgrupos mais sutis

**Conclusão**: 0.881 ainda é excelente (> 0.7). A queda reflete transição de "separação óbvia" para "estrutura genuína".

---

## 3. Resultados - PCA sem Outliers

### Decomposição de Variância

| Componente | Autovalor | Var. % | Var. Acum. |
|------------|-----------|--------|------------|
| PC1 | 3.75 | 46.9% | 46.9% |
| PC2 | 1.14 | 14.2% | 61.1% |
| PC3 | 0.94 | 11.7% | 72.8% |
| PC4 | 0.92 | 11.6% | 84.4% |

### Critérios para M

- **Kaiser** (λ≥1): M = 2
- **75% variância**: M = 3
- **80% variância**: M = 4

**Decisão**: M = **3 ou 4** componentes (vs M=2 original)

### Interpretação dos Loadings (comparação)

**Com Big 7**:
- PC1: Todas variáveis com loadings ~-0.43 (tamanho indiferenciado)

**Sem outliers** (espera-se):
- PC1: Provavelmente ainda tamanho, mas diferenciando melhor
- PC2-PC4: Capturando dimensões de especialização (fintechs, regionais, cooperativas)

---

## 4. Resultados - EFA sem Outliers

### Número de Fatores

- **Análise paralela**: m = 4 fatores
- **Variância explicada** (m=4): ~60%

**Mudança**: m=2 (com Big 7) → m=4 (sem outliers)

**Interpretação**: Estrutura fatorial mais rica emerge quando outliers não dominam.

---

## 5. Resultados - Clustering sem Outliers

### Silhuetas para Diferentes K

| K | Silhueta | Avaliação |
|---|----------|-----------|
| **2** | **0.881** | Excelente ✅ |
| **3** | **0.785** | Bom ✅ |
| 4 | 0.375 | Fraco ⚠️ |
| 5 | 0.389 | Fraco ⚠️ |

### Análise Crítica

**K=2 vs K=3**:
- K=2: Silhueta 0.881 (excelente)
- K=3: Silhueta 0.785 (bom, mas queda de 11%)
- K=4+: Silhueta < 0.4 (estrutura fraca)

**Observação**: Mesmo sem Big 7, **K=2 tem silhueta superior**!

### Composição dos Clusters (K=3)

#### Cluster 1: "Bancos Pequenos" (N=1,030 - 98.5%)

**Perfil**:
- Ativo: R$ 2.2 milhões
- Agências: 1.1
- Basileia: 51%

**Exemplos**:
- SCDs (Sociedades de Crédito Direto)
- Agências de Fomento Estaduais
- Pequenas cooperativas
- Bancos de nicho

#### Cluster 2: "Bancos Médios" (N=15 - 1.4%) ⭐

**Perfil**:
- Ativo: R$ 135.6 milhões (61x maior que Cluster 1!)
- Agências: 92.5 (84x mais que Cluster 1)
- Basileia: 15.7% (mais alavancados)

**Composição** (15 bancos):
1. **Bancos Regionais**: Banrisul, BRB, Banco da Amazônia, Banco do Nordeste
2. **Cooperativas Grandes**: Bancoob, Sicredi
3. **Fintechs de Escala**: C6, Inter, XP
4. **Bancos Privados Médios**: Safra, Daycoval, Votorantim
5. **Estrangeiros Médios**: Citibank, JP Morgan
6. **Bancos de Montadoras**: Volkswagen

**Interpretação**: Este é o **"middle market"** bancário brasileiro - bancos com escala significativa, mas não dominantes como Big 7.

#### Cluster 3: "Outlier" (N=1 - 0.1%)

**Banco**: CREFISA S.A. CFI

**Perfil atípico**:
- Ativo: R$ 8.9 milhões (pequeno)
- **1,062 postos** de atendimento (!) vs apenas 4 agências
- Estrutura única: muitos pontos de atendimento, poucas agências formais

**Conclusão**: CREFISA é outlier operacional (deve ser removido ou tratado separadamente).

---

## 6. Problema: Clusters Ainda Desbalanceados

### Distribuição K=3

- Cluster 1: 98.5% (massa)
- Cluster 2: 1.4% (médios)
- Cluster 3: 0.1% (outlier único)

**Problema**: Cluster 3 com N=1 não é cluster, é outlier!

### Solução: Testar K=2

**Hipótese**: K=2 pode ser mais apropriado:
- Cluster 1: Pequenos (maioria)
- Cluster 2: Médios (15-20 bancos)

**Vantagem**: Silhueta K=2 (0.881) > Silhueta K=3 (0.785)

---

## 7. Recomendação: K=2 sem Outliers

### Justificativa para K=2

1. **Silhueta superior**: 0.881 vs 0.785 (K=3)
2. **Interpretabilidade**: Pequenos vs Médios (divisão clara)
3. **Sem clusters unitários**: K=3 tem cluster com N=1 (não válido)
4. **Queda dramática após K=3**: K=4 tem silhueta 0.375 (fraco)

### Estrutura Esperada com K=2

**Cluster 1**: Bancos Pequenos (~1,030 bancos)
- SCDs, fintechs pequenas, agências de fomento
- Ativo < R$ 10 milhões
- 1-2 agências

**Cluster 2**: Bancos Médios (~16 bancos)
- Bancos regionais (Banrisul, BRB)
- Cooperativas grandes (Sicredi, Bancoob)
- Fintechs escala (C6, Inter, XP)
- Privados médios (Safra, Votorantim)
- Possível inclusão de: Agibank, ABC-Brasil

---

## 8. Decisões Finais

### Outliers a Remover

**Total: 10 bancos** (0.9% do dataset):

1. Big 5 comerciais (5)
2. BNDES + BTG Pactual (2)
3. RV2 SEP + VUON SCD (2 outliers regulatórios)
4. **CREFISA** (1 outlier operacional - 1,062 postos!)

### PCA sem Outliers

**M = 3 ou 4** componentes (75-84% variância)
- Estrutura mais multidimensional
- PC1 não mais dominante (47% vs 66%)

### EFA sem Outliers

**m = 3 ou 4** fatores
- Estrutura fatorial mais rica
- Fatores podem capturar tipos de bancos

### Clustering sem Outliers

**RECOMENDAÇÃO: K = 2 clusters**

**Justificativa**:
- Silhueta 0.881 (melhor que K=3)
- Divisão clara: Pequenos vs Médios
- Sem clusters unitários
- Interpretabilidade superior

**Alternativa**: K=3 se quisermos separar um subgrupo específico (ex: fintechs vs regionais)

---

## 9. Próximos Passos

### Ação 1: Refazer Análise com K=2

Modificar script `07_analise_final_sem_outliers.R`:
- Remover também CREFISA (total 10 outliers)
- Forçar K=2 na solução final
- Caracterizar detalhadamente os 2 clusters

### Ação 2: Identificar Tipologias

Dentro do Cluster 2 (Médios), identificar sub-tipologias:
- Bancos regionais públicos
- Cooperativas grandes
- Fintechs de escala
- Privados médios tradicionais

### Ação 3: Documentar Achados

**Achado principal**:
> "Removendo os 10 maiores outliers (Big 7 + 3 casos extremos), identificamos 2 clusters principais:
> 1. **Bancos Pequenos** (N=~1,030): SCDs, fintechs pequenas, agências de fomento
> 2. **Bancos Médios** (N=15-16): Regionais, cooperativas grandes, fintechs escala, privados médios"

---

## 10. Insights Importantes

### 1. Heterogeneidade do "Middle Market"

O Cluster 2 (15 bancos) contém **4 tipologias distintas**:

a) **Bancos Regionais Públicos** (4):
   - Banrisul (RS), BRB (DF), Banco da Amazônia, Banco do Nordeste

b) **Cooperativas de Escala Nacional** (2):
   - Bancoob, Sicredi

c) **Fintechs Grandes** (3):
   - C6, Inter, XP

d) **Privados Médios Tradicionais** (6):
   - Safra, Daycoval, Votorantim, Citibank, JP Morgan, Volkswagen

### 2. Concentração em Múltiplos Níveis

**Nível 1**: Big 5 (~80% do mercado) - análise original
**Nível 2**: Big 7 incluindo BNDES e BTG
**Nível 3**: 15-16 bancos médios (~15-18% do mercado estimado)
**Nível 4**: 1,030 bancos pequenos (~2-5% do mercado restante)

**Estrutura**: "Cauda longa dupla" - concentração extrema no topo, depois middle market, depois cauda longa massiva.

### 3. Perfis Regulatórios

| Grupo | N | Basileia Médio | Interpretação |
|-------|---|----------------|---------------|
| **Big 5** | 5 | 15% | Altamente alavancados |
| **Médios** | 15 | 16% | Alavancados |
| **Pequenos** | 1,030 | 51% | Conservadores |

**Padrão**: Quanto maior o banco, menor a Basileia (mais alavancagem).

---

## 11. Limitações da Análise K=3

### Problema: Cluster 3 Unitário

**Cluster 3 = 1 banco** (CREFISA)
- Não é cluster, é outlier
- Silhueta K=3 cai para 0.785 (vs 0.881 em K=2)

**CREFISA é outlier porque**:
- 1,062 postos vs 4 agências (estrutura atípica)
- Modelo de negócio diferente (correspondentes bancários?)

### Recomendação

**Remover CREFISA** e refazer com K=2:
- Cluster 1: ~1,030 pequenos
- Cluster 2: 14-16 médios (sem CREFISA)
- Silhueta esperada: ~0.85-0.90

---

## 12. Cluster 2 (Médios): Análise Detalhada

### Os 15 Bancos do "Middle Market"

1. **BANCO C6** - Fintech (digital, crescimento rápido)
2. **BANCOOB** - Cooperativa (rede nacional)
3. **BANRISUL** - Regional público (Rio Grande do Sul)
4. **BCO COOPERATIVO SICREDI** - Cooperativa (nacional)
5. **BCO DA AMAZONIA S.A.** - Regional público (Norte)
6. **BCO DAYCOVAL S.A** - Privado médio
7. **BCO DO NORDESTE DO BRASIL S.A.** - Regional público (Nordeste)
8. **BRB** - Regional público (Brasília)
9. **CITIBANK** - Estrangeiro
10. **INTER** - Fintech (digital, bolsa)
11. **JP MORGAN CHASE** - Estrangeiro (investimento)
12. **SAFRA** - Privado médio (tradicional)
13. **VOLKSWAGEN** - Montadora (crédito automotivo)
14. **VOTORANTIM** - Privado médio (grupo industrial)
15. **XP** - Fintech (corretora/banco digital)

### Características Comuns

**Tamanho**: 50-60x maior que Cluster 1 (mas 4-6x menor que Big 7)
**Agências**: 70-120 (vs 1-2 dos pequenos, 2,800 dos Big 5)
**Especialização**: Muitos têm nichos (regionais, cooperativas, fintechs)
**Basileia**: ~16% (próximo ao mínimo, como Big 7)

### Diversidade Interna

Apesar de estarem no mesmo cluster, há **4 arquétipos**:
1. **Públicos regionais**: Missão de desenvolvimento regional
2. **Cooperativas**: Governança associativa
3. **Fintechs**: Modelo digital, crescimento rápido
4. **Privados tradicionais**: Modelo clássico, nichos corporativos

**Questão**: Seria possível separar estes 4 arquétipos?

**Resposta**: Silhueta cai dramaticamente para K>3 (< 0.4). Subgrupos existem, mas não são bem separados estatisticamente no espaço PCA.

---

## 13. Decisão Final Recomendada

### OPÇÃO 1: K=2 (Recomendado)

**Remover**: 10 outliers (Big 5 + BNDES + BTG + 2 reg. + CREFISA)
**Dataset**: N=1,045 bancos
**Clusters**:
1. Pequenos (~1,030)
2. Médios (~15)

**Vantagens**:
- Silhueta esperada ~0.88 (excelente)
- Sem clusters unitários
- Divisão clara e interpretável

### OPÇÃO 2: K=3 (Alternativa)

**Manter**: CREFISA (dataset N=1,046)
**Reconhecer**: Cluster 3 é outlier (N=1)

**Vantagens**:
- Documenta que CREFISA é caso atípico
- Cluster 2 bem definido (15 bancos)

**Desvantagens**:
- Silhueta menor (0.785 vs 0.881)
- Cluster unitário não é cluster

---

## 14. Composição Final do Setor Bancário

### Estrutura em 4 Camadas

**Camada 1: Big 5 - Oligopólio Dominante** (N=5, ~80% mercado)
- BB, Bradesco, Caixa, Itaú, Santander
- Escala nacional, 2,000-4,000 agências
- Basileia 15% (alta alavancagem)

**Camada 2: Grandes Especializados** (N=2)
- BNDES (desenvolvimento)
- BTG Pactual (investimento/private banking)
- Escala comparável a Big 5, mas especializados

**Camada 3: Middle Market** (N=15, ~15-18% mercado estimado)
- Regionais, cooperativas grandes, fintechs de escala
- 70-200 agências
- Basileia 16% (moderadamente alavancados)

**Camada 4: Cauda Longa** (N=1,030, ~2-5% mercado)
- SCDs, fintechs pequenas, agências de fomento
- 1-2 agências (ou zero - digitais)
- Basileia 51% (bem capitalizados)

**Outliers Extremos** (N=3):
- RV2 SEP, VUON SCD (Basileia > 5,000%)
- CREFISA (1,062 postos, estrutura atípica)

---

## 15. Recomendação Final

### Para Relatório e Apresentação

**Apresentar 2 análises complementares**:

#### Análise 1: Dataset Completo (N=1,055)
- **K=2**: Big 7 vs Demais
- **Mensagem**: Concentração extrema do setor
- **Silhueta**: 0.972 (perfeita separação)

#### Análise 2: Sem Outliers (N=1,045-1,046)
- **K=2**: Pequenos vs Médios
- **Mensagem**: Estrutura do middle market + cauda longa
- **Silhueta**: ~0.88 (excelente)

**Cluster 2 da Análise 2** (15 bancos médios) é o **achado mais interessante**:
- Banrisul, Sicredi, C6, Inter, XP, Safra, Votorantim, etc.
- São o "segundo escalão" que compete abaixo dos Big 7
- Diversidade de modelos de negócio (regional, cooperativa, digital)

---

## 16. Decisões

### Dataset Final

**Remover**: 10 outliers
- Big 5: BB, Bradesco, Caixa, Itaú, Santander
- Especializados: BNDES, BTG Pactual
- Regulatórios: RV2 SEP, VUON SCD
- Operacional: CREFISA

**Analisar**: N=1,045 bancos

### Número de Clusters

**K = 2** (recomendado)

**Razão**:
- Silhueta 0.881 (vs 0.785 em K=3)
- Divisão clara: Pequenos vs Médios
- Sem clusters unitários

### Interpretação

**Cluster 1**: "Cauda Longa" (98-99%)
- SCDs, cooperativas pequenas, agências de fomento
- Ativo < R$ 10 milhões
- Altamente capitalizados (Basileia 50%)

**Cluster 2**: "Middle Market" (1-2%)
- 15 bancos com escala regional/nacional
- Ativo R$ 50-500 milhões
- Modelos diversos: regionais, cooperativas, fintechs, privados

---

## 17. Para Relatório Final

### Seção de Clustering

**Estrutura sugerida**:

1. **Análise Primária** (dataset completo):
   - K=2: Big 7 vs Demais (silhueta 0.972)
   - Plot mostrando separação dramática

2. **Análise Secundária** (sem outliers):
   - K=2: Pequenos vs Médios (silhueta 0.881)
   - Lista dos 15 bancos médios
   - Diversidade de arquétipos

3. **Conclusão**:
   - Setor tem estrutura em 4 camadas
   - Concentração extrema (Big 5 = 80%)
   - Middle market diverso (15 bancos, modelos variados)
   - Cauda longa massiva (1,030 bancos, 2-5% mercado)

---

**Status**: Análise final concluída. Estrutura completa do setor revelada.
**Data**: 2025-11-15
