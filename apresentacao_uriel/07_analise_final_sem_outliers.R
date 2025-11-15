# ==============================================================================
# ANÁLISE FINAL - SEM OUTLIERS EXTREMOS
# ==============================================================================
# Objetivo: Descobrir estrutura real dos bancos pequenos/médios
# Removidos: Big 5 + BNDES + BTG + 2 outliers regulatórios = 9 bancos
# Restantes: 1,046 bancos "normais"
# Outputs: outputs/07_*.{csv,pdf}
# ==============================================================================

library(tidyverse)
library(psych)
library(GPArotation)
library(factoextra)
library(FactoMineR)
library(cluster)
library(corrplot)

# Carregar dados originais
source("apresentacao_uriel/df_banco.R")

cat("\n╔══════════════════════════════════════════════════════════╗\n")
cat("║   ANÁLISE FINAL - ESTRUTURA DOS BANCOS PEQUENOS/MÉDIOS  ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n")

# --- 1. REMOVER TODOS OS OUTLIERS ---

# Big 5 comerciais
big5 <- c("BB - PRUDENCIAL", "BRADESCO - PRUDENCIAL",
          "CAIXA ECONÔMICA FEDERAL - PRUDENCIAL",
          "ITAU - PRUDENCIAL", "SANTANDER - PRUDENCIAL")

# Grandes bancos especializados (identificados em análise anterior)
grandes_especializados <- c("BNDES - PRUDENCIAL", "BTG PACTUAL - PRUDENCIAL")

# Outliers regulatórios (Basileia > 1000%)
outliers_regulatorios <- c("RV2 SEP - PRUDENCIAL", "VUON SCD - PRUDENCIAL")

# Combinar todos
outliers_totais <- c(big5, grandes_especializados, outliers_regulatorios)

cat("\n=== OUTLIERS REMOVIDOS (N=9) ===\n")
cat("\nBig 5 Comerciais:\n")
for(b in big5) cat(" -", b, "\n")
cat("\nGrandes Especializados:\n")
for(b in grandes_especializados) cat(" -", b, "\n")
cat("\nOutliers Regulatórios:\n")
for(b in outliers_regulatorios) cat(" -", b, "\n")

# Remover
indices_outliers <- which(bancos %in% outliers_totais)
df_final <- df_limpo[-indices_outliers, ]
bancos_final <- bancos[-indices_outliers]

cat("\n=== DATASET FINAL ===\n")
cat("N original:", nrow(df_limpo), "\n")
cat("N final:", nrow(df_final), "\n")
cat("Removidos:", length(indices_outliers), "outliers extremos\n")
cat("Percentual analisado:", round(nrow(df_final)/nrow(df_limpo)*100, 1), "%\n")

# RE-PADRONIZAR
df_final_padro <- scale(df_final)

# --- 2. ANÁLISE DESCRITIVA FINAL ---

cor_mat_final <- cor(df_final)
kmo_final <- KMO(df_final_padro)
bartlett_final <- cortest.bartlett(df_final_padro)

cat("\n=== ADEQUAÇÃO (Dataset Final) ===\n")
cat("KMO:", round(kmo_final$MSA, 3), "\n")
cat("Bartlett p:", format(bartlett_final$p.value, scientific = TRUE), "\n")

# Correlações fortes
cor_fortes_final <- cor_mat_final |>
  as.data.frame() |>
  rownames_to_column("var1") |>
  pivot_longer(-var1, names_to = "var2", values_to = "r") |>
  filter(var1 < var2, abs(r) > 0.7) |>
  arrange(desc(abs(r)))

cat("Correlações |r| > 0.7:", nrow(cor_fortes_final), "pares\n")

# --- 3. PCA FINAL ---

cat("\n=== PCA (Dataset Final) ===\n")

pca_final <- prcomp(df_final_padro, scale. = FALSE)
eigenvalues_final <- pca_final$sdev^2

pca_var_final <- data.frame(
  PC = paste0("PC", 1:length(eigenvalues_final)),
  Autovalor = eigenvalues_final,
  Var_Pct = eigenvalues_final / sum(eigenvalues_final) * 100,
  Var_Acum = cumsum(eigenvalues_final / sum(eigenvalues_final) * 100)
)

cat("\nDecomposição de variância:\n")
print(pca_var_final[1:5, ])

write_csv(pca_var_final, "apresentacao_uriel/outputs/07_pca_variancia.csv")

# Critérios
m_kaiser_final <- sum(eigenvalues_final >= 1)
m_75_final <- which(pca_var_final$Var_Acum >= 75)[1]
m_80_final <- which(pca_var_final$Var_Acum >= 80)[1]

cat("\nCritérios:\n")
cat("  Kaiser:", m_kaiser_final, "| 75%:", m_75_final, "| 80%:", m_80_final, "\n")

M_final <- max(m_kaiser_final, m_75_final)
cat("\nM escolhido:", M_final, "componentes (", round(pca_var_final$Var_Acum[M_final], 1), "% var.)\n")

# Scree plot
pdf("apresentacao_uriel/outputs/07_scree_plot.pdf", width = 10, height = 6)
fviz_eig(pca_final, addlabels = TRUE,
         main = sprintf("Scree Plot - Sem Outliers (N=%d)", nrow(df_final)))
dev.off()

# Loadings
loadings_final <- pca_final$rotation
cat("\nLoadings (PC1-PC3):\n")
print(round(loadings_final[, 1:3], 3))

write_csv(as.data.frame(loadings_final) |> rownames_to_column("var"),
          "apresentacao_uriel/outputs/07_pca_loadings.csv")

# Escores
scores_pca_final <- pca_final$x[, 1:M_final]

# --- 4. EFA FINAL ---

cat("\n=== EFA (Dataset Final) ===\n")

parallel_final <- fa.parallel(df_final_padro, fa = "fa", n.iter = 100,
                               main = "Análise Paralela - Dataset Final")
m_efa_final <- parallel_final$nfact
cat("Análise paralela sugere:", m_efa_final, "fatores\n")

pdf("apresentacao_uriel/outputs/07_efa_parallel.pdf", width = 10, height = 6)
fa.parallel(df_final_padro, fa = "fa", n.iter = 100,
            main = sprintf("Análise Paralela (N=%d)", nrow(df_final)))
dev.off()

# Estimar EFA
efa_final <- fa(df_final_padro, nfactors = m_efa_final,
                rotate = "varimax", fm = "ml", scores = "regression")

cat("\nCargas fatoriais:\n")
print(round(efa_final$loadings, 3))

write_csv(data.frame(
  variavel = rownames(efa_final$loadings),
  efa_final$loadings[1:nrow(efa_final$loadings), 1:m_efa_final]
), "apresentacao_uriel/outputs/07_efa_loadings.csv")

# --- 5. CLUSTERING FINAL ---

cat("\n=== CLUSTERING FINAL (sem outliers) ===\n")

set.seed(123)

# Testar K=2 a 8
wss_final <- numeric(10)
sil_final <- numeric(9)

for(k in 1:10) {
  km <- kmeans(scores_pca_final, centers = k, nstart = 25)
  wss_final[k] <- km$tot.withinss

  if(k >= 2) {
    sil <- silhouette(km$cluster, dist(scores_pca_final))
    sil_final[k-1] <- mean(sil[, 3])
  }
}

silhueta_final_df <- data.frame(K = 2:10, Silhueta = sil_final)

cat("\nSilhuetas:\n")
print(silhueta_final_df[1:7, ])

write_csv(silhueta_final_df, "apresentacao_uriel/outputs/07_silhueta.csv")

# Plotar critérios
pdf("apresentacao_uriel/outputs/07_criterios_K.pdf", width = 14, height = 6)
par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))

# Cotovelo
plot(1:10, wss_final, type = "b", pch = 19, cex = 1.5, lwd = 2,
     col = "steelblue", main = "Método do Cotovelo",
     xlab = "K (número de clusters)", ylab = "WSS")
grid()

# Silhueta
plot(2:10, sil_final, type = "b", pch = 19, cex = 1.5, lwd = 2,
     col = "firebrick", main = "Coeficiente de Silhueta",
     xlab = "K (número de clusters)", ylab = "Silhueta Média")
abline(h = 0.5, lty = 2, col = "gray50", lwd = 1.5)
abline(h = 0.7, lty = 2, col = "gray30", lwd = 1.5)
grid()

dev.off()

# --- 6. GERAR SOLUÇÕES PARA K=3,4,5 ---

cat("\n=== SOLUÇÕES CANDIDATAS ===\n")

for(K in 3:5) {
  cat("\n--- K =", K, "---\n")

  set.seed(123)
  km <- kmeans(scores_pca_final, centers = K, nstart = 25)
  sil <- silhouette(km$cluster, dist(scores_pca_final))

  # Tamanhos
  tab <- table(km$cluster)
  cat("Tamanhos:", paste(tab, collapse = ", "), "\n")
  cat("Silhueta:", round(mean(sil[, 3]), 3), "\n")

  # Centróides
  cent <- aggregate(df_final, by = list(Cluster = km$cluster), mean)
  write_csv(cent, sprintf("apresentacao_uriel/outputs/07_centroides_K%d.csv", K))

  # Bancos
  bc <- data.frame(Banco = bancos_final, Cluster = km$cluster) |> arrange(Cluster, Banco)
  write_csv(bc, sprintf("apresentacao_uriel/outputs/07_bancos_K%d.csv", K))

  # Plot
  pdf(sprintf("apresentacao_uriel/outputs/07_kmeans_K%d.pdf", K), width = 12, height = 10)

  plot_df <- as.data.frame(scores_pca_final) |>
    mutate(Cluster = factor(km$cluster))
  colnames(plot_df)[1:M_final] <- paste0("PC", 1:M_final)

  cent_pca <- aggregate(scores_pca_final, by = list(km$cluster), mean)

  p <- ggplot(plot_df, aes(x = PC1, y = PC2, color = Cluster, shape = Cluster)) +
    geom_point(size = 2.5, alpha = 0.65) +
    geom_point(data = data.frame(
      PC1 = cent_pca$PC1,
      PC2 = cent_pca$PC2,
      Cluster = factor(cent_pca$Group.1)
    ),
    size = 9, shape = 4, stroke = 2.5, color = "black") +
    scale_color_brewer(palette = "Set1") +
    scale_shape_manual(values = c(16, 17, 15, 18, 8)) +
    theme_minimal(base_size = 13) +
    labs(title = sprintf("K=%d Clusters - Bancos sem Outliers", K),
         subtitle = sprintf("Silhueta = %.3f | N = %d", mean(sil[, 3]), nrow(df_final)),
         x = sprintf("PC1 (%.1f%%)", pca_var_final$Var_Pct[1]),
         y = sprintf("PC2 (%.1f%%)", pca_var_final$Var_Pct[2]))

  print(p)
  dev.off()
}

# --- 7. ESCOLHER MELHOR K E CARACTERIZAR ---

# Baseado em silhueta e interpretabilidade
K_best <- 3  # ou 4, conforme análise

cat("\n╔══════════════════════════════════════════════════════════╗\n")
cat("║   SOLUÇÃO FINAL: K =", K_best, "CLUSTERS (sem outliers)        ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n")

set.seed(123)
kmeans_best <- kmeans(scores_pca_final, centers = K_best, nstart = 25)
sil_best <- silhouette(kmeans_best$cluster, dist(scores_pca_final))

cat("\nSilhueta média:", round(mean(sil_best[, 3]), 3), "\n")

# Centróides detalhados
centroides_best <- aggregate(df_final, by = list(Cluster = kmeans_best$cluster), mean)

cat("\n=== CARACTERIZAÇÃO DETALHADA DOS", K_best, "CLUSTERS ===\n")

for(k in 1:K_best) {
  cat("\n┌──────────────────────────────────────────────────┐\n")
  cat("│ CLUSTER", k, "                                      │\n")
  cat("├──────────────────────────────────────────────────┤\n")

  # Tamanho
  n_k <- sum(kmeans_best$cluster == k)
  pct_k <- round(n_k / nrow(df_final) * 100, 1)
  cat("│ N =", n_k, "bancos (", pct_k, "%)                    │\n")
  cat("│                                                  │\n")

  # Centróide
  c <- centroides_best[k, -1]  # Remove coluna Cluster

  cat("│ PERFIL FINANCEIRO:                               │\n")
  cat("│  Ativo Total: R$", sprintf("%8.1f", c$ativo_total/1e6), "milhões          │\n")
  cat("│  Carteira Crédito: R$", sprintf("%5.1f", c$carteira_de_credito/1e6), "milhões     │\n")
  cat("│  Patrimônio: R$", sprintf("%8.0f", c$patrimonio_liquido/1e3), "mil                │\n")
  cat("│  Lucro: R$", sprintf("%12.0f", c$lucro_liquido/1e3), "mil                     │\n")
  cat("│                                                  │\n")
  cat("│ PERFIL REGULATÓRIO:                              │\n")
  cat("│  Índice Basileia:", sprintf("%6.1f", c$indice_de_basileia*100), "%                    │\n")
  cat("│  Índice Imobilização:", sprintf("%4.1f", c$indice_de_imobilizacao*100), "%                │\n")
  cat("│                                                  │\n")
  cat("│ INFRAESTRUTURA:                                  │\n")
  cat("│  Agências:", sprintf("%6.1f", c$numero_de_agencias), "                              │\n")
  cat("│  Postos:", sprintf("%8.1f", c$numero_de_postos_de_atendimento), "                            │\n")
  cat("│                                                  │\n")

  # Exemplos
  bancos_k <- bancos_final[kmeans_best$cluster == k]
  exemplos <- head(sort(bancos_k), 10)

  cat("│ EXEMPLOS (primeiros 10 alfabeticamente):        │\n")
  for(i in 1:min(10, length(exemplos))) {
    nome <- gsub(" - PRUDENCIAL", "", exemplos[i])
    if(nchar(nome) > 43) nome <- paste0(substr(nome, 1, 40), "...")
    cat("│ ", sprintf("%2d", i), ".", nome, "\n")
  }

  cat("└──────────────────────────────────────────────────┘\n")
}

# Salvar caracterização
write_csv(centroides_best, "apresentacao_uriel/outputs/07_centroides_final.csv")

bancos_cluster_final <- data.frame(
  Banco = bancos_final,
  Cluster = kmeans_best$cluster
) |> arrange(Cluster, Banco)

write_csv(bancos_cluster_final, "apresentacao_uriel/outputs/07_bancos_cluster_final.csv")

# --- 8. VISUALIZAÇÃO FINAL COM NOMES DESTAQUE ---

pdf("apresentacao_uriel/outputs/07_clustering_final.pdf", width = 14, height = 11)

plot_final <- as.data.frame(scores_pca_final) |>
  mutate(Cluster = factor(kmeans_best$cluster),
         Banco = bancos_final)
colnames(plot_final)[1:M_final] <- paste0("PC", 1:M_final)

cent_final_pca <- aggregate(scores_pca_final, by = list(kmeans_best$cluster), mean)

# Bancos para destacar (maiores de cada cluster)
destaques <- plot_final |>
  group_by(Cluster) |>
  arrange(desc(abs(PC1))) |>
  slice_head(n = 3) |>
  ungroup()

p_final <- ggplot(plot_final, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point(size = 2.5, alpha = 0.6) +

  # Centróides
  geom_point(data = data.frame(
    PC1 = cent_final_pca$PC1,
    PC2 = cent_final_pca$PC2,
    Cluster = factor(cent_final_pca$Group.1)
  ),
  size = 10, shape = 4, stroke = 3, color = "black", show.legend = FALSE) +

  # Labels para bancos destaque
  geom_text(data = destaques,
            aes(label = gsub(" - PRUDENCIAL", "", Banco)),
            size = 3, vjust = -0.7, hjust = 0.5, fontface = "bold",
            show.legend = FALSE) +

  scale_color_manual(
    values = c("1" = "#E41A1C", "2" = "#377EB8", "3" = "#4DAF4A"),
    labels = c(
      sprintf("1: Pequenos (N=%d)", sum(kmeans_best$cluster == 1)),
      sprintf("2: Médios (N=%d)", sum(kmeans_best$cluster == 2)),
      sprintf("3: Outliers (N=%d)", sum(kmeans_best$cluster == 3))
    )
  ) +

  theme_minimal(base_size = 14) +
  theme(
    legend.position = c(0.15, 0.85),
    legend.background = element_rect(fill = "white", color = "gray70", linewidth = 0.5),
    legend.title = element_text(face = "bold", size = 13),
    legend.text = element_text(size = 11),
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5)
  ) +

  labs(
    title = sprintf("Estrutura do Setor Bancário Brasileiro (K=%d)", K_best),
    subtitle = sprintf("Sem Big 7 e outliers | Silhueta = %.3f | N = %d bancos",
                       mean(sil_best[, 3]), nrow(df_final)),
    x = sprintf("PC1 - Tamanho (%.1f%% variância)", pca_var_final$Var_Pct[1]),
    y = sprintf("PC2 - Solidez (%.1f%% variância)", pca_var_final$Var_Pct[2]),
    color = "Cluster"
  ) +

  annotate("text", x = min(plot_final$PC1) + 0.5,
           y = max(plot_final$PC2) - 0.5,
           label = "X = Centróide", size = 4.5, hjust = 0, fontface = "bold")

print(p_final)
dev.off()

# --- 9. CLUSTERING HIERÁRQUICO ---

cat("\n=== HIERÁRQUICO (Ward) ===\n")

dist_final <- dist(scores_pca_final)
hclust_final <- hclust(dist_final, method = "ward.D2")

pdf("apresentacao_uriel/outputs/07_dendrograma.pdf", width = 14, height = 8)
plot(hclust_final, labels = FALSE,
     main = sprintf("Dendrograma - Dataset Final (N=%d)", nrow(df_final)),
     xlab = "", sub = "")
rect.hclust(hclust_final, k = K_best, border = "red")
dev.off()

# --- 10. RESUMO COMPARATIVO ---

cat("\n╔══════════════════════════════════════════════════════════╗\n")
cat("║                  RESUMO COMPARATIVO                      ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n")

resumo <- data.frame(
  Analise = c("Com Big 7 (N=1,055)", "Sem Big 7 (N=1,048)", "Dataset Final (N=1,046)"),
  M_PCA = c(2, 3, M_final),
  Var_PCA = c(80.0, 84.4, round(pca_var_final$Var_Acum[M_final], 1)),
  m_EFA = c(2, 3, m_efa_final),
  K_clusters = c(2, 3, K_best),
  Silhueta = c(0.972, 0.889, round(mean(sil_best[, 3]), 3))
)

cat("\n")
print(resumo)

write_csv(resumo, "apresentacao_uriel/outputs/07_resumo_comparativo.csv")

cat("\n╔══════════════════════════════════════════════════════════╗\n")
cat("║              ANÁLISE FINAL CONCLUÍDA!                    ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n")
cat("\nOutputs em: apresentacao_uriel/outputs/07_*\n")
cat("\nPróximo passo: Documentar CHECKPOINT 7 com interpretação dos clusters\n")
