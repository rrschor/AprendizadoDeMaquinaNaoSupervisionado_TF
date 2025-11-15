# Checkpoint 4: Decisões Clustering

**Data**: 2025-11-15
**Método**: K-Means sobre escores PCA (M=2 componentes)
**N**: 1,055 bancos brasileiros

---

## 1. Escolha de K (Número de Clusters)

### Método do Cotovelo (Elbow Method)

| K | WSS (Within-Sum-of-Squares) | Redução |
|---|------------------------------|---------|
| 1 | 6745.42 | - |
| 2 | **1633.22** | **-75.8%** ⬇ |
| 3 | 1331.66 | -18.5% |
| 4 | 958.59 | -28.0% |
| 5 | 729.25 | -23.9% |
| 6 | 472.97 | -35.1% |
| 7 | 391.20 | -17.3% |
| 8 | 330.27 | -15.6% |
| 9 | 296.34 | -10.3% |
| 10 | 248.88 | -16.0% |

**Análise do Cotovelo**:
- K=1→K=2: Queda de **75.8%** (significativa)
- K=2→K=3: Queda de 18.5%
- K=3→K=4: Queda de **28.0%** (maior que K=2→K=3!)

**Observação**: O cotovelo **não é dramaticamente claro** em K=2. K=3 e K=4 também apresentam reduções substanciais de WSS. O método do cotovelo **sozinho** não é conclusivo para escolher K=2.

### Coeficiente de Silhueta

| K | Silhueta Média | Classificação |
|---|----------------|---------------|
| **2** | **0.972** | ⭐⭐⭐ **EXCEPCIONAL** |
| 3 | 0.541 | Bom |
| 4 | 0.582 | Bom |
| 5 | 0.517 | Médio |
| 6 | 0.519 | Médio |
| 7 | 0.515 | Médio |
| 8 | 0.451 | Médio |
| 9 | 0.532 | Bom |
| 10 | 0.432 | Médio |

**Interpretação da Silhueta**:
- **S > 0.7**: Estrutura forte (excelente)
- **0.5 < S < 0.7**: Estrutura razoável
- **0.25 < S < 0.5**: Estrutura fraca
- **S < 0.25**: Sem estrutura clara

**Resultado**: K=2 tem silhueta de **0.972** → Estrutura de clusters **EXTREMAMENTE BEM DEFINIDA**

### Decisão Final

**K = 2 clusters**

**Justificativas (por ordem de importância)**:

1. ✅ **Silhueta excepcional** (critério DOMINANTE):
   - K=2: 0.972 (extremamente raro na prática)
   - K=3: 0.541 (queda de **44%**)
   - K=4: 0.582
   - Diferença entre K=2 e K=3 é dramática

2. ✅ **Interpretabilidade clara**:
   - K=2 separa perfeitamente Big 5 vs Demais
   - Divisão economicamente significativa
   - Alinhada com estrutura real do setor bancário

3. ✅ **Parcimônia**:
   - Modelo mais simples que captura a estrutura principal
   - Princípio da navalha de Occam

4. ⚠️ **Cotovelo moderado** (não é decisivo):
   - Queda de 76% em K=2 (significativa, mas não extrema)
   - K=3 e K=4 também têm reduções razoáveis
   - Este critério sozinho não seria conclusivo

**Peso da decisão**: Silhueta (70%) + Interpretação (20%) + Parcimônia (10%)

---

## 2. Composição dos Clusters

### Distribuição de Tamanhos

- **Cluster 1**: 1,050 bancos (99.5% do total)
- **Cluster 2**: 5 bancos (0.5% do total)

**Desequilíbrio extremo**: Cluster 2 é outlier multivariado composto pelos 5 maiores bancos do Brasil.

### Cluster 2: "Big Five" 🏛️

Os **5 únicos bancos** do Cluster 2 são:

1. **BB** (Banco do Brasil) - PRUDENCIAL
2. **Bradesco** - PRUDENCIAL
3. **Caixa Econômica Federal** - PRUDENCIAL
4. **Itaú** - PRUDENCIAL
5. **Santander** - PRUDENCIAL

**Interpretação**: O algoritmo K-Means identificou perfeitamente os **5 maiores bancos do Brasil** como um grupo isolado e homogêneo.

### Cluster 1: "Demais Bancos" 🏦

1,050 bancos incluindo:
- Bancos regionais
- Cooperativas de crédito
- Agências de fomento
- Fintechs/SCDs
- Bancos de investimento
- Bancos médios e pequenos

---

## 3. Caracterização dos Clusters (Centróides)

### Comparação de Centróides (Valores Médios)

| Variável | Cluster 1 (Demais) | Cluster 2 (Big 5) | **Razão (C2/C1)** |
|----------|-------------------|-------------------|-------------------|
| **Ativo Total** | 5.5 milhões | 1.99 bilhões | **361x maior** |
| **Carteira de Crédito** | 2.2 milhões | 964 milhões | **432x maior** |
| **Patrimônio Líquido** | 670 mil | 150 milhões | **224x maior** |
| **Lucro Líquido** | 23 mil | 6.6 milhões | **288x maior** |
| **Índice de Basileia** | 0.599 (59.9%) | 0.150 (15.0%) | **4x menor** ⚠️ |
| **Índice de Imobilização** | 0.071 (7.1%) | 0.176 (17.6%) | **2.5x maior** ⚠️ |
| **Número de Agências** | 2.5 agências | 2,800 agências | **1,120x maior** |
| **Postos de Atendimento** | 11 postos | 989 postos | **91x maior** |

### Interpretação dos Perfis

#### Cluster 1: "Bancos Pequenos e Médios"

**Perfil Operacional**:
- Escala reduzida (média de 2-3 agências)
- Operações localizadas/regionais
- Baixo volume de crédito (~2.2 milhões)
- Patrimônio modesto (~670 mil)

**Perfil Regulatório**:
- **Alto Índice de Basileia** (59.9%)
  - Bem capitalizados relativamente ao risco
  - "Overcapitalized" - capital excede mínimo regulatório (10.5%)
- **Baixa Imobilização** (7.1%)
  - Poucos ativos permanentes
  - Estrutura leve

**Interpretação**: Bancos com operações conservadoras, bem capitalizados, e infraestrutura enxuta.

#### Cluster 2: "Big Five - Gigantes Nacionais"

**Perfil Operacional**:
- **Escala massiva**: Centenas de vezes maior que Cluster 1
- **Rede nacional**: Média de 2,800 agências + 989 postos
- **Domínio de mercado**: Concentram grande parte do crédito brasileiro
- **Lucratividade absoluta**: R$ 6.6 milhões médio (288x Cluster 1)

**Perfil Regulatório**:
- **Baixo Índice de Basileia** (15.0%)
  - Próximo ao mínimo regulatório (10.5%)
  - Alavancagem elevada (mais risco, mais retorno)
- **Alta Imobilização** (17.6%)
  - Investimento pesado em infraestrutura (agências, TI, edifícios)

**Interpretação**: Bancos altamente alavancados, com infraestrutura física massiva, operando próximo aos limites regulatórios para maximizar retorno sobre capital.

---

## 4. Qualidade dos Clusters

### Silhueta por Cluster

| Cluster | Tamanho | Silhueta Média | Avaliação |
|---------|---------|----------------|-----------|
| **1** | 1,050 | **0.97** | Excelente coesão ✅ |
| **2** | 5 | **0.77** | Boa coesão ✅ |

**Silhueta Global**: 0.972

**Interpretação**:
- Cluster 1: Coesão quase perfeita (0.97) - bancos muito similares entre si
- Cluster 2: Coesão boa (0.77) - Big 5 são homogêneos, mas com alguma variação interna
- Nenhum cluster com silhueta negativa ✅
- Separação entre clusters é extrema (distância grande no espaço PCA)

### Visualização no Espaço PCA

**Observações do Biplot** (04_biplot_clusters.pdf):
- Cluster 1: Nuvem densa próxima à origem
- Cluster 2: 5 pontos isolados no extremo de PC1 (tamanho)
- **Separação perfeita**: Nenhuma sobreposição entre clusters
- Elipses de confiança: Não se tocam (clusters bem separados)

### Casos Mal Classificados?

**Nenhum** caso com silhueta negativa foi detectado.
- Todos os 1,050 bancos do Cluster 1 têm S > 0.9
- Os 5 bancos do Cluster 2 têm S > 0.7

**Conclusão**: Classificação é **extremamente confiável**.

---

## 5. Clustering Hierárquico (Ward's Method)

### Comparação K-Means vs Hierárquico

**Tabela de Contingência**:

|            | Hier. Cluster 1 | Hier. Cluster 2 |
|------------|----------------|----------------|
| **K-Means C1** | 0 | 1,050 |
| **K-Means C2** | 5 | 0 |

**Concordância**: 0% (!) ⚠️

**O que aconteceu?**

Os métodos **inverteram os rótulos** dos clusters:
- K-Means Cluster 1 = Hierárquico Cluster 2 (demais bancos)
- K-Means Cluster 2 = Hierárquico Cluster 1 (Big 5)

**Rótulos são arbitrários**: Algoritmos não coordenam numeração.

**Concordância real (ajustando rótulos)**: **100%**!

Ambos métodos identificaram **exatamente os mesmos 5 bancos** como grupo isolado.

### Dendrograma (Ward's Method)

**Observações** (04_dendrograma.pdf):
- Altura de fusão dos Big 5: ~20 (união precoce)
- Altura de fusão com demais bancos: ~100+ (união tardia)
- **Gap dramático**: Confirma existência de 2 grupos naturais
- Corte em K=2 é óbvio visualmente

**Conclusão**: Estrutura hierárquica **confirma** divisão binária encontrada por K-Means.

---

## 6. Validação Prática

### Os "Big 5" Fazem Sentido?

✅ **SIM - Perfeitamente**

Os 5 bancos identificados são:
1. **Banco do Brasil** - Maior banco estatal do Brasil
2. **Caixa Econômica Federal** - Segundo maior banco estatal
3. **Itaú** - Maior banco privado do Brasil
4. **Bradesco** - Segundo maior banco privado
5. **Santander** - Maior banco estrangeiro no Brasil

Estes 5 bancos:
- Representam ~80% do crédito bancário brasileiro
- Possuem redes nacionais (presença em todos os estados)
- São os únicos com >1,000 agências
- Dominam todos os rankings de tamanho do setor

**Validação Externa**: Qualquer brasileiro reconheceria estes 5 como "os grandes bancos".

### Interpretação Econômica

**Cluster 2 (Big 5)**:
- Oligopólio bancário brasileiro
- "Too big to fail" - sistematicamente importantes
- Alta alavancagem (Basileia baixa) → maior risco sistêmico
- Infraestrutura física massiva (modelo tradicional)

**Cluster 1 (Demais 1,050)**:
- Cauda longa do setor bancário
- Operações especializadas/regionais
- Baixo risco individual (bem capitalizados)
- Modelo enxuto (menos imobilização)

---

## 7. Relação com PCA/EFA

### Separação no Espaço Reduzido

**PC1 (66.4% variância - "Tamanho"):**
- Big 5: Escores extremamente negativos (PC1 < -30)
- Demais bancos: Escores próximos a 0

**PC2 (13.6% variância - "Basileia vs Imobilização"):**
- Big 5: Basileia baixa, Imobilização alta (PC2 ligeiramente positivo)
- Demais bancos: Basileia alta, Imobilização baixa (PC2 variável)

**Conclusão**: Clusters se separam **primariamente por PC1 (tamanho)**, com contribuição menor de PC2.

### Fatores EFA vs Clusters

**Fator 1 ("Escala Operacional")**:
- Big 5: Escores altíssimos (muitas agências, alto crédito)
- Demais bancos: Escores baixos

**Fator 2 ("Solidez Financeira")**:
- Correlação menos clara com clusters
- Ambos clusters têm bancos lucrativos e não-lucrativos

**Insight**: **Escala** é o principal divisor, não necessariamente **solidez**.

---

## 8. Limitações e Considerações

### Desequilíbrio Extremo

**Problema**: Cluster 2 tem apenas 5 observações (0.5%)

**Implicações**:
- Estatísticas de Cluster 2 têm alta variância (n=5)
- Centróides sensíveis a observações individuais
- Silhueta de Cluster 2 (0.77) menos confiável que Cluster 1 (0.97)

**É um problema real?** ❌ **NÃO**

- Desequilíbrio reflete realidade: setor bancário é **altamente concentrado**
- Big 5 são realmente outliers multivariados (não é artefato)
- Interpretação econômica é robusta

### K=2 é Suficiente?

**Argumento para K > 2**:
- Cluster 1 pode ter subgrupos:
  - Fintechs vs bancos tradicionais pequenos
  - Agências de fomento vs bancos comerciais
  - Cooperativas de crédito vs bancos de investimento

**Contra-argumento**:
- Silhueta para K=3,4,5,... é muito menor (~0.5 vs 0.97)
- Subgrupos não são tão bem definidos quanto divisão Big 5 vs Demais
- Parsimônia: **K=2 captura a distinção mais importante**

**Decisão**: Manter K=2 como solução principal, mas **reconhecer heterogeneidade dentro de Cluster 1**.

---

## 9. Comparação com Expectativas Iniciais

### Expectativa (do Plano Original)

> "Expectativa: K = 3 a 5 clusters baseados em posições no espaço PC1-PC2"

### Realidade

**K = 2** foi escolhido (menor que esperado)

**Por que?**
1. **Silhueta excepcional em K=2**: 0.972 (vs 0.54 em K=3) - evidência irrefutável
2. **Concentração extrema do setor**: Big 5 são tão dominantes que formam ilha isolada
3. **PC1 explica 66%**: Dimensão de tamanho é tão dominante que ofusca subdivisões
4. **Interpretação clara**: Big 5 vs Demais é economicamente significativo

**Nota**: O cotovelo não foi tão claro quanto esperado (K=3 e K=4 também tinham reduções razoáveis). A decisão foi dominada pela **silhueta excepcional**.

**Lição**: Dados reais podem ter estrutura mais simples (ou complexa) que expectativas teóricas. **Sempre priorizar evidência empírica sobre intuições**. Nem todos os critérios convergem sempre - usar o mais robusto (silhueta neste caso).

---

## 10. Decisões Finais

### Número de Clusters

**DECISÃO: K = 2**

**Justificativa (revisada)**:
- **Silhueta excepcional** (0.972) - critério DOMINANTE
- Queda de 44% na silhueta de K=2 para K=3 (0.972 → 0.541)
- Interpretação econômica clara e robusta (Big 5 vs Demais)
- Confirmado por método hierárquico (100% concordância ajustando rótulos)
- Cotovelo moderado (76% redução WSS), mas não decisivo sozinho

### Interpretação dos Clusters

**Cluster 1: "Cauda Longa do Setor Bancário"** (N=1,050)
- Bancos pequenos, médios, regionais, cooperativas, fintechs
- Bem capitalizados (Basileia 60%)
- Infraestrutura enxuta
- 99.5% das instituições, mas fração minoritária do mercado

**Cluster 2: "Oligopólio dos Big Five"** (N=5)
- BB, Bradesco, Caixa, Itaú, Santander
- Escala 200-400x maior que média do Cluster 1
- Alavancagem elevada (Basileia 15%)
- Infraestrutura física massiva (2,800 agências)
- 0.5% das instituições, mas ~80% do mercado

### Qualidade da Solução

**Avaliação: EXCELENTE**

- Silhueta = 0.972 (extremamente alta)
- Concordância entre K-Means e Hierárquico = 100%
- Validação prática = perfeita (identificou Big 5 corretamente)
- Interpretação econômica = clara e robusta

### Método de Clustering

**K-Means sobre Escores PCA** foi adequado:
- ✅ Componentes ortogonais (simplificam distâncias Euclidianas)
- ✅ 80% variância retida (suficiente para clustering)
- ✅ Redução dimensional facilitou visualização
- ✅ Resultados robustos (confirmados por hierárquico)

---

## 11. Insights para Relatório Final

### Principais Achados

1. **Concentração Extrema**:
   - 5 bancos (0.5%) vs 1,050 bancos (99.5%)
   - Big 5 são 200-400x maiores em todas as métricas

2. **Perfis Regulatórios Opostos**:
   - Big 5: Basileia baixa (15%), alta imobilização (18%)
   - Demais: Basileia alta (60%), baixa imobilização (7%)

3. **Separação Perfeita**:
   - Silhueta 0.972 é raro na prática
   - K-Means e Hierárquico concordam 100%

4. **Validação Externa**:
   - Clustering "descobriu" os Big 5 sem informação prévia
   - Resultado alinha perfeitamente com conhecimento do setor

### Aplicações Práticas

1. **Regulação Diferenciada**:
   - Big 5 exigem supervisão sistêmica especial
   - Demais podem ter regime simplificado

2. **Benchmarking**:
   - Comparar banco com centróide do seu cluster
   - Big 5 vs resto são incomparáveis

3. **Política Pública**:
   - Quantificar concentração do setor
   - Avaliar necessidade de antitruste

### Limitações

1. Cluster 1 é heterogêneo (agrupa todos os não-Big 5)
2. Análise estática (snapshot março 2025)
3. Não considera variáveis qualitativas (governance, estratégia)

---

## 12. Próximos Passos

### Para Relatório Final (Tarefa 6):

**Seção de Clustering deve incluir**:
1. Gráfico cotovelo + silhueta (04_elbow_plot.pdf, 04_silhouette_scores.pdf)
2. Biplot colorido por cluster (04_biplot_clusters.pdf) ⭐
3. Tabela de centróides (04_centroides_transposto.csv)
4. Lista dos Big 5 (validação prática)
5. Interpretação econômica dos perfis
6. Comparação K-Means vs Hierárquico (dendrograma)

**Mensagem-chave**: "K-Means identificou perfeitamente os 5 maiores bancos do Brasil como grupo isolado, confirmando concentração extrema do setor"

### Para Apresentação (Tarefa 7):

**Slides de Clustering** (~3-4 slides):
1. **Escolha de K**: Gráfico de silhueta mostrando K=2 dominante
2. **Biplot**: Visualização dramática da separação
3. **Perfis**: Tabela comparando Big 5 vs Demais (razões 200-400x)
4. **Conclusão**: "5 bancos concentram poder, 1,050 formam cauda longa"

---

## 13. Resumo Executivo

### ✅ Sucessos

- **Silhueta excepcional**: 0.972 (muito raro, critério dominante)
- **Validação perfeita**: Identificou Big 5 corretamente sem supervisão
- **Confirmação hierárquica**: 100% concordância com K-Means
- **Interpretação clara**: Oligopólio vs Cauda Longa
- **Robustez**: Decisão não depende de um único critério (silhueta >> cotovelo)

### ⚠️ Limitações

- Cluster 1 é heterogêneo (todos os não-Big 5 juntos)
- Desequilíbrio extremo (1,050 vs 5)
- K=2 pode ser simplificação excessiva para análises específicas

### 📊 Números-Chave

- **K = 2 clusters**
- **Silhueta global = 0.972**
- **Big 5**: BB, Bradesco, Caixa, Itaú, Santander
- **Razão de tamanho**: 200-400x maior (C2 vs C1)
- **Concordância K-Means vs Hierárquico**: 100%

---

**Status**: Análise de Clustering concluída com sucesso. Prosseguir para Tarefas 6-8 (Relatório, Apresentação, README).

**Data**: 2025-11-15
