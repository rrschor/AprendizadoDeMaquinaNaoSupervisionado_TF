# Análise Bancária com Técnicas Não Supervisionadas - Plano de Implementação

> **Para Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implementar análise multivariada completa de dados bancários brasileiros usando PCA, EFA e Clustering com relatório e apresentação.

**Architecture:** Análise modular em 4 scripts R separados (descritiva, PCA, EFA, clustering) + 2 documentos R Markdown (relatório e slides). Cada análise gera outputs padronizados salvos em `outputs/`. Checkpoint obrigatório entre fases para validar resultados antes de prosseguir.

**Tech Stack:** R, tidyverse, psych (PCA/EFA), factoextra (clustering), corrplot (visualizações), knitr/rmarkdown (documentação)

---

## PRINCÍPIO FUNDAMENTAL

**CHECKPOINT OBRIGATÓRIO APÓS CADA TAREFA PRINCIPAL**

Antes de prosseguir para próxima fase:
1. Executar script e verificar outputs
2. Analisar resultados criticamente
3. Documentar decisões (hiperparâmetros M, m, K)
4. Ajustar plano se necessário

---

## Tarefa 1: Refatorar Preparação de Dados

**Files:**
- Modify: `apresentacao_uriel/df_banco.R:1-110`

### Step 1: Adicionar cabeçalho e padronização explícita

Modificar o script para adicionar documentação e padronização explícita no final:

```r
# ==============================================================================
# PREPARAÇÃO DE DADOS - ANÁLISE BANCÁRIA
# ==============================================================================
# Objetivo: Limpar, transformar e padronizar dados bancários para análises
# Outputs: df_bancos (limpo), df_limpo (reduzido), df_limpo_padro (Z-scores)
# ==============================================================================

library(dplyr)
library(purrr)
library(tidyverse)
library(janitor)
library(data.table)
library(psych)
library(corrplot)

# --- CARREGAMENTO E LIMPEZA ---

dados <- read_csv2(
  "apresentacao_uriel/dados.csv",
  locale = locale(decimal_mark = ",", grouping_mark = ".")
) |>
  clean_names() |>
  select(-x22) |>
  filter(if_all(everything(), ~ . != "NI")) |>
  mutate(
    across(
      c(
        ativo_total,
        carteira_de_credito,
        titulos_e_valores_mobiliarios,
        passivo_exigivel,
        captacoes,
        patrimonio_liquido,
        lucro_liquido,
        patrimonio_de_referencia_para_comparacao_com_o_rwa_e,
        indice_de_basileia,
        indice_de_imobilizacao,
        numero_de_agencias,
        numero_de_postos_de_atendimento
      ),
      ~ as.numeric(
        gsub(",", ".",
             gsub("%", "",
                  gsub("\\.", "", .)))
      )
    )
  ) |>
  na.omit()

# --- SELEÇÃO DE VARIÁVEIS ---

# Dataset completo (12 variáveis)
df_bancos <- dados |>
  select(
    ativo_total,
    carteira_de_credito,
    titulos_e_valores_mobiliarios,
    passivo_exigivel,
    captacoes,
    patrimonio_liquido,
    lucro_liquido,
    patrimonio_de_referencia_para_comparacao_com_o_rwa_e,
    indice_de_basileia,
    indice_de_imobilizacao,
    numero_de_agencias,
    numero_de_postos_de_atendimento
  ) |>
  mutate(
    indice_de_basileia = indice_de_basileia/100,
    indice_de_imobilizacao = indice_de_imobilizacao/100
  )

# Dataset reduzido (8 variáveis - remove variáveis altamente correlacionadas)
df_limpo <- dados |>
  select(
    ativo_total,
    carteira_de_credito,
    patrimonio_liquido,
    lucro_liquido,
    indice_de_basileia,
    indice_de_imobilizacao,
    numero_de_agencias,
    numero_de_postos_de_atendimento
  ) |>
  mutate(
    indice_de_basileia = indice_de_basileia/100,
    indice_de_imobilizacao = indice_de_imobilizacao/100
  )

# Nomes dos bancos para referência
bancos <- dados$instituicao

# --- PADRONIZAÇÃO (Z-SCORES) ---
# CRÍTICO: PCA e K-Means são sensíveis à escala
# Z-score: (x - mean(x)) / sd(x)
# Resultado: média=0, desvio padrão=1

df_limpo_padro <- scale(df_limpo)

# Verificar padronização
cat("\n=== VERIFICAÇÃO DE PADRONIZAÇÃO ===\n")
cat("Médias (devem ser ~0):\n")
print(round(colMeans(df_limpo_padro), 10))
cat("\nDesvios padrão (devem ser 1):\n")
print(round(apply(df_limpo_padro, 2, sd), 10))

# --- TESTES PRELIMINARES (KMO E BARTLETT) ---

kmo_result <- KMO(df_limpo_padro)
bartlett_result <- cortest.bartlett(df_limpo_padro)

cat("\n=== TESTES DE ADEQUAÇÃO ===\n")
cat("KMO Overall MSA:", round(kmo_result$MSA, 3), "\n")
cat("Bartlett p-value:", format(bartlett_result$p.value, scientific = TRUE), "\n")

# --- MATRIZ DE CORRELAÇÃO ---

cor_mat <- cor(df_limpo_padro)
corrplot(cor_mat, method = "color", type = "upper", tl.cex = 0.7,
         title = "Matriz de Correlação - Dados Bancários",
         mar = c(0, 0, 2, 0))

# --- OUTPUTS CONFIRMADOS ---

cat("\n=== DATASETS DISPONÍVEIS ===\n")
cat("df_bancos:", nrow(df_bancos), "obs x", ncol(df_bancos), "vars\n")
cat("df_limpo:", nrow(df_limpo), "obs x", ncol(df_limpo), "vars\n")
cat("df_limpo_padro:", nrow(df_limpo_padro), "obs x", ncol(df_limpo_padro), "vars (Z-scores)\n")
cat("bancos:", length(bancos), "nomes\n")
```

### Step 2: Executar script e verificar outputs

Run: `Rscript apresentacao_uriel/df_banco.R`

Expected output:
```
=== VERIFICAÇÃO DE PADRONIZAÇÃO ===
Médias (devem ser ~0):
[valores próximos a 0]

Desvios padrão (devem ser 1):
[valores todos = 1]

=== TESTES DE ADEQUAÇÃO ===
KMO Overall MSA: [valor entre 0 e 1]
Bartlett p-value: [valor < 0.05]

=== DATASETS DISPONÍVEIS ===
df_bancos: [n] obs x 12 vars
df_limpo: [n] obs x 8 vars
df_limpo_padro: [n] obs x 8 vars (Z-scores)
bancos: [n] nomes
```

### Step 3: Commit

```bash
git add apresentacao_uriel/df_banco.R
git commit -m "refactor: add explicit standardization and validation to data preparation"
```

---

## Tarefa 2: Análise Descritiva

**Files:**
- Create: `apresentacao_uriel/01_analise_descritiva.R`
- Create: `apresentacao_uriel/outputs/` (directory)

### Step 1: Criar diretório de outputs

Run: `mkdir -p apresentacao_uriel/outputs`

### Step 2: Criar script de análise descritiva

```r
# ==============================================================================
# ANÁLISE DESCRITIVA - DADOS BANCÁRIOS
# ==============================================================================
# Objetivo: Estatísticas sumárias, visualizações, matrizes de variabilidade
# Dependência: Executar df_banco.R primeiro
# Outputs: Tabelas e gráficos em outputs/
# ==============================================================================

library(tidyverse)
library(corrplot)
library(knitr)
library(kableExtra)

# Carregar dados preparados
source("apresentacao_uriel/df_banco.R")

# Criar diretório de outputs se não existir
dir.create("apresentacao_uriel/outputs", showWarnings = FALSE)

# --- 1. ESTATÍSTICAS SUMÁRIAS UNIVARIADAS ---

cat("\n=== ESTATÍSTICAS DESCRITIVAS ===\n")

estatisticas <- df_limpo |>
  summarise(across(everything(), list(
    media = mean,
    mediana = median,
    dp = sd,
    min = min,
    max = max,
    q25 = ~quantile(., 0.25),
    q75 = ~quantile(., 0.75)
  ))) |>
  pivot_longer(everything(),
               names_to = c("variavel", "estatistica"),
               names_sep = "_(?=[^_]+$)") |>
  pivot_wider(names_from = estatistica, values_from = value)

print(estatisticas)

# Salvar tabela
write_csv(estatisticas, "apresentacao_uriel/outputs/01_estatisticas_descritivas.csv")

# --- 2. MATRIZES DE VARIABILIDADE MULTIVARIADA ---

# Matriz de Variâncias-Covariâncias (Σ̂)
cov_mat <- cov(df_limpo)
cat("\n=== MATRIZ DE VARIÂNCIAS-COVARIÂNCIAS (Σ̂) ===\n")
print(round(cov_mat, 2))

# Matriz de Correlações (Ĉ)
cor_mat <- cor(df_limpo)
cat("\n=== MATRIZ DE CORRELAÇÕES (Ĉ) ===\n")
print(round(cor_mat, 3))

# Salvar matrizes
write.csv(cov_mat, "apresentacao_uriel/outputs/01_matriz_covariancias.csv")
write.csv(cor_mat, "apresentacao_uriel/outputs/01_matriz_correlacoes.csv")

# --- 3. VISUALIZAÇÕES ---

# 3a. Histogramas
pdf("apresentacao_uriel/outputs/01_histogramas.pdf", width = 12, height = 8)
df_limpo |>
  pivot_longer(everything(), names_to = "variavel", values_to = "valor") |>
  ggplot(aes(x = valor)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  facet_wrap(~variavel, scales = "free") +
  theme_minimal() +
  labs(title = "Distribuições das Variáveis",
       x = "Valor", y = "Frequência")
dev.off()

# 3b. Boxplots
pdf("apresentacao_uriel/outputs/01_boxplots.pdf", width = 12, height = 6)
df_limpo |>
  pivot_longer(everything(), names_to = "variavel", values_to = "valor") |>
  ggplot(aes(x = variavel, y = valor)) +
  geom_boxplot(fill = "steelblue", alpha = 0.7) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Boxplots - Identificação de Outliers",
       x = "Variável", y = "Valor")
dev.off()

# 3c. Violin Plots
pdf("apresentacao_uriel/outputs/01_violin_plots.pdf", width = 12, height = 6)
df_limpo |>
  pivot_longer(everything(), names_to = "variavel", values_to = "valor") |>
  ggplot(aes(x = variavel, y = valor)) +
  geom_violin(fill = "steelblue", alpha = 0.7) +
  geom_boxplot(width = 0.1, fill = "white", alpha = 0.8) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Violin Plots - Densidade das Distribuições",
       x = "Variável", y = "Valor")
dev.off()

# 3d. Matriz de Correlação Visual
pdf("apresentacao_uriel/outputs/01_corrplot.pdf", width = 10, height = 10)
corrplot(cor_mat, method = "color", type = "upper",
         tl.col = "black", tl.srt = 45,
         addCoef.col = "black", number.cex = 0.7,
         title = "Matriz de Correlação - Avaliação de Redundância",
         mar = c(0, 0, 2, 0))
dev.off()

# --- 4. IDENTIFICAÇÃO DE OUTLIERS ---

# Contar outliers por variável (critério: > Q3 + 1.5*IQR ou < Q1 - 1.5*IQR)
outliers_count <- df_limpo |>
  summarise(across(everything(), ~{
    q1 <- quantile(., 0.25)
    q3 <- quantile(., 0.75)
    iqr <- q3 - q1
    sum(. < (q1 - 1.5*iqr) | . > (q3 + 1.5*iqr))
  })) |>
  pivot_longer(everything(), names_to = "variavel", values_to = "n_outliers")

cat("\n=== CONTAGEM DE OUTLIERS (Critério: IQR) ===\n")
print(outliers_count)

write_csv(outliers_count, "apresentacao_uriel/outputs/01_outliers_count.csv")

# --- 5. ANÁLISE DE CORRELAÇÕES FORTES ---

# Identificar pares com |r| > 0.7
cor_fortes <- cor_mat |>
  as.data.frame() |>
  rownames_to_column("var1") |>
  pivot_longer(-var1, names_to = "var2", values_to = "correlacao") |>
  filter(var1 < var2, abs(correlacao) > 0.7) |>
  arrange(desc(abs(correlacao)))

cat("\n=== CORRELAÇÕES FORTES (|r| > 0.7) ===\n")
print(cor_fortes)

write_csv(cor_fortes, "apresentacao_uriel/outputs/01_correlacoes_fortes.csv")

# --- RESUMO FINAL ---

cat("\n=== ANÁLISE DESCRITIVA CONCLUÍDA ===\n")
cat("Outputs salvos em: apresentacao_uriel/outputs/01_*.{csv,pdf}\n")
cat("\nPróximo passo: Revisar CHECKPOINT 1 em PLANO_EXECUCAO.md\n")
```

### Step 3: Executar e verificar outputs

Run: `Rscript apresentacao_uriel/01_analise_descritiva.R`

Expected:
- Estatísticas impressas no console
- 6 arquivos criados em `apresentacao_uriel/outputs/`
- Mensagem final de conclusão

### Step 4: Commit

```bash
git add apresentacao_uriel/01_analise_descritiva.R apresentacao_uriel/outputs/
git commit -m "feat: add descriptive analysis with summary statistics and visualizations"
```

---

## 🔍 CHECKPOINT 1: Análise Descritiva

**PARAR AQUI E ANALISAR**

### Step 1: Revisar correlações

1. Abrir: `apresentacao_uriel/outputs/01_correlacoes_fortes.csv`
2. Abrir PDF: `apresentacao_uriel/outputs/01_corrplot.pdf`

**Perguntas:**
- Existem correlações |r| > 0.7?
- Isso justifica redução dimensional?
- Variáveis de tamanho (ativo, patrimônio) estão correlacionadas?

### Step 2: Revisar outliers

1. Abrir: `apresentacao_uriel/outputs/01_outliers_count.csv`
2. Abrir PDF: `apresentacao_uriel/outputs/01_boxplots.pdf`

**Decisão:**
- Outliers são bancos grandes legítimos (Itaú, BB, Bradesco)?
- Manter outliers (representam variabilidade real)
- Ou transformar variáveis (log)?

### Step 3: Avaliar distribuições

Abrir: `apresentacao_uriel/outputs/01_histogramas.pdf`

**Perguntas:**
- Há assimetria forte?
- Dados aproximam-se de normalidade multivariada?
- Necessário transformação Box-Cox?

### Step 4: Documentar decisões

Criar: `apresentacao_uriel/outputs/CHECKPOINT_1_decisoes.md`

```markdown
# Checkpoint 1: Decisões

**Data**: [YYYY-MM-DD]

## Correlações
- [Descrever correlações fortes encontradas]
- Justifica PCA/EFA: [SIM/NÃO]

## Outliers
- Decisão: [MANTER/REMOVER/TRANSFORMAR]
- Justificativa: [...]

## Distribuições
- Transformação necessária: [SIM/NÃO]
- Se sim, qual: [log/Box-Cox/outra]

## Próximo Passo
- Prosseguir para PCA com [N] observações e [p] variáveis
```

### Step 5: Commit decisões

```bash
git add apresentacao_uriel/outputs/CHECKPOINT_1_decisoes.md
git commit -m "docs: document checkpoint 1 decisions on outliers and transformations"
```

---

## Tarefa 3: PCA - Análise de Componentes Principais

**Files:**
- Create: `apresentacao_uriel/02_pca.R`

### Step 1: Criar script PCA

```r
# ==============================================================================
# PCA - ANÁLISE DE COMPONENTES PRINCIPAIS
# ==============================================================================
# Objetivo: Decomposição de variância, escolha de M componentes, interpretação
# Dependência: Executar df_banco.R primeiro
# Outputs: Tabelas, gráficos e escores em outputs/
# ==============================================================================

library(tidyverse)
library(factoextra)
library(FactoMineR)

# Carregar dados padronizados
source("apresentacao_uriel/df_banco.R")

cat("\n=== INICIANDO PCA ===\n")

# --- 1. EXECUTAR PCA ---
# Usamos df_limpo_padro (dados padronizados Z-scores)
# PCA sobre matriz de correlações

pca_result <- prcomp(df_limpo_padro, scale. = FALSE)  # Já está padronizado

# Autovalores (variância de cada componente)
eigenvalues <- pca_result$sdev^2

# --- 2. TABELA DE DECOMPOSIÇÃO DE VARIÂNCIA ---

pca_summary <- data.frame(
  Componente = paste0("PC", 1:length(eigenvalues)),
  Autovalor = eigenvalues,
  Variancia_Explicada = eigenvalues / sum(eigenvalues) * 100,
  Variancia_Acumulada = cumsum(eigenvalues / sum(eigenvalues) * 100)
)

cat("\n=== DECOMPOSIÇÃO DE VARIÂNCIA ===\n")
print(pca_summary)

write_csv(pca_summary, "apresentacao_uriel/outputs/02_pca_variancia.csv")

# --- 3. CRITÉRIOS PARA ESCOLHA DE M ---

# a) Regra de Kaiser: λ ≥ 1
m_kaiser <- sum(eigenvalues >= 1)
cat("\n=== CRITÉRIO DE KAISER (λ ≥ 1) ===\n")
cat("Número de componentes:", m_kaiser, "\n")

# b) Scree Plot
pdf("apresentacao_uriel/outputs/02_scree_plot.pdf", width = 10, height = 6)
fviz_eig(pca_result, addlabels = TRUE, ylim = c(0, 50),
         main = "Scree Plot - Escolha de Componentes (Regra do Cotovelo)")
abline(h = 1, lty = 2, col = "red")  # Linha de Kaiser
dev.off()

# c) Cut-off de variância (75% e 80%)
m_75 <- which(pca_summary$Variancia_Acumulada >= 75)[1]
m_80 <- which(pca_summary$Variancia_Acumulada >= 80)[1]

cat("\n=== CRITÉRIO DE CUT-OFF ===\n")
cat("Componentes para 75% variância:", m_75, "\n")
cat("Componentes para 80% variância:", m_80, "\n")

# Salvar critérios
criterios <- data.frame(
  Criterio = c("Kaiser (λ≥1)", "Cut-off 75%", "Cut-off 80%"),
  M_componentes = c(m_kaiser, m_75, m_80)
)
write_csv(criterios, "apresentacao_uriel/outputs/02_criterios_m.csv")

# --- 4. LOADINGS (PESOS) ---

loadings <- pca_result$rotation
colnames(loadings) <- paste0("PC", 1:ncol(loadings))

cat("\n=== LOADINGS (Matriz W) - Primeiras 4 CPs ===\n")
print(round(loadings[, 1:min(4, ncol(loadings))], 3))

write_csv(as.data.frame(loadings) |> rownames_to_column("variavel"),
          "apresentacao_uriel/outputs/02_pca_loadings.csv")

# --- 5. BIPLOT ---

pdf("apresentacao_uriel/outputs/02_biplot.pdf", width = 12, height = 10)
fviz_pca_biplot(pca_result,
                repel = TRUE,
                col.var = "contrib",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                col.ind = "gray",
                title = "Biplot PCA - PC1 vs PC2")
dev.off()

# --- 6. CONTRIBUIÇÃO DAS VARIÁVEIS ---

pdf("apresentacao_uriel/outputs/02_contrib_vars.pdf", width = 10, height = 6)
fviz_contrib(pca_result, choice = "var", axes = 1:2,
             title = "Contribuição das Variáveis para PC1 e PC2")
dev.off()

# --- 7. ESCORES (REDUÇÃO DIMENSIONAL) ---

# Usar M = max(m_kaiser, m_75) como padrão
M <- max(m_kaiser, m_75)

scores <- pca_result$x[, 1:M]
scores_df <- as.data.frame(scores) |>
  mutate(banco = bancos)

cat("\n=== MATRIZ DE ESCORES (Redução Dimensional) ===\n")
cat("Dimensões originais: 8 variáveis\n")
cat("Dimensões reduzidas:", M, "componentes\n")
cat("Variância retida:", round(pca_summary$Variancia_Acumulada[M], 2), "%\n")

write_csv(scores_df, "apresentacao_uriel/outputs/02_pca_scores.csv")

# --- 8. INTERPRETAÇÃO ASSISTIDA ---

cat("\n=== INTERPRETAÇÃO DAS COMPONENTES ===\n")
for(i in 1:min(M, 4)) {
  cat("\n--- PC", i, "(", round(pca_summary$Variancia_Explicada[i], 1), "% variância) ---\n")

  # Top 3 variáveis (loadings mais altos em valor absoluto)
  top_vars <- loadings[, i] |>
    abs() |>
    sort(decreasing = TRUE) |>
    head(3)

  cat("Variáveis principais:\n")
  for(var_name in names(top_vars)) {
    loading_val <- loadings[var_name, i]
    cat("  -", var_name, ":", round(loading_val, 3), "\n")
  }
}

cat("\n=== PCA CONCLUÍDA ===\n")
cat("Outputs salvos em: apresentacao_uriel/outputs/02_*.{csv,pdf}\n")
cat("\nPróximo passo: Revisar CHECKPOINT 2 em PLANO_EXECUCAO.md\n")
```

### Step 2: Executar PCA

Run: `Rscript apresentacao_uriel/02_pca.R`

Expected:
- Tabela de variância explicada
- Critérios de Kaiser, 75%, 80%
- Loadings das primeiras 4 CPs
- Interpretação automática
- 5 arquivos criados em outputs/

### Step 3: Commit

```bash
git add apresentacao_uriel/02_pca.R apresentacao_uriel/outputs/02_*
git commit -m "feat: implement PCA with variance decomposition and component selection"
```

---

## 🔍 CHECKPOINT 2: PCA

**PARAR AQUI E ANALISAR**

### Step 1: Revisar escolha de M

1. Abrir: `apresentacao_uriel/outputs/02_criterios_m.csv`
2. Abrir: `apresentacao_uriel/outputs/02_scree_plot.pdf`

**Decisão:**
- Kaiser sugere: [M_kaiser]
- 75% sugere: [M_75]
- Cotovelo visual no scree plot: [M_visual]
- **ESCOLHA FINAL: M = [?]**

### Step 2: Interpretar loadings

1. Abrir: `apresentacao_uriel/outputs/02_pca_loadings.csv`
2. Console output da interpretação

**Para cada CP escolhida:**
- PC1: [Nome interpretativo, ex: "Tamanho do Banco"]
- PC2: [Nome interpretativo, ex: "Solidez Financeira"]
- PC3: [...]

### Step 3: Analisar biplot

Abrir: `apresentacao_uriel/outputs/02_biplot.pdf`

**Observações:**
- Outliers multivariados evidentes?
- Grupos naturais de bancos?
- Variáveis se agrupam conforme esperado?

### Step 4: Documentar decisões

Criar: `apresentacao_uriel/outputs/CHECKPOINT_2_decisoes.md`

```markdown
# Checkpoint 2: Decisões PCA

**Data**: [YYYY-MM-DD]

## Número de Componentes
- Kaiser: [M]
- Cut-off 75%: [M]
- Scree plot (visual): [M]
- **DECISÃO: M = [?]**
- Variância retida: [X]%

## Interpretação das Componentes
- PC1: [Nome] - [Descrição]
- PC2: [Nome] - [Descrição]
- [...]

## Observações do Biplot
- Outliers: [Lista de bancos se houver]
- Grupos: [Descrição]

## Para EFA
- Usar m = [M ou diferente?]
- Justificativa: [...]
```

### Step 5: Commit decisões

```bash
git add apresentacao_uriel/outputs/CHECKPOINT_2_decisoes.md
git commit -m "docs: document PCA checkpoint decisions on M components"
```

---

## Tarefa 4: EFA - Análise Fatorial Exploratória

**Files:**
- Create: `apresentacao_uriel/03_efa.R`

### Step 1: Criar script EFA

```r
# ==============================================================================
# EFA - ANÁLISE FATORIAL EXPLORATÓRIA
# ==============================================================================
# Objetivo: Estimar fatores latentes, escolher m fatores, rotação, escores
# Dependência: Executar df_banco.R primeiro
# Outputs: Tabelas de cargas, comunalidades, escores em outputs/
# ==============================================================================

library(tidyverse)
library(psych)
library(GPArotation)

# Carregar dados padronizados
source("apresentacao_uriel/df_banco.R")

cat("\n=== INICIANDO EFA ===\n")

# --- 1. TESTES DE ADEQUAÇÃO ---

kmo_result <- KMO(df_limpo_padro)
bartlett_result <- cortest.bartlett(df_limpo_padro)

cat("\n=== TESTES DE ADEQUAÇÃO ===\n")
cat("KMO Overall MSA:", round(kmo_result$MSA, 3), "\n")
cat("Interpretação:", ifelse(kmo_result$MSA >= 0.9, "Excelente",
                         ifelse(kmo_result$MSA >= 0.8, "Bom",
                         ifelse(kmo_result$MSA >= 0.7, "Médio", "Inadequado"))), "\n")
cat("\nBartlett:\n")
cat("  Chi-square:", round(bartlett_result$chisq, 2), "\n")
cat("  p-value:", format(bartlett_result$p.value, scientific = TRUE), "\n")
cat("  Rejeita H0:", bartlett_result$p.value < 0.05, "\n")

adequacao <- data.frame(
  Teste = c("KMO", "Bartlett"),
  Valor = c(kmo_result$MSA, bartlett_result$chisq),
  p_value = c(NA, bartlett_result$p.value)
)
write_csv(adequacao, "apresentacao_uriel/outputs/03_adequacao.csv")

# --- 2. DETERMINAR NÚMERO DE FATORES (m) ---

# Análise paralela (recomendado)
parallel <- fa.parallel(df_limpo_padro, fa = "fa", n.iter = 100)

m_parallel <- parallel$nfact
cat("\n=== ANÁLISE PARALELA ===\n")
cat("Número de fatores sugerido:", m_parallel, "\n")

# Capturar gráfico de análise paralela
pdf("apresentacao_uriel/outputs/03_parallel_analysis.pdf", width = 10, height = 6)
fa.parallel(df_limpo_padro, fa = "fa", n.iter = 100,
            main = "Análise Paralela - Escolha de m Fatores")
dev.off()

# --- 3. TESTAR DIFERENTES VALORES DE m ---

# Testar m = 1 até 5 (ou até m_parallel + 1)
m_max <- min(5, m_parallel + 1, ncol(df_limpo_padro) - 1)

efa_tests <- list()
for(m in 1:m_max) {
  cat("\nTestando m =", m, "fatores...\n")

  efa_ml <- fa(df_limpo_padro, nfactors = m, rotate = "none", fm = "ml")

  efa_tests[[m]] <- list(
    m = m,
    modelo = efa_ml,
    var_explicada = sum(efa_ml$communality) / ncol(df_limpo_padro) * 100,
    RMSEA = efa_ml$RMSEA[1],
    TLI = efa_ml$TLI
  )
}

# Tabela comparativa
comp_m <- data.frame(
  m_fatores = sapply(efa_tests, function(x) x$m),
  var_explicada_pct = sapply(efa_tests, function(x) round(x$var_explicada, 2)),
  RMSEA = sapply(efa_tests, function(x) round(x$RMSEA, 3)),
  TLI = sapply(efa_tests, function(x) round(x$TLI, 3))
)

cat("\n=== COMPARAÇÃO DE MODELOS (m fatores) ===\n")
print(comp_m)

write_csv(comp_m, "apresentacao_uriel/outputs/03_comparacao_m.csv")

# --- 4. ESCOLHER m E ESTIMAR MODELO FINAL ---

# Usar sugestão da análise paralela ou critério de 40% variância
m_escolhido <- m_parallel

cat("\n=== MODELO FINAL COM m =", m_escolhido, "===\n")

# Modelo sem rotação
efa_sem_rotacao <- fa(df_limpo_padro, nfactors = m_escolhido,
                       rotate = "none", fm = "ml", scores = "regression")

# Modelo com Varimax (ortogonal)
efa_varimax <- fa(df_limpo_padro, nfactors = m_escolhido,
                  rotate = "varimax", fm = "ml", scores = "regression")

# Modelo com Promax (oblíqua)
efa_promax <- fa(df_limpo_padro, nfactors = m_escolhido,
                 rotate = "promax", fm = "ml", scores = "regression")

# --- 5. CARGAS FATORIAIS ---

cat("\n=== CARGAS FATORIAIS (Varimax) ===\n")
print(round(efa_varimax$loadings, 3))

# Salvar cargas
loadings_varimax <- data.frame(
  variavel = rownames(efa_varimax$loadings),
  efa_varimax$loadings[1:nrow(efa_varimax$loadings), 1:m_escolhido]
)
write_csv(loadings_varimax, "apresentacao_uriel/outputs/03_cargas_varimax.csv")

loadings_promax <- data.frame(
  variavel = rownames(efa_promax$loadings),
  efa_promax$loadings[1:nrow(efa_promax$loadings), 1:m_escolhido]
)
write_csv(loadings_promax, "apresentacao_uriel/outputs/03_cargas_promax.csv")

# --- 6. COMUNALIDADES E ESPECIFICIDADES ---

comunalidades <- data.frame(
  variavel = colnames(df_limpo_padro),
  comunalidade = efa_varimax$communality,
  especificidade = 1 - efa_varimax$communality,
  unicidade = efa_varimax$uniquenesses
)

cat("\n=== COMUNALIDADES (h²) ===\n")
print(comunalidades)

write_csv(comunalidades, "apresentacao_uriel/outputs/03_comunalidades.csv")

# Alertar variáveis com baixa comunalidade
baixas <- comunalidades |> filter(comunalidade < 0.4)
if(nrow(baixas) > 0) {
  cat("\n⚠ ALERTA: Variáveis com comunalidade < 0.4:\n")
  print(baixas$variavel)
}

# --- 7. ESCORES FATORIAIS (Método de Thompson/Regressão) ---

scores_efa <- efa_varimax$scores
scores_efa_df <- as.data.frame(scores_efa) |>
  mutate(banco = bancos)

cat("\n=== ESCORES FATORIAIS (Redução Dimensional) ===\n")
cat("Dimensões originais: 8 variáveis\n")
cat("Dimensões reduzidas:", m_escolhido, "fatores\n")
cat("Variância explicada:", round(sum(efa_varimax$communality)/8*100, 2), "%\n")

write_csv(scores_efa_df, "apresentacao_uriel/outputs/03_efa_scores.csv")

# --- 8. VISUALIZAÇÃO DAS CARGAS ---

pdf("apresentacao_uriel/outputs/03_loadings_plot.pdf", width = 10, height = 8)
fa.diagram(efa_varimax, main = "Diagrama de Cargas Fatoriais (Varimax)")
dev.off()

# --- 9. INTERPRETAÇÃO ASSISTIDA ---

cat("\n=== INTERPRETAÇÃO DOS FATORES (Varimax) ===\n")
for(i in 1:m_escolhido) {
  cat("\n--- Fator", i, "---\n")

  # Cargas > 0.4 em valor absoluto
  cargas_fator <- efa_varimax$loadings[, i]
  cargas_importantes <- cargas_fator[abs(cargas_fator) > 0.4]
  cargas_importantes <- sort(abs(cargas_importantes), decreasing = TRUE)

  if(length(cargas_importantes) > 0) {
    cat("Variáveis importantes (|λ| > 0.4):\n")
    for(var_name in names(cargas_importantes)) {
      loading_val <- efa_varimax$loadings[var_name, i]
      cat("  -", var_name, ":", round(loading_val, 3), "\n")
    }
  } else {
    cat("Nenhuma variável com |λ| > 0.4\n")
  }
}

cat("\n=== EFA CONCLUÍDA ===\n")
cat("Outputs salvos em: apresentacao_uriel/outputs/03_*.{csv,pdf}\n")
cat("\nPróximo passo: Revisar CHECKPOINT 3 em PLANO_EXECUCAO.md\n")
```

### Step 2: Executar EFA

Run: `Rscript apresentacao_uriel/03_efa.R`

Expected:
- Testes KMO e Bartlett
- Análise paralela
- Comparação de modelos com diferentes m
- Cargas fatoriais (Varimax e Promax)
- Comunalidades
- Interpretação dos fatores
- 7 arquivos criados em outputs/

### Step 3: Commit

```bash
git add apresentacao_uriel/03_efa.R apresentacao_uriel/outputs/03_*
git commit -m "feat: implement EFA with factor extraction, rotation and scores"
```

---

## 🔍 CHECKPOINT 3: EFA

**PARAR AQUI E ANALISAR**

### Step 1: Validar adequação

1. Abrir: `apresentacao_uriel/outputs/03_adequacao.csv`

**Validações:**
- KMO ≥ 0.7? [SIM/NÃO]
- Bartlett p < 0.05? [SIM/NÃO]
- Se inadequado: remover variáveis problemáticas

### Step 2: Escolher m

1. Abrir: `apresentacao_uriel/outputs/03_comparacao_m.csv`
2. Abrir: `apresentacao_uriel/outputs/03_parallel_analysis.pdf`

**Decisão:**
- Análise paralela sugere: [m]
- Variância explicada com m fatores: [X]%
- RMSEA e TLI aceitáveis?
- **ESCOLHA FINAL: m = [?]**

### Step 3: Escolher rotação

1. Comparar: `03_cargas_varimax.csv` vs `03_cargas_promax.csv`

**Decisão:**
- Varimax ou Promax oferece melhor interpretabilidade?
- Fatores devem ser ortogonais ou podem ser correlacionados?
- **ESCOLHA: [Varimax/Promax]**

### Step 4: Interpretar fatores

Para cada fator (usando rotação escolhida):
- Fator 1: [Nome interpretativo]
- Fator 2: [Nome interpretativo]
- [...]

### Step 5: Comparar PCA vs EFA

**Comparação:**
- PCA: M = [?] componentes, [X]% variância
- EFA: m = [?] fatores, [Y]% variância explicada
- Interpretações convergem? [SIM/NÃO/PARCIALMENTE]
- Qual método mais adequado? [PCA/EFA/AMBOS]

### Step 6: Documentar decisões

Criar: `apresentacao_uriel/outputs/CHECKPOINT_3_decisoes.md`

```markdown
# Checkpoint 3: Decisões EFA

**Data**: [YYYY-MM-DD]

## Adequação
- KMO: [valor] - [classificação]
- Bartlett: p = [valor] - Adequado: [SIM/NÃO]

## Número de Fatores
- Análise paralela: [m]
- **DECISÃO: m = [?]**
- Variância explicada: [X]%

## Rotação
- **ESCOLHA: [Varimax/Promax]**
- Justificativa: [...]

## Interpretação dos Fatores
- F1: [Nome] - [Descrição]
- F2: [Nome] - [Descrição]
- [...]

## Comunalidades Baixas
- Variáveis com h² < 0.4: [lista ou "nenhuma"]

## Comparação PCA vs EFA
- Dimensionalidade: M = [?] vs m = [?]
- Convergência: [...]
- Método preferido: [...]
- Razão: [...]
```

### Step 7: Commit decisões

```bash
git add apresentacao_uriel/outputs/CHECKPOINT_3_decisoes.md
git commit -m "docs: document EFA checkpoint with factor interpretation and PCA comparison"
```

---

## Tarefa 5: Clustering

**Files:**
- Create: `apresentacao_uriel/04_clustering.R`

### Step 1: Criar script de clustering

```r
# ==============================================================================
# CLUSTERING - K-MEANS E HIERÁRQUICO
# ==============================================================================
# Objetivo: Agrupar bancos, escolher K, caracterizar clusters
# Dependência: Executar df_banco.R, 02_pca.R
# Outputs: Clusters, centróides, visualizações em outputs/
# ==============================================================================

library(tidyverse)
library(cluster)
library(factoextra)
library(NbClust)

# Carregar dados
source("apresentacao_uriel/df_banco.R")
source("apresentacao_uriel/02_pca.R")  # Para usar escores PCA

cat("\n=== INICIANDO CLUSTERING ===\n")

# --- 1. PREPARAR DADOS PARA CLUSTERING ---

# OPÇÃO 1: Dados originais padronizados
dados_clustering <- df_limpo_padro

# OPÇÃO 2 (alternativa): Escores PCA (descomentar se preferir)
# M <- max(m_kaiser, m_75)  # Usar decisão do CHECKPOINT 2
# dados_clustering <- pca_result$x[, 1:M]

cat("Dimensões para clustering:", nrow(dados_clustering), "obs x",
    ncol(dados_clustering), "vars\n")

# --- 2. MÉTODO DO COTOVELO ---

set.seed(123)  # Reprodutibilidade

wss <- numeric(10)
for(k in 1:10) {
  kmeans_temp <- kmeans(dados_clustering, centers = k, nstart = 25)
  wss[k] <- kmeans_temp$tot.withinss
}

cotovelo_df <- data.frame(K = 1:10, WSS = wss)

cat("\n=== MÉTODO DO COTOVELO ===\n")
print(cotovelo_df)

write_csv(cotovelo_df, "apresentacao_uriel/outputs/04_cotovelo.csv")

pdf("apresentacao_uriel/outputs/04_elbow_plot.pdf", width = 10, height = 6)
ggplot(cotovelo_df, aes(x = K, y = WSS)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  theme_minimal() +
  labs(title = "Método do Cotovelo - Escolha de K",
       x = "Número de Clusters (K)",
       y = "Soma de Quadrados Intra-Cluster (WSS)")
dev.off()

# --- 3. COEFICIENTE DE SILHUETA ---

silhouette_scores <- numeric(9)
for(k in 2:10) {
  kmeans_temp <- kmeans(dados_clustering, centers = k, nstart = 25)
  sil <- silhouette(kmeans_temp$cluster, dist(dados_clustering))
  silhouette_scores[k-1] <- mean(sil[, 3])
}

silhueta_df <- data.frame(K = 2:10, Silhueta_Media = silhouette_scores)

cat("\n=== COEFICIENTE DE SILHUETA ===\n")
print(silhueta_df)

write_csv(silhueta_df, "apresentacao_uriel/outputs/04_silhueta.csv")

pdf("apresentacao_uriel/outputs/04_silhouette_scores.pdf", width = 10, height = 6)
ggplot(silhueta_df, aes(x = K, y = Silhueta_Media)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "Coeficiente de Silhueta - Escolha de K",
       x = "Número de Clusters (K)",
       y = "Silhueta Média")
dev.off()

# --- 4. ESCOLHER K E EXECUTAR K-MEANS FINAL ---

# Usar K com maior Silhueta (ou decisão manual após análise)
K_escolhido <- silhueta_df$K[which.max(silhueta_df$Silhueta_Media)]

cat("\n=== K-MEANS FINAL COM K =", K_escolhido, "===\n")

set.seed(123)
kmeans_final <- kmeans(dados_clustering, centers = K_escolhido, nstart = 25)

# Estatísticas
cat("Tamanho dos clusters:\n")
print(table(kmeans_final$cluster))
cat("\nSilhueta média:", round(mean(silhouette(kmeans_final$cluster,
                                         dist(dados_clustering))[, 3]), 3), "\n")

# --- 5. CARACTERIZAÇÃO DOS CLUSTERS (CENTRÓIDES) ---

# Centróides no espaço original
centroides <- aggregate(df_limpo, by = list(Cluster = kmeans_final$cluster), mean)

cat("\n=== CENTRÓIDES DOS CLUSTERS ===\n")
print(centroides)

write_csv(centroides, "apresentacao_uriel/outputs/04_centroides.csv")

# Transpor para melhor visualização
centroides_t <- centroides |>
  pivot_longer(-Cluster, names_to = "Variavel", values_to = "Valor") |>
  pivot_wider(names_from = Cluster, values_from = Valor, names_prefix = "Cluster_")

write_csv(centroides_t, "apresentacao_uriel/outputs/04_centroides_transposto.csv")

# --- 6. BANCOS POR CLUSTER ---

bancos_cluster <- data.frame(
  Banco = bancos,
  Cluster = kmeans_final$cluster
) |>
  arrange(Cluster, Banco)

write_csv(bancos_cluster, "apresentacao_uriel/outputs/04_bancos_por_cluster.csv")

cat("\n=== EXEMPLOS DE BANCOS POR CLUSTER ===\n")
for(k in 1:K_escolhido) {
  cat("\nCluster", k, ":\n")
  exemplos <- bancos_cluster |> filter(Cluster == k) |> head(5)
  print(exemplos$Banco)
}

# --- 7. VISUALIZAÇÕES ---

# 7a. Biplot PCA colorido por cluster
if(exists("pca_result")) {
  pdf("apresentacao_uriel/outputs/04_biplot_clusters.pdf", width = 12, height = 10)
  fviz_pca_biplot(pca_result,
                  geom.ind = "point",
                  col.ind = as.factor(kmeans_final$cluster),
                  palette = "jco",
                  addEllipses = TRUE,
                  ellipse.level = 0.68,
                  legend.title = "Cluster",
                  repel = TRUE,
                  title = "Biplot PCA - Bancos Coloridos por Cluster")
  dev.off()
}

# 7b. Silhouette plot
pdf("apresentacao_uriel/outputs/04_silhouette_plot.pdf", width = 10, height = 8)
sil <- silhouette(kmeans_final$cluster, dist(dados_clustering))
fviz_silhouette(sil, palette = "jco",
                print.summary = TRUE,
                title = "Silhouette Plot - Qualidade dos Clusters")
dev.off()

# 7c. Parallel coordinates plot
bancos_com_cluster <- df_limpo |>
  mutate(Cluster = as.factor(kmeans_final$cluster))

pdf("apresentacao_uriel/outputs/04_parallel_coords.pdf", width = 14, height = 8)
bancos_com_cluster |>
  sample_n(min(100, nrow(bancos_com_cluster))) |>  # Amostra se muitos bancos
  pivot_longer(-Cluster, names_to = "Variavel", values_to = "Valor") |>
  ggplot(aes(x = Variavel, y = Valor, group = interaction(row_number(), Cluster),
             color = Cluster)) +
  geom_line(alpha = 0.3) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Parallel Coordinates - Perfis dos Clusters",
       x = "Variável", y = "Valor (original)")
dev.off()

# --- 8. CLUSTERING HIERÁRQUICO (COMPARAÇÃO) ---

cat("\n=== CLUSTERING HIERÁRQUICO ===\n")

# Ward's method
dist_matrix <- dist(dados_clustering, method = "euclidean")
hclust_ward <- hclust(dist_matrix, method = "ward.D2")

# Dendrograma
pdf("apresentacao_uriel/outputs/04_dendrograma.pdf", width = 14, height = 8)
plot(hclust_ward, labels = FALSE, main = "Dendrograma - Ward's Method",
     xlab = "", sub = "")
rect.hclust(hclust_ward, k = K_escolhido, border = "red")
dev.off()

# Cortar dendrograma com K_escolhido
clusters_hierarquico <- cutree(hclust_ward, k = K_escolhido)

# Comparar com K-Means (Tabela de contingência)
comparacao <- table(K_Means = kmeans_final$cluster,
                    Hierarquico = clusters_hierarquico)

cat("\n=== COMPARAÇÃO K-MEANS vs HIERÁRQUICO ===\n")
print(comparacao)

write.csv(comparacao, "apresentacao_uriel/outputs/04_comparacao_kmeans_hierarquico.csv")

# Adjusted Rand Index
library(mclust)
ari <- adjustedRandIndex(kmeans_final$cluster, clusters_hierarquico)
cat("\nAdjusted Rand Index:", round(ari, 3), "\n")
cat("Interpretação:", ifelse(ari > 0.8, "Alta concordância",
                          ifelse(ari > 0.5, "Concordância moderada",
                                 "Baixa concordância")), "\n")

# --- 9. BOXPLOTS POR CLUSTER ---

pdf("apresentacao_uriel/outputs/04_boxplots_clusters.pdf", width = 14, height = 10)
bancos_com_cluster |>
  pivot_longer(-Cluster, names_to = "Variavel", values_to = "Valor") |>
  ggplot(aes(x = Cluster, y = Valor, fill = Cluster)) +
  geom_boxplot() +
  facet_wrap(~Variavel, scales = "free_y") +
  theme_minimal() +
  labs(title = "Distribuições por Cluster",
       x = "Cluster", y = "Valor")
dev.off()

cat("\n=== CLUSTERING CONCLUÍDO ===\n")
cat("Outputs salvos em: apresentacao_uriel/outputs/04_*.{csv,pdf}\n")
cat("\nPróximo passo: Revisar CHECKPOINT 4 em PLANO_EXECUCAO.md\n")
```

### Step 2: Executar clustering

Run: `Rscript apresentacao_uriel/04_clustering.R`

Expected:
- Método do cotovelo e silhueta
- K-Means com K escolhido
- Centróides e caracterização
- Lista de bancos por cluster
- Clustering hierárquico
- Comparação entre métodos
- 10 arquivos criados em outputs/

### Step 3: Commit

```bash
git add apresentacao_uriel/04_clustering.R apresentacao_uriel/outputs/04_*
git commit -m "feat: implement k-means and hierarchical clustering with validation"
```

---

## 🔍 CHECKPOINT 4: Clustering

**PARAR AQUI E ANALISAR**

### Step 1: Escolher K

1. Abrir: `apresentacao_uriel/outputs/04_cotovelo.csv`
2. Abrir: `apresentacao_uriel/outputs/04_silhueta.csv`
3. Abrir PDFs dos gráficos

**Decisão:**
- Cotovelo sugere: [K]
- Silhueta máxima em: [K]
- Silhueta média: [valor] (>0.5 é bom)
- **DECISÃO FINAL: K = [?]**
- Balance interpretabilidade vs qualidade

### Step 2: Caracterizar clusters

1. Abrir: `apresentacao_uriel/outputs/04_centroides_transposto.csv`
2. Abrir: `apresentacao_uriel/outputs/04_boxplots_clusters.pdf`

**Para cada cluster, descrever perfil:**
- Cluster 1: [ex: "Grandes Bancos - alto ativo, muitas agências"]
- Cluster 2: [ex: "Bancos de Investimento - alto patrimônio, poucas agências"]
- [...]

### Step 3: Validar com exemplos reais

1. Abrir: `apresentacao_uriel/outputs/04_bancos_por_cluster.csv`

**Validações:**
- Itaú, BB, Bradesco no mesmo cluster?
- Nubank, XP juntos ou separados?
- Clusters fazem sentido prático?

### Step 4: Avaliar qualidade

1. Abrir: `apresentacao_uriel/outputs/04_silhouette_plot.pdf`

**Perguntas:**
- Há clusters com Silhueta negativa?
- Distribuição equilibrada ou 1 cluster dominante?
- Clusters bem separados no biplot?

### Step 5: Comparar métodos

1. Abrir: `apresentacao_uriel/outputs/04_comparacao_kmeans_hierarquico.csv`

**Análise:**
- Adjusted Rand Index: [valor]
- Concordância: [alta/média/baixa]
- Divergências indicam instabilidade?

### Step 6: Documentar decisões

Criar: `apresentacao_uriel/outputs/CHECKPOINT_4_decisoes.md`

```markdown
# Checkpoint 4: Decisões Clustering

**Data**: [YYYY-MM-DD]

## Escolha de K
- Cotovelo: [K]
- Silhueta: [K] (média = [valor])
- **DECISÃO: K = [?]**
- Justificativa: [balance entre métricas e interpretabilidade]

## Caracterização dos Clusters
- Cluster 1: [Nome] - [Perfil]
  - Exemplos: [bancos]
- Cluster 2: [Nome] - [Perfil]
  - Exemplos: [bancos]
- [...]

## Qualidade
- Silhueta média: [valor]
- Clusters bem separados: [SIM/NÃO]
- Tamanhos equilibrados: [SIM/NÃO]

## Comparação K-Means vs Hierárquico
- ARI: [valor]
- Concordância: [classificação]
- Método preferido: [K-Means/Hierárquico/Ambos]

## Relação com PCA/EFA
- Clusters se separam nas componentes principais: [SIM/NÃO]
- PCs explicam diferenças entre clusters: [descrição]
```

### Step 7: Commit decisões

```bash
git add apresentacao_uriel/outputs/CHECKPOINT_4_decisoes.md
git commit -m "docs: document clustering checkpoint with K selection and interpretation"
```

---

## Tarefa 6: Relatório Final em R Markdown

**Files:**
- Create: `apresentacao_uriel/relatorio_final.Rmd`

### Step 1: Criar estrutura do relatório

```rmarkdown
---
title: "Análise Multivariada de Dados Bancários Brasileiros"
subtitle: "PCA, EFA e Clustering"
author: "[Seu Nome]"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_float: true
    toc_depth: 3
    theme: flatly
    highlight: tango
    code_folding: hide
    df_print: paged
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = TRUE,
  warning = FALSE,
  message = FALSE,
  fig.width = 10,
  fig.height = 6
)

library(tidyverse)
library(knitr)
library(kableExtra)
```

# 1. Introdução

## 1.1 Contexto

Este relatório apresenta uma análise multivariada de dados bancários brasileiros utilizando técnicas de aprendizado não supervisionado.

## 1.2 Objetivos

- Reduzir dimensionalidade com PCA e EFA
- Identificar estrutura latente dos dados
- Agrupar bancos em tipologias homogêneas

## 1.3 Metodologias

- **PCA**: Análise de Componentes Principais
- **EFA**: Análise Fatorial Exploratória
- **Clustering**: K-Means e Hierárquico

---

# 2. Descrição dos Dados

## 2.1 Fonte

Dados bancários brasileiros referentes a março de 2025, obtidos de [fonte].

## 2.2 Variáveis Analisadas

```{r dados}
source("apresentacao_uriel/df_banco.R")

variaveis <- data.frame(
  Variável = colnames(df_limpo),
  Descrição = c(
    "Ativo Total",
    "Carteira de Crédito",
    "Patrimônio Líquido",
    "Lucro Líquido",
    "Índice de Basileia",
    "Índice de Imobilização",
    "Número de Agências",
    "Número de Postos de Atendimento"
  )
)

kable(variaveis, caption = "Variáveis Selecionadas para Análise") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

**Total de observações:** `r nrow(df_limpo)` bancos

## 2.3 Pré-processamento

1. Limpeza: remoção de valores ausentes e inconsistentes
2. Conversão de percentuais (Basileia, Imobilização)
3. **Padronização**: Z-scores (média=0, dp=1)

---

# 3. Análise Descritiva

## 3.1 Estatísticas Sumárias

```{r desc_stats}
estatisticas <- read_csv("apresentacao_uriel/outputs/01_estatisticas_descritivas.csv")

kable(estatisticas, digits = 2,
      caption = "Estatísticas Descritivas das Variáveis") |>
  kable_styling(bootstrap_options = c("striped", "hover"),
                full_width = FALSE)
```

## 3.2 Matriz de Correlações

```{r corrplot, fig.cap="Matriz de Correlação entre Variáveis"}
library(corrplot)
cor_mat <- cor(df_limpo)
corrplot(cor_mat, method = "color", type = "upper",
         tl.col = "black", addCoef.col = "black", number.cex = 0.7,
         title = "Correlações - Avaliação de Redundância",
         mar = c(0, 0, 2, 0))
```

**Correlações Fortes (|r| > 0.7):**

```{r cor_fortes}
cor_fortes <- read_csv("apresentacao_uriel/outputs/01_correlacoes_fortes.csv")

if(nrow(cor_fortes) > 0) {
  kable(cor_fortes, digits = 3,
        caption = "Pares de Variáveis com Alta Correlação") |>
    kable_styling(bootstrap_options = c("striped", "hover"))
} else {
  cat("Nenhuma correlação |r| > 0.7 detectada.\n")
}
```

**Conclusão:** `r ifelse(nrow(cor_fortes) > 0, "A presença de correlações fortes justifica o uso de técnicas de redução de dimensionalidade.", "Correlações moderadas sugerem estrutura multivariada.")`

## 3.3 Distribuições e Outliers

```{r boxplots, fig.cap="Boxplots - Identificação de Outliers"}
knitr::include_graphics("apresentacao_uriel/outputs/01_boxplots.pdf")
```

```{r outliers_count}
outliers <- read_csv("apresentacao_uriel/outputs/01_outliers_count.csv")

kable(outliers, caption = "Contagem de Outliers por Variável") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

**Decisão:** [Descrever decisão tomada no CHECKPOINT 1 sobre outliers]

---

# 4. Análise de Componentes Principais (PCA)

## 4.1 Decomposição de Variância

```{r pca_exec}
source("apresentacao_uriel/02_pca.R")
```

```{r pca_variancia}
pca_var <- read_csv("apresentacao_uriel/outputs/02_pca_variancia.csv")

kable(pca_var, digits = 2,
      caption = "Decomposição de Variância - PCA") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

## 4.2 Escolha de M Componentes

```{r scree_plot, fig.cap="Scree Plot - Método do Cotovelo"}
knitr::include_graphics("apresentacao_uriel/outputs/02_scree_plot.pdf")
```

```{r criterios_m}
criterios <- read_csv("apresentacao_uriel/outputs/02_criterios_m.csv")

kable(criterios, caption = "Critérios para Escolha de M") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

**Decisão:** [Preencher com decisão do CHECKPOINT 2]

**Justificativa:** [Explicar por que M foi escolhido, citando critérios]

**Variância Retida:** [X]%

## 4.3 Interpretação das Componentes

```{r loadings}
loadings <- read_csv("apresentacao_uriel/outputs/02_pca_loadings.csv")

# Mostrar apenas primeiras M componentes escolhidas
M <- 3  # Ajustar com decisão do CHECKPOINT 2
loadings_principais <- loadings |>
  select(variavel, 1:(M+1))

kable(loadings_principais, digits = 3,
      caption = paste("Loadings - Primeiras", M, "Componentes")) |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

**Interpretação:**

- **PC1** ([X]% variância): [Nome interpretativo]
  - Variáveis principais: [lista]
  - Interpretação: [descrição]

- **PC2** ([Y]% variância): [Nome interpretativo]
  - Variáveis principais: [lista]
  - Interpretação: [descrição]

[Continuar para demais componentes...]

## 4.4 Biplot

```{r biplot, fig.cap="Biplot PCA - PC1 vs PC2"}
knitr::include_graphics("apresentacao_uriel/outputs/02_biplot.pdf")
```

**Observações:** [Descrever outliers, grupos, padrões]

---

# 5. Análise Fatorial Exploratória (EFA)

## 5.1 Testes de Adequação

```{r efa_exec}
source("apresentacao_uriel/03_efa.R")
```

```{r adequacao}
adequacao <- read_csv("apresentacao_uriel/outputs/03_adequacao.csv")

kable(adequacao, digits = 3,
      caption = "Testes de Adequação - KMO e Bartlett") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

**Interpretação:**

- KMO: [valor] - [classificação]
- Bartlett: p < 0.05 - Adequado para EFA

## 5.2 Escolha de m Fatores

```{r parallel, fig.cap="Análise Paralela"}
knitr::include_graphics("apresentacao_uriel/outputs/03_parallel_analysis.pdf")
```

```{r comp_m}
comp_m <- read_csv("apresentacao_uriel/outputs/03_comparacao_m.csv")

kable(comp_m, digits = 2,
      caption = "Comparação de Modelos com Diferentes m") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

**Decisão:** [Preencher com decisão do CHECKPOINT 3]

**Justificativa:** [Citar análise paralela, variância explicada, interpretabilidade]

## 5.3 Cargas Fatoriais (Rotação Varimax)

```{r cargas}
cargas <- read_csv("apresentacao_uriel/outputs/03_cargas_varimax.csv")

kable(cargas, digits = 3,
      caption = "Cargas Fatoriais Rotacionadas (Varimax)") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

```{r loadings_diagram, fig.cap="Diagrama de Cargas Fatoriais"}
knitr::include_graphics("apresentacao_uriel/outputs/03_loadings_plot.pdf")
```

## 5.4 Comunalidades e Especificidades

```{r comunalidades}
comun <- read_csv("apresentacao_uriel/outputs/03_comunalidades.csv")

kable(comun, digits = 3,
      caption = "Comunalidades (h²) e Especificidades") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

**Análise:** [Comentar variáveis bem/mal explicadas]

## 5.5 Interpretação dos Fatores

**Fator 1:** [Nome]
- Cargas principais: [lista]
- Interpretação: [descrição]

**Fator 2:** [Nome]
- Cargas principais: [lista]
- Interpretação: [descrição]

[Continuar...]

## 5.6 Comparação PCA vs EFA

```{r comparacao}
comparacao <- data.frame(
  Método = c("PCA", "EFA"),
  Dimensões = c("[M]", "[m]"),
  Variância_Explicada = c("[X]%", "[Y]%"),
  Interpretação = c("[resumo PCA]", "[resumo EFA]")
)

kable(comparacao, caption = "Comparação PCA vs EFA") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

**Conclusão:** [Convergências, divergências, método preferido]

---

# 6. Clustering

## 6.1 Escolha de K

```{r clustering_exec}
source("apresentacao_uriel/04_clustering.R")
```

```{r elbow}
cotovelo <- read_csv("apresentacao_uriel/outputs/04_cotovelo.csv")
silhueta <- read_csv("apresentacao_uriel/outputs/04_silhueta.csv")
```

```{r elbow_plot, fig.cap="Método do Cotovelo"}
ggplot(cotovelo, aes(x = K, y = WSS)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  theme_minimal() +
  labs(title = "Método do Cotovelo",
       x = "K", y = "WSS")
```

```{r silhouette_plot, fig.cap="Coeficiente de Silhueta"}
ggplot(silhueta, aes(x = K, y = Silhueta_Media)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "Coeficiente de Silhueta",
       x = "K", y = "Silhueta Média")
```

**Decisão:** K = [?]

**Justificativa:** [Balance entre cotovelo, silhueta e interpretabilidade]

**Silhueta Média:** [valor] - [interpretação]

## 6.2 Caracterização dos Clusters

```{r centroides}
centroides <- read_csv("apresentacao_uriel/outputs/04_centroides_transposto.csv")

kable(centroides, digits = 2,
      caption = "Centróides dos Clusters") |>
  kable_styling(bootstrap_options = c("striped", "hover"),
                font_size = 10)
```

```{r boxplots_clusters, fig.cap="Distribuições por Cluster", fig.height=10}
knitr::include_graphics("apresentacao_uriel/outputs/04_boxplots_clusters.pdf")
```

**Perfis dos Clusters:**

- **Cluster 1:** [Nome/Descrição]
  - Características: [altos/baixos em quais variáveis]
  - Exemplos: [bancos]

- **Cluster 2:** [Nome/Descrição]
  - Características: [...]
  - Exemplos: [...]

[Continuar...]

## 6.3 Visualização no Espaço PCA

```{r biplot_clusters, fig.cap="Biplot PCA Colorido por Cluster"}
knitr::include_graphics("apresentacao_uriel/outputs/04_biplot_clusters.pdf")
```

**Observações:** [Separação dos clusters, sobreposições]

## 6.4 Validação

```{r silhouette_validation, fig.cap="Silhouette Plot - Validação dos Clusters"}
knitr::include_graphics("apresentacao_uriel/outputs/04_silhouette_plot.pdf")
```

**Análise:**
- Clusters bem definidos?
- Observações mal classificadas?
- Tamanhos equilibrados?

## 6.5 Comparação com Clustering Hierárquico

```{r dendrograma, fig.cap="Dendrograma - Clustering Hierárquico"}
knitr::include_graphics("apresentacao_uriel/outputs/04_dendrograma.pdf")
```

```{r comparacao_clustering}
comp_clust <- read.csv("apresentacao_uriel/outputs/04_comparacao_kmeans_hierarquico.csv",
                       row.names = 1)

kable(comp_clust, caption = "K-Means vs Hierárquico - Tabela de Contingência") |>
  kable_styling(bootstrap_options = c("striped", "hover"))
```

**Adjusted Rand Index:** [valor] - [interpretação]

---

# 7. Conclusões

## 7.1 Principais Achados

1. **Redundância:** [PCA/EFA reduziu X variáveis para M/m dimensões com Y% variância]
2. **Estrutura Latente:** [Descrição dos componentes/fatores principais]
3. **Tipologia:** [K clusters identificados com perfis distintos]

## 7.2 Aplicações Práticas

- [Aplicação 1]
- [Aplicação 2]
- [Aplicação 3]

## 7.3 Limitações

- [Limitação 1]
- [Limitação 2]

## 7.4 Trabalhos Futuros

- [Sugestão 1]
- [Sugestão 2]

---

# Referências

- [Material do curso]
- [Pacotes R utilizados]

---

# Apêndice

## Pacotes R Utilizados

```{r sessionInfo}
sessionInfo()
```
```

### Step 2: Knit (compilar) o relatório

Run: `Rscript -e "rmarkdown::render('apresentacao_uriel/relatorio_final.Rmd')"`

Expected: `apresentacao_uriel/relatorio_final.html` criado

### Step 3: Revisar e ajustar

1. Abrir HTML no navegador
2. Verificar se todos os gráficos carregaram
3. Preencher seções [marcadas entre colchetes]
4. Ajustar interpretações conforme CHECKPOINTs

### Step 4: Commit

```bash
git add apresentacao_uriel/relatorio_final.Rmd apresentacao_uriel/relatorio_final.html
git commit -m "docs: add comprehensive final report with PCA, EFA and clustering"
```

---

## Tarefa 7: Apresentação em Slides

**Files:**
- Create: `apresentacao_uriel/apresentacao.Rmd`

### Step 1: Criar slides

```rmarkdown
---
title: "Análise de Dados Bancários"
subtitle: "PCA, EFA e Clustering"
author: "[Seu Nome]"
date: "`r Sys.Date()`"
output:
  ioslides_presentation:
    widescreen: true
    smaller: false
    logo: NULL
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)
library(tidyverse)
library(knitr)
```

## Objetivos

- Analisar estrutura multivariada de dados bancários brasileiros
- Aplicar PCA e EFA para redução de dimensionalidade
- Identificar tipologias de bancos via clustering

**Métodos:** PCA | EFA | K-Means | Hierárquico

---

## Dados

- **Fonte:** Dados bancários brasileiros (03/2025)
- **Observações:** [N] bancos
- **Variáveis:** 8 selecionadas

```{r vars_table}
source("apresentacao_uriel/df_banco.R")

data.frame(
  Variável = c("Ativo Total", "Cart. Crédito", "Patrimônio", "Lucro",
               "Basileia", "Imobilização", "Agências", "Postos")
) |>
  kable()
```

---

## Análise Descritiva

```{r corrplot, fig.width=8, fig.height=6}
library(corrplot)
cor_mat <- cor(df_limpo)
corrplot(cor_mat, method = "color", type = "upper",
         tl.col = "black", addCoef.col = "black", number.cex = 0.7)
```

**Correlações fortes justificam redução dimensional**

---

## PCA - Decomposição de Variância

```{r pca_table}
source("apresentacao_uriel/02_pca.R")
pca_var <- read_csv("apresentacao_uriel/outputs/02_pca_variancia.csv")

pca_var |>
  head(4) |>
  kable(digits = 2)
```

**Decisão:** M = [?] componentes ([X]% variância)

---

## PCA - Scree Plot

```{r scree, out.width="80%"}
knitr::include_graphics("apresentacao_uriel/outputs/02_scree_plot.pdf")
```

---

## PCA - Interpretação

**PC1 ([X]%):** [Nome]
- [Descrição breve]

**PC2 ([Y]%):** [Nome]
- [Descrição breve]

---

## PCA - Biplot

```{r biplot, out.width="90%"}
knitr::include_graphics("apresentacao_uriel/outputs/02_biplot.pdf")
```

---

## EFA - Adequação

```{r adequacao}
adequacao <- read_csv("apresentacao_uriel/outputs/03_adequacao.csv")
kable(adequacao, digits = 3)
```

- KMO: [valor] - [classificação]
- Bartlett: p < 0.05 ✓

**Dados adequados para EFA**

---

## EFA - Número de Fatores

```{r parallel, out.width="80%"}
knitr::include_graphics("apresentacao_uriel/outputs/03_parallel_analysis.pdf")
```

**Decisão:** m = [?] fatores

---

## EFA - Cargas Fatoriais

```{r cargas}
cargas <- read_csv("apresentacao_uriel/outputs/03_cargas_varimax.csv")
kable(cargas, digits = 2)
```

---

## EFA - Interpretação

**Fator 1:** [Nome]
- [Descrição]

**Fator 2:** [Nome]
- [Descrição]

---

## Comparação PCA vs EFA

| | PCA | EFA |
|---|---|---|
| **Dimensões** | M = [?] | m = [?] |
| **Variância** | [X]% | [Y]% |
| **Interpretação** | [resumo] | [resumo] |

**Convergência:** [SIM/PARCIAL/NÃO]

---

## Clustering - Escolha de K

```{r elbow_silhouette, fig.width=12, fig.height=5}
cotovelo <- read_csv("apresentacao_uriel/outputs/04_cotovelo.csv")
silhueta <- read_csv("apresentacao_uriel/outputs/04_silhueta.csv")

library(gridExtra)

p1 <- ggplot(cotovelo, aes(x = K, y = WSS)) +
  geom_line(size = 1) + geom_point(size = 2) +
  theme_minimal() + labs(title = "Cotovelo")

p2 <- ggplot(silhueta, aes(x = K, y = Silhueta_Media)) +
  geom_line(size = 1) + geom_point(size = 2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
  theme_minimal() + labs(title = "Silhueta")

grid.arrange(p1, p2, ncol = 2)
```

**Decisão:** K = [?] (Silhueta = [valor])

---

## Clustering - Centróides

```{r centroides}
centroides <- read_csv("apresentacao_uriel/outputs/04_centroides_transposto.csv")
kable(centroides, digits = 1)
```

---

## Clustering - Perfis

**Cluster 1:** [Nome]
- [Características]
- Exemplos: [bancos]

**Cluster 2:** [Nome]
- [Características]
- Exemplos: [bancos]

[...]

---

## Clustering - Biplot

```{r biplot_clusters, out.width="90%"}
knitr::include_graphics("apresentacao_uriel/outputs/04_biplot_clusters.pdf")
```

---

## Conclusões

1. **Redundância Capturada**
   - PCA: [M] CPs → [X]% variância
   - EFA: [m] fatores → [Y]% variância

2. **Estrutura Latente**
   - [Principais dimensões identificadas]

3. **Tipologia**
   - [K] grupos distintos de bancos
   - [Breve caracterização]

---

## Aplicações

- Segmentação de mercado bancário
- Benchmarking por tipologia
- Monitoramento de indicadores latentes

---

## Obrigado!

**Perguntas?**
```

### Step 2: Knit slides

Run: `Rscript -e "rmarkdown::render('apresentacao_uriel/apresentacao.Rmd')"`

Expected: `apresentacao_uriel/apresentacao.html` criado

### Step 3: Revisar slides

1. Abrir HTML no navegador
2. Navegar pelos slides
3. Verificar visualizações
4. Ajustar conteúdo para ~10-15 slides
5. Garantir que mensagens-chave estão claras

### Step 4: Commit

```bash
git add apresentacao_uriel/apresentacao.Rmd apresentacao_uriel/apresentacao.html
git commit -m "docs: add presentation slides with key findings and visualizations"
```

---

## Tarefa 8: Atualizar README

**Files:**
- Modify: `README.md:1-70`

### Step 1: Adicionar seções ao README

```markdown
# Análise de Dados Bancários - Aprendizado Não Supervisionado

## Descrição

Este projeto realiza análise exploratória e aplicação de técnicas de aprendizado de máquina não supervisionado em dados bancários brasileiros, incluindo PCA, EFA e Clustering.

## Estrutura dos Dados

O dataset contém informações financeiras de instituições bancárias brasileiras (março/2025):

- **Ativo Total**, **Carteira de Crédito**, **Patrimônio Líquido**, **Lucro Líquido**
- **Índice de Basileia**, **Índice de Imobilização**
- **Número de Agências**, **Número de Postos de Atendimento**

**Total:** [N] bancos analisados

## Pré-requisitos

### Bibliotecas R

```r
install.packages(c(
  "tidyverse", "psych", "factoextra", "FactoMineR",
  "corrplot", "GPArotation", "cluster", "mclust",
  "knitr", "rmarkdown", "kableExtra"
))
```

## Estrutura do Projeto

```
apresentacao_uriel/
├── dados.csv                     # Dataset original
├── df_banco.R                    # Preparação e padronização
├── 01_analise_descritiva.R       # Estatísticas e visualizações
├── 02_pca.R                      # Análise de Componentes Principais
├── 03_efa.R                      # Análise Fatorial Exploratória
├── 04_clustering.R               # K-Means e Hierárquico
├── relatorio_final.Rmd           # Relatório completo
├── apresentacao.Rmd              # Slides de apresentação
└── outputs/                      # Tabelas e gráficos gerados
    ├── 01_*.{csv,pdf}
    ├── 02_*.{csv,pdf}
    ├── 03_*.{csv,pdf}
    ├── 04_*.{csv,pdf}
    └── CHECKPOINT_*.md
```

## Como Executar

### 1. Análises Individuais

Execute os scripts na ordem:

```r
# 1. Preparação dos dados (obrigatório primeiro)
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

**Importante:** Revisar CHECKPOINTs em `outputs/CHECKPOINT_*.md` após cada fase.

### 2. Gerar Relatório e Apresentação

```r
# Relatório completo (HTML)
rmarkdown::render("apresentacao_uriel/relatorio_final.Rmd")

# Slides (HTML)
rmarkdown::render("apresentacao_uriel/apresentacao.Rmd")
```

## Resultados Principais

### PCA
- **M = [?]** componentes principais retidas
- **Variância explicada:** [X]%
- **Interpretação:** [breve descrição dos componentes]

### EFA
- **m = [?]** fatores latentes identificados
- **KMO:** [valor] ([classificação])
- **Interpretação:** [breve descrição dos fatores]

### Clustering
- **K = [?]** clusters identificados
- **Silhueta média:** [valor]
- **Tipologias:** [breve descrição dos perfis]

## Arquivos de Saída

Todos os outputs são salvos em `apresentacao_uriel/outputs/`:

- **Análise Descritiva:** Estatísticas, correlações, gráficos de distribuição
- **PCA:** Autovalores, loadings, scree plot, biplot, escores
- **EFA:** KMO/Bartlett, cargas fatoriais, comunalidades, escores
- **Clustering:** Centróides, silhueta, biplot colorido, dendrograma

## Decisões de Hiperparâmetros

Documentadas em `outputs/CHECKPOINT_*.md`:
- **M** (componentes PCA): [justificativa]
- **m** (fatores EFA): [justificativa]
- **K** (clusters): [justificativa]

## Referências

- [Material do curso de Aprendizado Não Supervisionado]
- Pacotes R: psych, factoextra, FactoMineR, corrplot

## Autores

[Seu Nome]

## Licença

[Se aplicável]
```

### Step 2: Commit README atualizado

```bash
git add README.md
git commit -m "docs: update README with complete project structure and execution instructions"
```

---

## ✅ CHECKLIST FINAL

### Step 1: Verificar execução dos scripts

```bash
cd apresentacao_uriel
Rscript df_banco.R
Rscript 01_analise_descritiva.R
Rscript 02_pca.R
Rscript 03_efa.R
Rscript 04_clustering.R
```

Expected: Todos executam sem erros

### Step 2: Verificar outputs

Run: `ls -la apresentacao_uriel/outputs/`

Expected: ~25-30 arquivos (CSV e PDF)

### Step 3: Compilar documentos

```bash
Rscript -e "rmarkdown::render('apresentacao_uriel/relatorio_final.Rmd')"
Rscript -e "rmarkdown::render('apresentacao_uriel/apresentacao.Rmd')"
```

Expected: 2 arquivos HTML criados

### Step 4: Revisar CHECKPOINTs

Verificar que existem 4 arquivos:
- `outputs/CHECKPOINT_1_decisoes.md`
- `outputs/CHECKPOINT_2_decisoes.md`
- `outputs/CHECKPOINT_3_decisoes.md`
- `outputs/CHECKPOINT_4_decisoes.md`

### Step 5: Commit final

```bash
git add -A
git commit -m "chore: final project completion with all analyses and documentation"
git log --oneline
```

Expected: ~15-20 commits bem documentados

---

## 📊 RESUMO DO PLANO

**Total de Tarefas:** 8 principais + 4 checkpoints
**Entregas:**
- 4 scripts R de análise
- 2 documentos R Markdown (relatório + slides)
- ~30 outputs (CSV + PDF)
- 4 documentos de checkpoint
- README atualizado

**Tempo Estimado:** 1-3 dias (conforme especificado)

---

## Execution Handoff

Plan complete and saved to `docs/plans/2025-11-15-analise-bancaria-unsupervised-ml.md`.

**Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration with checkpoints

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with review points

**Which approach?**