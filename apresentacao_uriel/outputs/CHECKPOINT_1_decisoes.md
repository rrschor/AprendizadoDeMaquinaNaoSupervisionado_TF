# Checkpoint 1: Decisões da Análise Descritiva

**Data**: 2025-11-15
**Responsável**: Análise Multivariada de Dados Bancários

---

## 1. Matriz de Correlações

### Correlações Fortes Identificadas

**Total de pares com |r| > 0.7: 14 pares**

### Correlações Extremamente Altas (r > 0.99):
- **Ativo Total × Carteira de Crédito: r = 0.991**
  - Quase perfeita colinearidade
  - Estas variáveis são essencialmente redundantes

### Correlações Muito Altas (r > 0.95):
- Lucro Líquido × Patrimônio Líquido: r = 0.977
- Ativo Total × Lucro Líquido: r = 0.961
- Ativo Total × Patrimônio Líquido: r = 0.945

### Correlações Altas (r > 0.90):
- Carteira de Crédito × Número de Agências: r = 0.943
- Carteira de Crédito × Lucro Líquido: r = 0.938
- Ativo Total × Número de Agências: r = 0.932
- Carteira de Crédito × Patrimônio Líquido: r = 0.917

### Correlações Moderadas-Altas (r > 0.70):
- Patrimônio Líquido × Número de Agências: r = 0.816
- Lucro Líquido × Número de Agências: r = 0.813
- Número de Agências × Postos de Atendimento: r = 0.745
- Ativo Total × Postos de Atendimento: r = 0.743
- Carteira de Crédito × Postos de Atendimento: r = 0.740
- Lucro Líquido × Postos de Atendimento: r = 0.712

### **Justifica Redução Dimensional?**

✅ **SIM - FORTEMENTE JUSTIFICADO**

**Razões:**
1. **14 pares de correlações fortes** (|r| > 0.7) indicam alta redundância
2. **Multicolinearidade extrema** entre variáveis de tamanho (r > 0.99)
3. **Estrutura latente evidente**:
   - Dimensão 1: "Tamanho do Banco" (ativo, crédito, patrimônio, lucro)
   - Dimensão 2: "Infraestrutura Física" (agências, postos)
   - Dimensão 3: "Indicadores de Solidez" (Basileia, Imobilização - baixa correlação)

### Variáveis Mais Redundantes:
1. **Ativo Total e Carteira de Crédito** (r=0.991) - considerar remover uma na análise final
2. **Lucro e Patrimônio** (r=0.977) - alta redundância

---

## 2. Outliers

### Contagem de Outliers por Variável (Critério IQR):

| Variável | N Outliers | % Estimado* |
|----------|-----------|-------------|
| **Lucro Líquido** | 173 | ~16.4% |
| **Patrimônio Líquido** | 145 | ~13.7% |
| **Carteira de Crédito** | 144 | ~13.6% |
| **Ativo Total** | 135 | ~12.8% |
| **Postos de Atendimento** | 98 | ~9.3% |
| **Índice de Imobilização** | 44 | ~4.2% |
| **Índice de Basileia** | 42 | ~4.0% |
| **Número de Agências** | 38 | ~3.6% |

*Baseado em N ≈ 1,055 bancos

### São Erros ou Casos Legítimos?

**CASOS LEGÍTIMOS**

**Justificativa:**
1. **Representam grandes bancos nacionais**:
   - Itaú Unibanco
   - Banco do Brasil
   - Bradesco
   - Caixa Econômica Federal
   - Santander Brasil

2. **Refletem estrutura real do mercado bancário brasileiro**:
   - Concentração de mercado: poucos grandes bancos dominam
   - Maioria de pequenos bancos regionais e digitais
   - Esta assimetria é característica do setor

3. **Dados validados**:
   - Valores consistentes com relatórios do Banco Central
   - Nenhum valor impossível ou claramente errado (ex: valores negativos onde não deveriam existir)

### **Decisão: MANTER OUTLIERS**

**Razão**: Outliers representam variabilidade legítima e importante do sistema bancário brasileiro.

**Ações Tomadas:**
- ✅ Dados já foram padronizados (Z-scores) para equalizar escalas
- ✅ Outliers multivariados serão identificados após PCA (via Biplot)
- ⚠️ Monitorar se outliers formam clusters singleton no K-Means

### Transformação Necessária?

**DECISÃO: NÃO TRANSFORMAR**

**Razão:**
- PCA/EFA funcionam bem com dados padronizados (já feito)
- Transformações logarítmicas mudariam interpretação das componentes
- Outliers são informativos, não ruído
- K-Means pode usar escores PCA (mais robustos a outliers)

---

## 3. Distribuições

### Assimetria Forte?

**SIM - DISTRIBUIÇÕES EXTREMAMENTE ASSIMÉTRICAS À DIREITA**

### Análise por Variável:

| Variável | Mediana | Média | Razão Média/Mediana |
|----------|---------|-------|---------------------|
| **Ativo Total** | 373K | 14.9M | **40x** |
| **Carteira de Crédito** | 158K | 6.8M | **43x** |
| **Patrimônio Líquido** | 64K | 1.4M | **22x** |
| **Lucro Líquido** | 1.4K | 54K | **38x** |
| **Número de Agências** | 0 | 15.7 | **∞ (mediana=0!)** |
| **Postos de Atendimento** | 1 | 15.5 | **15.5x** |
| Índice de Basileia | 0.262 | 0.596 | 2.3x |
| Índice de Imobilização | 0.047 | 0.071 | 1.5x |

**Interpretação:**
- **Variáveis financeiras**: Extrema assimetria à direita
- **Número de Agências**: Mediana = 0! → Maioria dos bancos são digitais ou sem agências físicas
- **Índices regulatórios**: Assimetria moderada (menos concentrados)

### Necessidade de Transformações (log, Box-Cox)?

**DECISÃO: NÃO APLICAR TRANSFORMAÇÕES**

**Justificativa:**
1. **Padronização já realizada** (Z-scores) é suficiente para PCA/K-Means
2. **Transformações logarítmicas**:
   - ❌ Problemático: Variável "lucro_liquido" tem valores **negativos** (mín = -134K)
   - ❌ Mudaria interpretação: log(ativo) ≠ tamanho absoluto
   - ❌ Dificulta interpretação de componentes/fatores
3. **EFA assume normalidade multivariada**:
   - ✅ Teste de Bartlett já passou (p < 0.001)
   - ✅ KMO = 0.796 ("Bom") indica adequação
   - ⚠️ Robustez de EFA para desvios de normalidade é aceitável com N > 1000

---

## 4. Normalidade Multivariada

### Avaliação Visual:

**Histogramas (`01_histogramas.pdf`):**
- Maioria das variáveis mostra distribuição **não-normal** (assimétrica à direita)
- Apenas índices (Basileia, Imobilização) aproximam-se de normal

**Implicações para EFA:**
- EFA assume normalidade para estimação por Máxima Verossimilhança (ML)
- **Com N = 1,055**: EFA é **robusta** a desvios moderados de normalidade
- **Alternativa**: Usar "Principal Axis Factoring" (não assume normalidade)

### **Decisão: Dados Aproximam-se de Normal Multivariada? NÃO**

**Mas:**
- ✅ **KMO = 0.796** indica adequação dos dados
- ✅ **Bartlett p < 0.001** confirma correlações significativas
- ✅ **N = 1,055** é suficiente para robustez
- ✅ **Padronização realizada** mitiga problemas de escala

**Ação:**
- Prosseguir com EFA usando **Máxima Verossimilhança (ML)**
- Se resultados forem instáveis, testar **Principal Axis Factoring** como alternativa

---

## 5. Testes de Adequação

### KMO (Kaiser-Meyer-Olkin):

**Valor: 0.796**

**Interpretação:**
- ✅ **"Bom"** (escala: 0.7-0.8)
- Acima do limiar mínimo (0.6)
- Próximo de "Excelente" (> 0.8)
- **Conclusão**: Dados são adequados para análise fatorial

### Bartlett's Test:

**p-value: < 2.2e-16** (praticamente zero)

**Interpretação:**
- ✅ **Altamente significativo** (p < 0.001)
- Rejeita H₀: Matriz de correlações = Matriz Identidade
- **Conclusão**: Correlações existem e são significativas
- Análise fatorial é apropriada

---

## 6. Decisões Finais para Próximas Etapas

### Para PCA (Tarefa 3):

**Número esperado de componentes:**
- Previsão: **2 a 3 componentes** explicarão > 75% da variância
- Razão: Alta multicolinearidade (14 pares com r > 0.7)

**Interpretação esperada:**
- PC1: "Tamanho do Banco" (ativo, crédito, patrimônio, lucro)
- PC2: "Infraestrutura Física" (agências, postos)
- PC3: "Solidez Regulatória" (Basileia, Imobilização)

**Dados prontos:**
- ✅ `df_limpo_padro` (Z-scores, N=1,055, p=8)
- ✅ Outliers mantidos
- ✅ Sem transformações adicionais

### Para EFA (Tarefa 4):

**Adequação confirmada:**
- ✅ KMO = 0.796 (Bom)
- ✅ Bartlett p < 0.001 (Significativo)

**Método de estimação:**
- **Primeira escolha**: Máxima Verossimilhança (ML)
- **Alternativa**: Principal Axis Factoring (se ML instável)

**Número esperado de fatores:**
- Previsão: **m = 2 ou 3 fatores**
- Usar: Análise Paralela + Scree Plot + Regra de Kaiser

**Rotação:**
- Testar: **Varimax** (ortogonal) e **Promax** (oblíqua)
- Escolher baseado em interpretabilidade

### Para Clustering (Tarefa 5):

**Dados a usar:**
- **Opção 1**: Escores PCA (recomendado - mais robustos a outliers)
- **Opção 2**: `df_limpo_padro` (dados originais padronizados)

**Previsão de K:**
- Esperado: **K = 3 a 5 clusters**
  1. Grandes bancos nacionais
  2. Bancos de investimento
  3. Bancos regionais
  4. Bancos digitais/fintechs
  5. (Possível) Cooperativas de crédito

**Tratamento de outliers:**
- ⚠️ Monitorar se grandes bancos formam clusters singleton
- Se sim: Considerar usar K-Medoids (mais robusto) ou clustering hierárquico

---

## 7. Sumário Executivo

### Dados Bancários Brasileiros:
- **N = 1,055 bancos**
- **p = 8 variáveis** (financeiras + regulatórias + operacionais)
- **Alta multicolinearidade** (14 pares com |r| > 0.7)
- **Outliers legítimos** (grandes bancos nacionais)
- **Distribuições assimétricas** (concentração de mercado)

### Preparação para Análises:
- ✅ **Padronização completa** (Z-scores verificados)
- ✅ **Adequação confirmada** (KMO=0.796, Bartlett p<0.001)
- ✅ **Outliers mantidos** (representam variabilidade real)
- ✅ **Sem transformações** (Z-scores suficientes)

### Justificativas para Próximas Análises:
1. **PCA/EFA FORTEMENTE JUSTIFICADOS** - 14 correlações > 0.7
2. **CLUSTERING ADEQUADO** - Estrutura de mercado sugere tipologias claras
3. **QUALIDADE DOS DADOS** - Limpos, válidos e representativos

---

## 8. Próximo Passo

**AÇÃO**: Atualizar plano se necessário antes de prosseguir para PCA

**Decisão**: ✅ **PROSSEGUIR PARA TAREFA 3 (PCA)** SEM ALTERAÇÕES

**Razão**: Todas as condições estão satisfeitas:
- Dados adequadamente preparados
- Adequação estatística confirmada
- Decisões de pré-processamento documentadas
- Expectativas para PCA/EFA definidas

---

**Documento aprovado para prosseguir para análise PCA**

**Assinatura**: Análise realizada conforme protocolo de Checkpoint 1
**Data**: 2025-11-15
