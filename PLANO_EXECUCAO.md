# Plano de Execução - Análise de Dados Bancários
## Trabalho Final - Aprendizado de Máquina Não Supervisionado

**Prazo**: 1-3 dias
**Formato de Entrega**: R Markdown (relatório) + Slides (apresentação)
**Abordagem**: Balanceada entre PCA, EFA e Clustering

---

## ⚠️ PRINCÍPIO FUNDAMENTAL

**ENTRE CADA FASE, ANALISAR OS RESULTADOS ANTES DE PROSSEGUIR**

- Resultados podem revelar insights inesperados
- Problemas podem exigir adaptação do plano
- Decisões sobre hiperparâmetros (M, m, K) dependem dos outputs anteriores
- Cada CHECKPOINT é obrigatório para validar a próxima etapa

---

## 📊 FASE 1: Organização e Análise Descritiva
**Objetivo**: Preparar dados e entender estrutura multivariada
**Tempo Estimado**: Dia 1 - Manhã

### Tarefa 1.1: Refatorar `df_banco.R`
**Arquivo**: `apresentacao_uriel/df_banco.R`

**Melhorias**:
- Tornar código modular e reutilizável
- **Adicionar padronização explícita** (Z-scores: média=0, desvio padrão=1)
  - **Justificativa**: PCA e K-Means são sensíveis à escala das variáveis
  - Técnicas baseadas em distância/variância não devem ser dominadas por variáveis de maior magnitude

**Outputs Esperados**:
- `df_bancos`: Dataset limpo (12 variáveis)
- `df_limpo`: Dataset reduzido (8 variáveis)
- `df_limpo_padro`: Dataset padronizado (Z-scores)
- `bancos`: Vetor com nomes das instituições

---

### Tarefa 1.2: Criar `01_analise_descritiva.R`
**Arquivo**: `apresentacao_uriel/01_analise_descritiva.R`

#### Análises a Implementar:

1. **Estatísticas Sumárias Univariadas**
   - Média, mediana, desvio padrão, quartis
   - Máximo, mínimo, amplitude

2. **Medidas de Variabilidade Multivariada**
   - **Matriz de Variâncias-Covariâncias** (Σ̂)
   - **Matriz de Correlações** (Ĉ)
   - **Justificativa**: Estas matrizes são centrais para análise multivariada

3. **Visualizações**
   - **Histogramas**: Distribuição de cada variável
   - **Boxplots**: Identificação visual de outliers
   - **Violin Plots**: Densidade estimada por kernel (comparação visual)
   - **Matriz de Correlação Visual**: corrplot (já existe em df_banco.R)
     - **Objetivo**: Avaliar redundância entre variáveis → justifica PCA/EFA

4. **Identificação de Outliers**
   - Via boxplots univariados
   - **Nota**: Outliers multivariados serão detectados após redução dimensional (Biplots de PCA)

**Outputs Esperados**:
- Tabela de estatísticas descritivas
- Matrizes Σ̂ e Ĉ
- Gráficos salvos (PNG/PDF)

---

### 🔍 CHECKPOINT 1: Análise Descritiva
**PARAR E ANALISAR**:

1. **Matriz de Correlações**:
   - Existem correlações fortes (|r| > 0.7)?
   - Isso justifica redução dimensional?
   - Quais variáveis são mais redundantes?

2. **Outliers**:
   - Quantos outliers foram identificados?
   - São erros ou casos legítimos (ex: grandes bancos)?
   - Decisão: remover, transformar ou manter?

3. **Distribuições**:
   - Há assimetria forte?
   - Necessidade de transformações (log, Box-Cox)?

4. **Normalidade Multivariada**:
   - Avaliar visualmente se dados se aproximam de normal multivariada
   - Importante para interpretação de EFA (modelo assume normalidade)

**AÇÃO**: Atualizar plano se necessário antes de prosseguir para PCA

---

## 🧮 FASE 2: PCA - Análise de Componentes Principais
**Objetivo**: Decompor variabilidade em componentes ortogonais não-correlacionadas
**Tempo Estimado**: Dia 1 - Tarde

### Tarefa 2.1: Criar `02_pca.R`
**Arquivo**: `apresentacao_uriel/02_pca.R`

#### Fundamentos Teóricos:
- **Matriz Base**: Matriz de Correlações **C** (trabalhar com Z-scores)
- **Decomposição**: Autovetores (matriz W) e autovalores (λₖ)
- **Propriedade**: Componentes são ortogonais/não-correlacionadas

#### Implementações:

1. **Construção das Componentes Principais**
   - Obter autovetores (pesos) e autovalores
   - Ordenar por autovalores decrescentes
   - Componentes: X̂ₖ = Σ(wₖⱼ × Zⱼ)

2. **Critérios para Escolha de M Componentes**

   a) **Scree Plot (Regra do Cotovelo)**
      - Gráfico: λₖ vs k
      - Buscar "cotovelo" (ponto de inflexão)

   b) **Regra de Kaiser**
      - Reter componentes com λₖ ≥ 1 (dados padronizados)
      - **Justificativa**: Componente explica mais que uma variável original

   c) **Critério de Cut-off de Variância**
      - Reter M componentes que expliquem γ% da variância total
      - **Sugestão**: γ = 75% ou 80%

3. **Decomposição de Variância**
   - Variância de cada componente: V_T(X̂ₖ) = λₖ
   - **Proporção de Variância Explicada (PVE)**:
     - PVEₖ = λₖ / Σλₖ = λₖ / V_T(X)
   - PVE acumulada

4. **Loadings e Interpretação Qualitativa**
   - **Loadings** (wₖⱼ): Pesos de cada variável original na componente k
   - **Interpretação**: wₖⱼ é proporcional a corr(Xⱼ, X̂ₖ)
   - Magnitude de |wₖⱼ| indica "importância" da variável Xⱼ na componente k
   - Dar nomes interpretativos às componentes (ex: "Tamanho", "Lucratividade")

5. **Biplot**
   - Visualização simultânea: observações (escores) + variáveis (loadings)
   - **Uso adicional**: Detecção visual de outliers multivariados

6. **Redução Dimensional**
   - Formar matriz de escores X̂_M (primeiras M componentes)
   - **Objetivo**: Reter máximo de informação com mínimo de dimensões

**Outputs Esperados**:
- Tabela de autovalores e PVE
- Scree plot
- Tabela de loadings (matriz W)
- Biplot (2 primeiras CPs)
- Matriz de escores X̂_M

---

### 🔍 CHECKPOINT 2: PCA
**PARAR E ANALISAR**:

1. **Número de Componentes**:
   - Quantas componentes os 3 critérios sugerem?
   - Há consenso ou divergência?
   - Qual percentual de variância é explicado?

2. **Interpretação dos Loadings**:
   - As componentes fazem sentido interpretativo?
   - Quais variáveis definem cada componente?
   - Possível nomear as componentes?

3. **Biplot**:
   - Há outliers multivariados evidentes?
   - Há grupos naturais visíveis?
   - Variáveis se agrupam conforme esperado?

4. **Decisão para EFA**:
   - O número M de componentes é adequado?
   - Devemos usar o mesmo número m de fatores na EFA?

**AÇÃO**: Documentar decisões e ajustar plano de EFA

---

## 🔬 FASE 3: EFA - Análise Fatorial Exploratória
**Objetivo**: Estimar fatores latentes que explicam estrutura de covariância
**Tempo Estimado**: Dia 2 - Manhã

### Tarefa 3.1: Criar `03_efa.R`
**Arquivo**: `apresentacao_uriel/03_efa.R`

#### Fundamentos Teóricos:
- **Modelo**: Σ = ΛΛᵀ + Ψ
  - **Λ**: Matriz de cargas fatoriais (p × m)
  - **Ψ**: Matriz diagonal de especificidades (variâncias residuais)
- **Comunalidades** (ΛΛᵀ): Variância explicada pelos fatores
- **Especificidades** (Ψ): Variância não explicada (erro + unicidade)

#### Implementações:

1. **Testes de Adequação (Migrar de `df_banco.R`)**

   a) **Teste KMO (Kaiser-Meyer-Olkin)**
      - Overall MSA (Measure of Sampling Adequacy)
      - Interpretação:
        - MSA ≥ 0.9: Excelente
        - 0.8 ≤ MSA < 0.9: Bom
        - 0.7 ≤ MSA < 0.8: Médio
        - MSA < 0.6: Inadequado
      - **Objetivo**: Avaliar se variáveis são coerentes para análise fatorial

   b) **Teste de Bartlett**
      - H₀: Matriz de correlações é uma matriz identidade
      - Queremos rejeitar H₀ (p-valor < 0.05)
      - **Objetivo**: Confirmar que existem correlações significativas

2. **Estimação com Diferentes Métodos**

   a) **Máxima Verossimilhança (ML)** - Método principal
      - Estimadores obtidos numericamente (não há solução analítica)
      - Fornece testes estatísticos

   b) **Principal Axis Factoring** - Alternativa
      - Método iterativo baseado em comunalidades
      - Não assume normalidade

3. **Escolha do Número de Fatores (m)**

   **IMPORTANTE**: Diferente de PCA, é necessário **re-estimar o modelo** para cada m

   Critérios:

   a) **Regra de Kaiser**
      - Reter fatores com autovalor ≥ 1

   b) **Scree Plot**
      - Buscar cotovelo no gráfico de autovalores

   c) **Percentual de Explicação das Variáveis**
      - Reter m fatores que expliquem γ% das variáveis
      - **Sugestão**: γ = 40% (EFA explica menos que PCA)

   d) **Interpretabilidade**
      - Fatores devem fazer sentido teórico

4. **Rotação para Melhor Interpretabilidade**

   a) **Varimax (Rotação Ortogonal)**
      - Mantém fatores não-correlacionados
      - Maximiza variância dos loadings ao quadrado
      - **Uso**: Quando esperamos fatores independentes

   b) **Promax (Rotação Oblíqua)**
      - Permite correlação entre fatores
      - **Uso**: Quando esperamos fatores relacionados (comum em ciências sociais)

   **Decisão**: Testar ambas e escolher baseado em interpretabilidade

5. **Interpretação dos Fatores**
   - Analisar **matriz de cargas fatoriais Λ**
   - Loading λₖⱼ é proporcional a corr(Xₖ, fⱼ)
   - Variáveis com |λₖⱼ| > 0.4 são consideradas importantes para o fator j
   - Dar nomes interpretativos aos fatores

6. **Cálculo de Comunalidades e Especificidades**
   - **Comunalidade** de Xⱼ: h²ⱼ = Σ(λ²ⱼₖ) para k=1 a m
   - **Especificidade** de Xⱼ: ψⱼ = 1 - h²ⱼ
   - Avaliar qual percentual de cada variável é explicado pelos fatores

7. **Estimação dos Escores Fatoriais**
   - **Estimador de Thompson (Método de Regressão)**
   - f̂ = E[f | X] (esperança condicional)
   - Matriz de escores f̂ (n × m)
   - **Objetivo**: Redução dimensional via fatores estimados

**Outputs Esperados**:
- KMO e Bartlett (valores e p-valores)
- Tabela de cargas fatoriais (antes e depois da rotação)
- Tabela de comunalidades e especificidades
- Matriz de escores fatoriais f̂
- Comparação entre Varimax e Promax

---

### 🔍 CHECKPOINT 3: EFA
**PARAR E ANALISAR**:

1. **Adequação dos Dados**:
   - KMO está aceitável (≥ 0.7)?
   - Bartlett rejeita H₀ (p < 0.05)?
   - Se inadequado, considerar remoção de variáveis

2. **Número de Fatores**:
   - Consenso entre critérios?
   - Fatores são interpretáveis?
   - Comunalidades são satisfatórias (≥ 0.4)?

3. **Rotação**:
   - Varimax ou Promax oferece melhor interpretabilidade?
   - Fatores rotacionados são mais claros?

4. **Comparação PCA vs EFA**:
   - EFA encontrou estrutura latente diferente de PCA?
   - Número de dimensões é similar (M ≈ m)?
   - Interpretações convergem ou divergem?
   - Qual método parece mais adequado para os dados bancários?

5. **Comunalidades Baixas**:
   - Alguma variável tem h²ⱼ < 0.3?
   - Considerar remover variáveis mal explicadas?

**AÇÃO**: Documentar comparação PCA vs EFA; ajustar se necessário

---

## 🎯 FASE 4: Clustering
**Objetivo**: Particionar bancos em grupos homogêneos
**Tempo Estimado**: Dia 2 - Tarde

### Tarefa 4.1: Criar `04_clustering.R`
**Arquivo**: `apresentacao_uriel/04_clustering.R`

#### Preparação dos Dados:

**CRUCIAL**: Clustering deve ser aplicado em dados padronizados ou escores de redução dimensional

Opções:
1. Dados originais padronizados (Z-scores)
2. Escores PCA (X̂_M)
3. Escores EFA (f̂)

**Justificativa**: K-Means minimiza distância Euclidiana → sensível à escala

---

#### Método 1: K-Means Clustering

1. **Inicialização**
   - **K-means++**: Inicialização inteligente (melhor que aleatória)
   - **Múltiplos Starts**: `nstart = 25` no R
   - **Justificativa**: Mitigar risco de mínimos locais

2. **Testar Diferentes Valores de K**
   - Range sugerido: K = 2 a 10
   - Para cada K, armazenar:
     - Soma de quadrados intra-cluster W(C)
     - Coeficiente de Silhueta médio

3. **Critério 1: Método do Cotovelo (Elbow Method)**
   - Gráfico: W(C) vs K
   - Buscar ponto de inflexão (cotovelo)
   - W(C) sempre diminui com K, mas taxa de decréscimo muda

4. **Critério 2: Coeficiente de Silhueta**
   - Para cada observação i:
     - a(i): distância média intra-cluster
     - b(i): distância média ao cluster vizinho mais próximo
     - S(i) = [b(i) - a(i)] / max{a(i), b(i)}
   - Interpretação:
     - S(i) ≈ 1: Bem posicionado no cluster
     - S(i) ≈ 0: Na fronteira entre clusters
     - S(i) < 0: Possivelmente no cluster errado
   - **Silhueta Média**: Avaliar qualidade geral do agrupamento
   - Escolher K que maximiza Silhueta média

5. **Caracterização dos Clusters**
   - **Centróides**: Médias de cada variável por cluster
   - Tabela comparativa (clusters nas colunas, variáveis nas linhas)
   - Interpretar perfil de cada cluster
   - Exemplos: "Cluster de Grandes Bancos", "Bancos Regionais", etc.

6. **Distribuições Estratificadas**
   - Boxplots de variáveis importantes por cluster
   - Identificar características distintivas

7. **Validação**
   - Analisar alguns bancos por cluster
   - Clusters fazem sentido prático?

---

#### Método 2: Clustering Hierárquico

1. **Implementação**
   - Função `hclust()` no R
   - Testar diferentes métodos de linkage:
     - Complete linkage (padrão)
     - Average linkage
     - Ward's method (minimiza variância intra-cluster)

2. **Dendrograma**
   - Visualização hierárquica
   - Não exige especificar K a priori

3. **Escolha de K**
   - Usar `cutree()` para cortar dendrograma
   - Testar diferentes alturas de corte
   - Comparar com K-Means

4. **Comparação com K-Means**
   - Mesmos bancos nos mesmos clusters?
   - Tabela de contingência
   - Índice de Rand ou Adjusted Rand Index

---

#### Visualizações:

1. **Biplot PCA Colorido por Cluster**
   - Projeção em 2D (PC1 vs PC2)
   - Pontos coloridos por cluster membership
   - Adicionar centróides dos clusters
   - Adicionar elipses de confiança
   - **Objetivo**: Visualizar separação em espaço de baixa dimensão

2. **Silhouette Plot**
   - Barras de silhueta por observação e cluster
   - Avaliar visualmente qualidade

3. **Parallel Coordinates Plot**
   - Visualizar perfil multivariado dos clusters
   - Linhas coloridas por cluster

**Outputs Esperados**:
- Gráficos de Cotovelo e Silhueta
- Dendrograma (hierárquico)
- Tabela de centróides
- Biplot colorido
- Lista de bancos por cluster
- Silhouette plot

---

### 🔍 CHECKPOINT 4: Clustering
**PARAR E ANALISAR**:

1. **Escolha de K**:
   - Cotovelo e Silhueta concordam?
   - Qual K escolher? (balance: interpretabilidade vs qualidade)
   - K entre 3-5 é comum para interpretabilidade

2. **Qualidade dos Clusters**:
   - Silhueta média > 0.5 é bom
   - Há clusters com Silhueta negativa? (repensar K)
   - Clusters são equilibrados ou há 1 cluster muito grande?

3. **Interpretação dos Clusters**:
   - Perfis dos centróides são distintos?
   - É possível nomear/caracterizar cada cluster?
   - Exemplos:
     - Cluster 1: Grandes bancos (alto ativo, muitas agências)
     - Cluster 2: Bancos de investimento (alto patrimônio, poucos postos)
     - Cluster 3: Bancos regionais (médio porte)

4. **Consistência K-Means vs Hierárquico**:
   - Estruturas de clusters são similares?
   - Divergências grandes indicam instabilidade

5. **Validação Prática**:
   - Listar bancos notáveis em cada cluster
   - Faz sentido Itaú, BB, Bradesco estarem juntos?
   - Nubank e XP formam cluster de fintechs?

6. **Relação com PCA/EFA**:
   - Clusters se separam bem no espaço reduzido?
   - Componentes/fatores explicam diferenças entre clusters?

**AÇÃO**: Documentar interpretação final dos clusters

---

## 📝 FASE 5: Documentação e Apresentação
**Objetivo**: Consolidar análises em relatório e slides
**Tempo Estimado**: Dia 3

### Tarefa 5.1: Criar `relatorio_final.Rmd`
**Arquivo**: `apresentacao_uriel/relatorio_final.Rmd`

#### Estrutura Sugerida:

1. **Introdução**
   - Contexto: análise de instituições bancárias brasileiras
   - Objetivos do trabalho
   - Metodologias utilizadas (PCA, EFA, Clustering)

2. **Descrição dos Dados**
   - Fonte e período (dados de 03/2025)
   - Variáveis analisadas (8 variáveis finais)
   - Pré-processamento (limpeza, padronização)

3. **Análise Descritiva**
   - Estatísticas sumárias
   - Matriz de correlações
   - Distribuições e outliers
   - Justificativa para análises multivariadas

4. **Análise de Componentes Principais (PCA)**
   - Decomposição de variância
   - **Justificativa de M**: Explicar critérios usados (Scree, Kaiser, Cut-off)
   - Interpretação das componentes (loadings)
   - Biplot e insights
   - **PVE**: Quanto de variância foi retida?

5. **Análise Fatorial Exploratória (EFA)**
   - Testes de adequação (KMO, Bartlett)
   - **Justificativa de m**: Explicar critérios
   - Modelo estimado (Λ e Ψ)
   - Comunalidades e especificidades
   - Rotação (Varimax vs Promax) e justificativa da escolha
   - Interpretação dos fatores
   - **Comparação com PCA**: Semelhanças e diferenças

6. **Clustering**
   - Método K-Means
   - **Justificativa de K**: Cotovelo, Silhueta, interpretabilidade
   - Caracterização dos clusters (centróides)
   - Perfil qualitativo de cada cluster
   - Visualização no espaço PCA
   - Validação prática (exemplos de bancos)
   - Clustering hierárquico (comparação)

7. **Conclusões**
   - Principais achados
   - Redundância capturada (PVE, comunalidades)
   - Estrutura latente dos dados bancários
   - Tipologia de bancos identificada
   - Limitações e trabalhos futuros

8. **Referências**
   - Material do curso
   - Pacotes R utilizados

#### Aspectos Técnicos:
- Incluir todos os gráficos principais
- Tabelas formatadas (kable, kableExtra)
- Código pode ser ocultado (echo=FALSE) no relatório final
- Output em HTML (mais flexível) ou PDF

---

### Tarefa 5.2: Criar `apresentacao.Rmd`
**Arquivo**: `apresentacao_uriel/apresentacao.Rmd`

#### Formato:
- R Markdown com output: `ioslides_presentation` ou `slidy_presentation`
- Alternativamente: `beamer_presentation` para PDF

#### Estrutura de Slides:

1. **Título e Contexto** (1 slide)
   - Título do trabalho
   - Autores
   - Disciplina e data

2. **Objetivos** (1 slide)
   - Analisar estrutura multivariada de dados bancários
   - Aplicar PCA, EFA e Clustering
   - Identificar dimensões latentes e tipologia de bancos

3. **Dados** (1 slide)
   - Fonte: dados bancários brasileiros (03/2025)
   - 8 variáveis selecionadas
   - Número de bancos analisados

4. **Análise Descritiva** (1-2 slides)
   - Matriz de correlação (gráfico)
   - Principais insights: alta correlação entre variáveis de tamanho

5. **PCA - Resultados Principais** (2-3 slides)
   - Scree plot
   - Número de componentes retidas (M) e PVE
   - Interpretação das componentes (tabela de loadings)
   - Biplot (destaque)

6. **EFA - Resultados Principais** (2-3 slides)
   - Adequação: KMO e Bartlett
   - Número de fatores (m) e justificativa
   - Cargas fatoriais rotacionadas (tabela)
   - Interpretação dos fatores latentes
   - **Comparação com PCA**: Consenso ou divergência?

7. **Clustering - Resultados Principais** (2-3 slides)
   - Método do Cotovelo e Silhueta (gráficos)
   - K escolhido e justificativa
   - Perfil dos clusters (tabela de centróides)
   - Biplot colorido por cluster (destaque)
   - Exemplos de bancos em cada cluster

8. **Conclusões** (1-2 slides)
   - **Redundância**: PCA/EFA reduziram dimensionalidade com sucesso
   - **Estrutura Latente**: Fatores/Componentes identificados
   - **Tipologia**: K clusters com perfis distintos
   - Aplicações práticas

9. **Referências** (1 slide, opcional)

#### Dicas:
- Slides devem ser visuais (mais gráficos, menos texto)
- Usar cores consistentes
- Destacar números-chave (PVE, KMO, K escolhido)
- Apresentação deve ter 10-15 slides

---

### Tarefa 5.3: Atualizar `README.md`
**Arquivo**: `README.md`

#### Adicionar Seções:

1. **Como Executar as Análises**
   ```r
   # 1. Preparação dos dados
   source("apresentacao_uriel/df_banco.R")

   # 2. Análise descritiva
   source("apresentacao_uriel/01_analise_descritiva.R")

   # 3. PCA
   source("apresentacao_uriel/02_pca.R")

   # 4. EFA
   source("apresentacao_uriel/03_efa.R")

   # 5. Clustering
   source("apresentacao_uriel/04_clustering.R")
   ```

2. **Gerar Relatório e Apresentação**
   ```r
   rmarkdown::render("apresentacao_uriel/relatorio_final.Rmd")
   rmarkdown::render("apresentacao_uriel/apresentacao.Rmd")
   ```

3. **Estrutura de Arquivos**
   ```
   apresentacao_uriel/
   ├── dados.csv
   ├── df_banco.R (preparação)
   ├── 01_analise_descritiva.R
   ├── 02_pca.R
   ├── 03_efa.R
   ├── 04_clustering.R
   ├── relatorio_final.Rmd
   ├── apresentacao.Rmd
   └── outputs/ (gráficos e tabelas)
   ```

4. **Resultados Principais**
   - Resumo dos principais achados (preencher após análises)

---

## 🎯 CHECKLIST FINAL

Antes de considerar o trabalho completo:

- [ ] Todos os scripts R executam sem erros
- [ ] Todos os gráficos foram gerados e salvos
- [ ] Relatório Rmd compila em HTML/PDF
- [ ] Apresentação Rmd compila em slides
- [ ] README está atualizado
- [ ] Código está comentado e limpo
- [ ] Interpretações estão claras e justificadas
- [ ] Hiperparâmetros (M, m, K) foram escolhidos com critérios objetivos
- [ ] Comparação PCA vs EFA está documentada
- [ ] Clusters foram caracterizados e validados

---

## 📋 NOTAS IMPORTANTES

1. **Padronização é Crítica**
   - Sempre trabalhar com Z-scores para PCA e Clustering
   - EFA também se beneficia de padronização

2. **Re-estimação em EFA**
   - Ao contrário de PCA, EFA requer re-estimar modelo para cada m
   - Não podemos simplesmente "cortar" componentes

3. **Interpretação > Otimização**
   - Preferir soluções interpretáveis a soluções matematicamente ótimas
   - K=4 interpretável > K=7 com Silhueta marginalmente melhor

4. **Validação Prática**
   - Sempre verificar se resultados fazem sentido no domínio bancário
   - Consultar nomes de bancos em cada cluster

5. **Documentação Contínua**
   - Anotar decisões e justificativas à medida que avança
   - Facilita escrita do relatório final

---

## 🔄 PROCESSO ITERATIVO

Este plano é um guia, não uma receita rígida.

**Esteja preparado para**:
- Voltar à análise descritiva se houver problemas
- Ajustar número de componentes/fatores/clusters
- Re-testar com diferentes métodos
- Remover/adicionar variáveis se necessário

**O objetivo é produzir análises robustas e interpretáveis, não seguir o plano cegamente.**

---

**Data de Criação**: 2025-11-15
**Última Atualização**: [Atualizar conforme progresso]