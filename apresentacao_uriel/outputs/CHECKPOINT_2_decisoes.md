# Checkpoint 2: Decisões PCA

**Data**: 2025-11-15
**Análise**: Principal Component Analysis (PCA)

---

## 1. Número de Componentes (M)

### Critérios Aplicados:

| Critério | M Sugerido | Variância Acumulada |
|----------|-----------|---------------------|
| **Kaiser (λ ≥ 1)** | **2** | 80.0% |
| **Cut-off 75%** | **2** | 80.0% |
| **Cut-off 80%** | **3** | 91.4% |
| **Scree Plot (cotovelo visual)** | **2** | 80.0% |

### Decomposição de Variância:

| Componente | Autovalor (λ) | Variância | Acumulada |
|-----------|--------------|-----------|-----------|
| **PC1** | **5.31** | **66.4%** | **66.4%** |
| **PC2** | **1.09** | **13.6%** | **80.0%** |
| PC3 | 0.91 | 11.4% | 91.4% |
| PC4 | 0.41 | 5.1% | 96.5% |
| PC5-PC8 | <0.25 | <3% cada | 100% |

### **DECISÃO: M = 2 Componentes**

### Justificativa:

1. **Consenso entre critérios**:
   - Kaiser: M = 2 (ambos autovalores > 1)
   - Cut-off 75%: M = 2 (exato em 80%)
   - Scree plot: Cotovelo claro entre PC2 e PC3

2. **Variância explicada adequada**:
   - 80% com 2 componentes excede o mínimo de 75%
   - PC3 adiciona apenas 11.4% (retorno decrescente)

3. **Interpretabilidade**:
   - 2 dimensões são fáceis de visualizar (biplot 2D)
   - Componentes têm interpretação clara de negócio
   - Redução de 8→2 é significativa (75% de compressão)

4. **Parsimônia**:
   - Princípio da simplicidade (Occam's Razor)
   - 2 componentes suficientes para capturar estrutura principal
   - Facilita análises subsequentes (clustering)

---

## 2. Interpretação das Componentes

### PC1 (66.4% da variância): "TAMANHO DO BANCO"

#### Loadings Principais (todos negativos):

| Variável | Loading | Interpretação |
|----------|---------|---------------|
| Ativo Total | -0.430 | Magnitude de ativos |
| Carteira de Crédito | -0.427 | Volume de empréstimos |
| Lucro Líquido | -0.417 | Lucratividade |
| Patrimônio Líquido | -0.412 | Capital próprio |
| Número de Agências | -0.404 | Rede física |
| Postos de Atendimento | -0.352 | Pontos de serviço |

#### Interpretação:

**PC1 é uma dimensão composta de TAMANHO/ESCALA bancária**

- **Sinal negativo** é arbitrário (direção matemática)
- Todas variáveis financeiras e operacionais carregam similarmente
- **PC1 < -10**: Grandes bancos nacionais (Itaú, BB, Caixa, Bradesco, Santander)
- **PC1 ≈ 0**: Bancos médios regionais
- **PC1 > 0**: Pequenos bancos, cooperativas, fintechs

#### Significado Prático:

Esta componente confirma o **CHECKPOINT 1**: Alta multicolinearidade entre variáveis de tamanho (r > 0.9). PC1 captura essa redundância em uma única dimensão.

**Implicação**: O setor bancário brasileiro é primariamente caracterizado por **escala** - a distinção mais importante entre bancos é o tamanho.

---

### PC2 (13.6% da variância): "SAÚDE FINANCEIRA / PERFIL DE RISCO"

#### Loadings Principais (opostos):

| Variável | Loading | Interpretação |
|----------|---------|---------------|
| **Índice de Basileia** | **+0.716** | Adequação de capital |
| **Índice de Imobilização** | **-0.695** | Ativos imobilizados |
| Outras variáveis | <0.05 | Contribuição mínima |

#### Interpretação:

**PC2 é um CONTRASTE entre solidez financeira e imobilização de ativos**

- **PC2 > 0 (positivo)**:
  - Alto Índice de Basileia (capital sólido, baixo risco)
  - Baixo Índice de Imobilização (ativos líquidos)
  - **Perfil**: Bancos conservadores, desenvolvimento, bem capitalizados
  - **Exemplo**: BNDES (PC2 = +1.21)

- **PC2 < 0 (negativo)**:
  - Baixo Índice de Basileia (capital apertado, maior risco)
  - Alto Índice de Imobilização (ativos ilíquidos)
  - **Perfil**: Bancos de investimento, alavancados, agressivos
  - **Exemplo**: XP (PC2 = -2.09), BTG Pactual (PC2 = -1.18)

#### Significado Prático:

PC2 **independe do tamanho** (PC1) - revela que bancos de qualquer tamanho podem ser conservadores ou agressivos. Esta componente captura a **estratégia de negócio** e **apetite a risco**.

---

### PC3 (11.4% da variância): NÃO RETIDA

- Também dominada por índices regulatórios
- Representa nuances adicionais de Basileia/Imobilização
- Não incluída em M=2 por retorno decrescente

### PC4 (5.1% da variância): NÃO RETIDA

- Dominada por "número de postos de atendimento" (loading = 0.880)
- Captura bancos com extensa rede de PABs vs agências
- Contribuição mínima, não justifica inclusão

---

## 3. Análise do Biplot

### Observações do Biplot (PC1 vs PC2):

**Arquivo**: `02_biplot.pdf`

#### Outliers Multivariados Identificados:

1. **Grandes Bancos (PC1 extremo negativo)**:
   - Itaú (PC1 = -39)
   - Banco do Brasil (PC1 = -35)
   - Caixa (PC1 = -32)
   - Bradesco (PC1 = -29)
   - Santander (PC1 = -25)

2. **Bancos de Investimento Agressivos (PC2 extremo negativo)**:
   - XP (PC2 = -2.09)
   - BTG Pactual (PC2 = -1.18)

3. **Bancos de Desenvolvimento Conservadores (PC2 extremo positivo)**:
   - BNDES (PC2 = +1.21)

#### Grupos Naturais Visíveis:

1. **Cluster Central (maioria dos bancos)**:
   - PC1 ≈ 0, PC2 ≈ 0
   - Pequenos/médios bancos com perfil médio de risco
   - ~80% dos 1,055 bancos

2. **Grupo de Grandes Retail Banks**:
   - PC1 < -10, -1 < PC2 < +1
   - Grandes bancos com perfil de risco moderado
   - Incluindo: Itaú, BB, Caixa, Bradesco, Santander, Safra

3. **Investment Banks**:
   - -5 < PC1 < 0, PC2 < -1
   - Tamanho médio, alto risco/alavancagem
   - Incluindo: XP, BTG, alguns bancos de investimento

4. **Development Banks**:
   - PC1 < -5, PC2 > +0.5
   - Grande tamanho, perfil conservador
   - Exemplo: BNDES, algumas agências de fomento

#### Variáveis se Agrupam Conforme Esperado?

✅ **SIM - Agrupamento Coerente**

**No Biplot:**
- **Cluster 1** (ativo, crédito, patrimônio, lucro, agências): Vetores alinhados negativamente em PC1 → Variáveis de TAMANHO
- **Cluster 2** (postos): Vetor moderado em PC1, neutro em PC2 → Infraestrutura
- **Singleton** (Basileia): Vetor forte positivo em PC2 → SOLIDEZ
- **Singleton** (Imobilização): Vetor forte negativo em PC2 → RISCO

Este agrupamento confirma a interpretação das componentes.

---

## 4. Decisão para EFA

### Número de Fatores Esperado: **m = 2 ou 3**

#### Justificativa:

1. **PCA sugere 2 componentes**:
   - EFA tipicamente encontra estrutura similar
   - Esperamos m = 2 ou m = 3 (se PC3 for interpretável como fator)

2. **Estrutura latente clara**:
   - Fator 1: "Tamanho/Escala" (análogo a PC1)
   - Fator 2: "Risco/Solidez" (análogo a PC2)
   - Possível Fator 3: Nuance adicional de regulatório

3. **Comunalidades esperadas**:
   - Variáveis financeiras (ativo, crédito, lucro, patrimônio): h² > 0.9 (bem explicadas pelo Fator 1)
   - Índices (Basileia, Imobilização): h² > 0.8 (explicadas pelo Fator 2)
   - Postos de atendimento: h² moderado (0.4-0.6)

### Método de Estimação:

- **Primeira escolha**: Máxima Verossimilhança (ML)
- **Se instável**: Principal Axis Factoring
- **Rotação**: Testar Varimax (ortogonal) vs Promax (oblíqua)

### Expectativa de Convergência PCA vs EFA:

- **ALTA convergência esperada**: Estrutura é clara e dimensões são ortogonais em PCA (r(PC1,PC2) = 0)
- Se EFA com Varimax convergir em 2 fatores, interpretações devem ser quase idênticas
- Diferença principal: EFA separará variância única (Ψ) da variância comum (Λ)

---

## 5. Sumário Executivo

### Redução Dimensional Bem-Sucedida:

- **De 8 variáveis → 2 componentes**
- **80% de informação retida**
- **75% de compressão dimensional**
- **Interpretação clara e acionável**

### Estrutura Bidimensional do Setor Bancário Brasileiro:

1. **Dimensão 1 (66%)**: TAMANHO/ESCALA
   - Separa grandes bancos nacionais de pequenos/regionais
   - Captura multicolinearidade de variáveis financeiras

2. **Dimensão 2 (14%)**: SAÚDE FINANCEIRA/RISCO
   - Separa bancos conservadores de agressivos
   - Independente do tamanho
   - Captura estratégia de negócio

### Outliers Multivariados Confirmados:

- **Grandes bancos** (Itaú, BB, Caixa): PC1 extremo, mas não problemático
- **Bancos de investimento** (XP, BTG): PC2 extremo negativo, perfil de risco alto
- **BNDES**: PC2 extremo positivo, perfil ultra-conservador

**Decisão de outliers**: MANTER - representam diversidade legítima do setor.

---

## 6. Preparação para Próximas Etapas

### Para EFA (Tarefa 4):

✅ **Pronto para prosseguir**

- Usar mesmo `df_limpo_padro` (1,055 × 8)
- Esperar m = 2 fatores (possivelmente 3)
- Comparar loadings de EFA com loadings de PCA
- Avaliar se comunalidades são altas (h² > 0.7)

### Para Clustering (Tarefa 5):

✅ **Usar escores PCA**

- **Arquivo**: `02_pca_scores.csv` (1,055 bancos × 2 PCs)
- **Vantagem**: Redução de ruído, componentes ortogonais
- **Esperado**: K = 3 a 5 clusters baseados em posições no biplot

**Previsão de clusters**:
1. Grandes bancos retail (PC1 < -10)
2. Bancos de investimento (PC2 < -1)
3. Bancos desenvolvimento (PC2 > +0.5)
4. Pequenos/médios tradicionais (centro, PC1 ≈ 0, PC2 ≈ 0)
5. (Possível) Cooperativas/fintechs (características distintas)

---

## 7. Nomeação das Componentes (Aprovado)

### PC1: "TAMANHO DO BANCO" ou "ESCALA OPERACIONAL"

**Nome técnico aprovado**: "Bank Size / Operational Scale"

**Uso em relatório**: "A primeira componente principal (PC1, 66.4% da variância) representa o tamanho e escala operacional dos bancos, capturando a alta correlação entre ativos totais, carteira de crédito, patrimônio, lucro e rede de distribuição."

### PC2: "SAÚDE FINANCEIRA" ou "PERFIL DE RISCO"

**Nome técnico aprovado**: "Financial Health / Risk Profile"

**Uso em relatório**: "A segunda componente principal (PC2, 13.6% da variância) contrasta solidez financeira (alto índice de Basileia, baixa imobilização) com perfil agressivo/alavancado (baixo Basileia, alta imobilização), independentemente do tamanho do banco."

---

## 8. Validação Técnica

### Verificações Matemáticas:

✅ **Autovalores somam a p**: Σλ = 8.00 ✓
✅ **Variância soma 100%**: Σ(PVE) = 100% ✓
✅ **Componentes ortogonais**: cor(PC1, PC2) = 0 ✓ (por construção)
✅ **Loadings normalizados**: Σ(w²ₖⱼ) = 1 para cada PC ✓

### Verificações Práticas:

✅ **Grandes bancos têm PC1 extremo**: Itaú (-39), BB (-35) confirmados ✓
✅ **Índices dominam PC2**: Basileia (+0.72), Imobilização (-0.70) confirmados ✓
✅ **Biplot interpretável**: Grupos visíveis, vetores coerentes ✓

---

## 9. Próximo Passo

**AÇÃO**: Prosseguir para Tarefa 4 (EFA) com expectativa de m = 2 fatores

**Sem ajustes necessários** - PCA bem-sucedida, resultados validados, decisões documentadas.

---

**Documento aprovado para prosseguir para análise EFA**

**Assinatura**: Análise realizada conforme protocolo de Checkpoint 2
**Data**: 2025-11-15
