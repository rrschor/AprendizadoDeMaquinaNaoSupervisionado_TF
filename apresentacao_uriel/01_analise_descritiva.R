# ==============================================================================
# ANÁLISE DESCRITIVA - DADOS BANCÁRIOS
# ==============================================================================
# Objetivo: Estatísticas sumárias, visualizações, matrizes de variabilidade
# Dependência: Executar df_banco.R primeiro
# Outputs: Tabelas e gráficos em outputs/
# ==============================================================================

library(tidyverse)
library(corrplot)

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
