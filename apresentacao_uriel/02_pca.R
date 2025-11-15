# ==============================================================================
# PCA - ANÁLISE DE COMPONENTES PRINCIPAIS
# ==============================================================================
# Fonte: IF.data (BCB) - Março/2025 - 1,055 bancos brasileiros
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
p <- fviz_eig(pca_result, addlabels = TRUE, ylim = c(0, 70),
         main = "Scree Plot - Escolha de Componentes (Regra do Cotovelo)")
p <- p + geom_hline(yintercept = 12.5, linetype = "dashed", color = "red", linewidth = 0.8) +
     annotate("text", x = 7, y = 14, label = "Kaiser (λ=1 → 12.5% para p=8)",
              color = "red", size = 3)
print(p)
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