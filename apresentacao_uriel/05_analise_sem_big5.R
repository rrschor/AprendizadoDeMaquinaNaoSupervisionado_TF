# ==============================================================================
# ANÁLISE COMPLETA SEM OS BIG 5
# ==============================================================================
# Objetivo: Refazer PCA, EFA e Clustering excluindo os 5 maiores bancos
# Justificativa: Big 5 são outliers extremos que podem mascarar subgrupos
# Dependência: Executar df_banco.R primeiro
# Outputs: Novos resultados em outputs/05_*.{csv,pdf}
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

cat("\n=== ANÁLISE SEM OS BIG 5 ===\n")

# --- 1. IDENTIFICAR E REMOVER BIG 5 ---

# Big 5 identificados pelo clustering anterior
big5_nomes <- c(
  "BB - PRUDENCIAL",
  "BRADESCO - PRUDENCIAL",
  "CAIXA ECONÔMICA FEDERAL - PRUDENCIAL",
  "ITAU - PRUDENCIAL",
  "SANTANDER - PRUDENCIAL"
)

cat("\n=== REMOVENDO BIG 5 ===\n")
cat("Bancos removidos:\n")
print(big5_nomes)

# Encontrar índices dos Big 5
indices_big5 <- which(bancos %in% big5_nomes)
cat("\nÍndices:", indices_big5, "\n")

# Criar datasets sem Big 5
df_limpo_sem_big5 <- df_limpo[-indices_big5, ]
bancos_sem_big5 <- bancos[-indices_big5]

cat("\n=== NOVO DATASET ===\n")
cat("N original:", nrow(df_limpo), "bancos\n")
cat("N sem Big 5:", nrow(df_limpo_sem_big5), "bancos\n")
cat("Removidos:", length(indices_big5), "bancos\n")

# IMPORTANTE: RE-PADRONIZAR os dados (Z-scores mudam sem outliers!)
df_limpo_sem_big5_padro <- scale(df_limpo_sem_big5)

cat("\n=== RE-PADRONIZAÇÃO ===\n")
cat("Médias (devem ser ~0):\n")
print(round(colMeans(df_limpo_sem_big5_padro), 10))
cat("\nDesvios padrão (devem ser 1):\n")
print(round(apply(df_limpo_sem_big5_padro, 2, sd), 10))

# --- 2. ANÁLISE DESCRITIVA (RÁPIDA) ---

cor_mat_sem_big5 <- cor(df_limpo_sem_big5)

cat("\n=== MATRIZ DE CORRELAÇÕES (sem Big 5) ===\n")
write_csv(as.data.frame(cor_mat_sem_big5) |> rownames_to_column("variavel"),
          "apresentacao_uriel/outputs/05_correlacoes.csv")

# Testes de adequação
kmo_sem_big5 <- KMO(df_limpo_sem_big5_padro)
bartlett_sem_big5 <- cortest.bartlett(df_limpo_sem_big5_padro)

cat("\n=== ADEQUAÇÃO (sem Big 5) ===\n")
cat("KMO:", round(kmo_sem_big5$MSA, 3), "\n")
cat("Bartlett p-value:", format(bartlett_sem_big5$p.value, scientific = TRUE), "\n")

# --- 3. PCA SEM BIG 5 ---

cat("\n=== PCA SEM BIG 5 ===\n")

pca_sem_big5 <- prcomp(df_limpo_sem_big5_padro, scale. = FALSE)

# Autovalores
eigenvalues_sem_big5 <- pca_sem_big5$sdev^2

# Tabela de variância
pca_summary_sem_big5 <- data.frame(
  Componente = paste0("PC", 1:length(eigenvalues_sem_big5)),
  Autovalor = eigenvalues_sem_big5,
  Variancia_Explicada = eigenvalues_sem_big5 / sum(eigenvalues_sem_big5) * 100,
  Variancia_Acumulada = cumsum(eigenvalues_sem_big5 / sum(eigenvalues_sem_big5) * 100)
)

cat("\n=== DECOMPOSIÇÃO DE VARIÂNCIA (sem Big 5) ===\n")
print(pca_summary_sem_big5)

write_csv(pca_summary_sem_big5, "apresentacao_uriel/outputs/05_pca_variancia.csv")

# Critérios
m_kaiser_sem_big5 <- sum(eigenvalues_sem_big5 >= 1)
m_75_sem_big5 <- which(pca_summary_sem_big5$Variancia_Acumulada >= 75)[1]
m_80_sem_big5 <- which(pca_summary_sem_big5$Variancia_Acumulada >= 80)[1]

cat("\n=== CRITÉRIOS PARA M (sem Big 5) ===\n")
cat("Kaiser (λ≥1):", m_kaiser_sem_big5, "\n")
cat("Cut-off 75%:", m_75_sem_big5, "\n")
cat("Cut-off 80%:", m_80_sem_big5, "\n")

criterios_sem_big5 <- data.frame(
  Criterio = c("Kaiser (λ≥1)", "Cut-off 75%", "Cut-off 80%"),
  M_componentes = c(m_kaiser_sem_big5, m_75_sem_big5, m_80_sem_big5)
)
write_csv(criterios_sem_big5, "apresentacao_uriel/outputs/05_pca_criterios.csv")

# Scree plot
pdf("apresentacao_uriel/outputs/05_scree_plot.pdf", width = 10, height = 6)
fviz_eig(pca_sem_big5, addlabels = TRUE, ylim = c(0, 50),
         main = "Scree Plot - PCA sem Big 5")
dev.off()

# Loadings
loadings_sem_big5 <- pca_sem_big5$rotation
write_csv(as.data.frame(loadings_sem_big5) |> rownames_to_column("variavel"),
          "apresentacao_uriel/outputs/05_pca_loadings.csv")

cat("\n=== LOADINGS (sem Big 5) - Primeiras 3 CPs ===\n")
print(round(loadings_sem_big5[, 1:3], 3))

# Biplot
pdf("apresentacao_uriel/outputs/05_pca_biplot.pdf", width = 12, height = 10)
fviz_pca_biplot(pca_sem_big5,
                repel = TRUE,
                col.var = "contrib",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                col.ind = "gray",
                title = "Biplot PCA - Sem Big 5")
dev.off()

# Escores
M_sem_big5 <- max(m_kaiser_sem_big5, m_75_sem_big5)
scores_pca_sem_big5 <- pca_sem_big5$x[, 1:M_sem_big5]
write_csv(as.data.frame(scores_pca_sem_big5) |>
            mutate(banco = bancos_sem_big5),
          "apresentacao_uriel/outputs/05_pca_scores.csv")

cat("\nM escolhido (sem Big 5):", M_sem_big5, "\n")
cat("Variância retida:", round(pca_summary_sem_big5$Variancia_Acumulada[M_sem_big5], 2), "%\n")

# --- 4. EFA SEM BIG 5 ---

cat("\n=== EFA SEM BIG 5 ===\n")

# Análise paralela
parallel_sem_big5 <- fa.parallel(df_limpo_sem_big5_padro, fa = "fa", n.iter = 100,
                                  main = "Análise Paralela - Sem Big 5")
m_parallel_sem_big5 <- parallel_sem_big5$nfact

cat("Análise paralela sugere:", m_parallel_sem_big5, "fatores\n")

# Salvar gráfico
pdf("apresentacao_uriel/outputs/05_efa_parallel.pdf", width = 10, height = 6)
fa.parallel(df_limpo_sem_big5_padro, fa = "fa", n.iter = 100,
            main = "Análise Paralela - Sem Big 5")
dev.off()

# Testar diferentes valores de m
m_max_sem_big5 <- min(5, m_parallel_sem_big5 + 1)

efa_tests_sem_big5 <- list()
for(m in 1:m_max_sem_big5) {
  cat("Testando m =", m, "fatores...\n")
  efa_ml <- fa(df_limpo_sem_big5_padro, nfactors = m, rotate = "none", fm = "ml")

  efa_tests_sem_big5[[m]] <- list(
    m = m,
    var_explicada = sum(efa_ml$communality) / ncol(df_limpo_sem_big5_padro) * 100,
    RMSEA = efa_ml$RMSEA[1],
    TLI = efa_ml$TLI
  )
}

# Tabela comparativa
comp_m_sem_big5 <- data.frame(
  m_fatores = sapply(efa_tests_sem_big5, function(x) x$m),
  var_explicada_pct = sapply(efa_tests_sem_big5, function(x) round(x$var_explicada, 2)),
  RMSEA = sapply(efa_tests_sem_big5, function(x) round(x$RMSEA, 3)),
  TLI = sapply(efa_tests_sem_big5, function(x) round(x$TLI, 3))
)

cat("\n=== COMPARAÇÃO DE MODELOS EFA (sem Big 5) ===\n")
print(comp_m_sem_big5)

write_csv(comp_m_sem_big5, "apresentacao_uriel/outputs/05_efa_comparacao_m.csv")

# Estimar modelo com m escolhido
m_escolhido_sem_big5 <- m_parallel_sem_big5

efa_varimax_sem_big5 <- fa(df_limpo_sem_big5_padro, nfactors = m_escolhido_sem_big5,
                            rotate = "varimax", fm = "ml", scores = "regression")

cat("\n=== CARGAS FATORIAIS (Varimax, sem Big 5) ===\n")
print(round(efa_varimax_sem_big5$loadings, 3))

# Salvar cargas
loadings_efa_sem_big5 <- data.frame(
  variavel = rownames(efa_varimax_sem_big5$loadings),
  efa_varimax_sem_big5$loadings[1:nrow(efa_varimax_sem_big5$loadings), 1:m_escolhido_sem_big5]
)
write_csv(loadings_efa_sem_big5, "apresentacao_uriel/outputs/05_efa_loadings.csv")

# Comunalidades
comunalidades_sem_big5 <- data.frame(
  variavel = colnames(df_limpo_sem_big5_padro),
  comunalidade = efa_varimax_sem_big5$communality,
  especificidade = 1 - efa_varimax_sem_big5$communality
)
write_csv(comunalidades_sem_big5, "apresentacao_uriel/outputs/05_efa_comunalidades.csv")

cat("\n=== COMUNALIDADES (sem Big 5) ===\n")
print(comunalidades_sem_big5)

# Diagrama de cargas
pdf("apresentacao_uriel/outputs/05_efa_diagram.pdf", width = 10, height = 8)
fa.diagram(efa_varimax_sem_big5, main = "Cargas Fatoriais - Sem Big 5")
dev.off()

# --- 5. CLUSTERING SEM BIG 5 ---

cat("\n=== CLUSTERING SEM BIG 5 ===\n")

# Usar escores PCA para clustering
dados_clustering_sem_big5 <- pca_sem_big5$x[, 1:M_sem_big5]

cat("Dimensões para clustering:", nrow(dados_clustering_sem_big5), "obs x",
    ncol(dados_clustering_sem_big5), "componentes\n")

# --- 5a. MÉTODO DO COTOVELO ---

set.seed(123)

wss_sem_big5 <- numeric(10)
for(k in 1:10) {
  kmeans_temp <- kmeans(dados_clustering_sem_big5, centers = k, nstart = 25)
  wss_sem_big5[k] <- kmeans_temp$tot.withinss
}

cotovelo_sem_big5 <- data.frame(K = 1:10, WSS = wss_sem_big5)

cat("\n=== MÉTODO DO COTOVELO (sem Big 5) ===\n")
print(cotovelo_sem_big5)

write_csv(cotovelo_sem_big5, "apresentacao_uriel/outputs/05_cotovelo.csv")

pdf("apresentacao_uriel/outputs/05_elbow_plot.pdf", width = 10, height = 6)
ggplot(cotovelo_sem_big5, aes(x = K, y = WSS)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  theme_minimal() +
  labs(title = "Método do Cotovelo - Sem Big 5",
       x = "Número de Clusters (K)",
       y = "WSS")
dev.off()

# --- 5b. COEFICIENTE DE SILHUETA ---

silhouette_sem_big5 <- numeric(9)
for(k in 2:10) {
  kmeans_temp <- kmeans(dados_clustering_sem_big5, centers = k, nstart = 25)
  sil <- silhouette(kmeans_temp$cluster, dist(dados_clustering_sem_big5))
  silhouette_sem_big5[k-1] <- mean(sil[, 3])
}

silhueta_sem_big5 <- data.frame(K = 2:10, Silhueta_Media = silhouette_sem_big5)

cat("\n=== COEFICIENTE DE SILHUETA (sem Big 5) ===\n")
print(silhueta_sem_big5)

write_csv(silhueta_sem_big5, "apresentacao_uriel/outputs/05_silhueta.csv")

pdf("apresentacao_uriel/outputs/05_silhouette_scores.pdf", width = 10, height = 6)
ggplot(silhueta_sem_big5, aes(x = K, y = Silhueta_Media)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "Coeficiente de Silhueta - Sem Big 5",
       x = "Número de Clusters (K)",
       y = "Silhueta Média")
dev.off()

# --- 5c. K-MEANS FINAL ---

# Escolher K com maior silhueta
K_sem_big5 <- silhueta_sem_big5$K[which.max(silhueta_sem_big5$Silhueta_Media)]

cat("\n=== K-MEANS FINAL (sem Big 5) COM K =", K_sem_big5, "===\n")

set.seed(123)
kmeans_sem_big5 <- kmeans(dados_clustering_sem_big5, centers = K_sem_big5, nstart = 25)

# Tamanhos dos clusters
cat("Tamanho dos clusters:\n")
print(table(kmeans_sem_big5$cluster))

# Silhueta média
sil_final <- silhouette(kmeans_sem_big5$cluster, dist(dados_clustering_sem_big5))
cat("\nSilhueta média:", round(mean(sil_final[, 3]), 3), "\n")

# --- 5d. CENTRÓIDES ---

# No espaço original
centroides_sem_big5 <- aggregate(df_limpo_sem_big5,
                                  by = list(Cluster = kmeans_sem_big5$cluster),
                                  mean)

cat("\n=== CENTRÓIDES (sem Big 5) ===\n")
print(centroides_sem_big5)

write_csv(centroides_sem_big5, "apresentacao_uriel/outputs/05_centroides.csv")

# Transposto
centroides_t_sem_big5 <- centroides_sem_big5 |>
  pivot_longer(-Cluster, names_to = "Variavel", values_to = "Valor") |>
  pivot_wider(names_from = Cluster, values_from = Valor, names_prefix = "Cluster_")

write_csv(centroides_t_sem_big5, "apresentacao_uriel/outputs/05_centroides_transposto.csv")

# --- 5e. BANCOS POR CLUSTER ---

bancos_cluster_sem_big5 <- data.frame(
  Banco = bancos_sem_big5,
  Cluster = kmeans_sem_big5$cluster
) |>
  arrange(Cluster, Banco)

write_csv(bancos_cluster_sem_big5, "apresentacao_uriel/outputs/05_bancos_por_cluster.csv")

cat("\n=== EXEMPLOS DE BANCOS POR CLUSTER (sem Big 5) ===\n")
for(k in 1:K_sem_big5) {
  cat("\nCluster", k, "(N =", sum(kmeans_sem_big5$cluster == k), "):\n")
  exemplos <- bancos_cluster_sem_big5 |> filter(Cluster == k) |> head(10)
  print(exemplos$Banco)
}

# --- 6. VISUALIZAÇÕES ---

# 6a. Plot clássico K-Means
pdf("apresentacao_uriel/outputs/05_kmeans_plot.pdf", width = 12, height = 10)

plot_data_sem_big5 <- as.data.frame(dados_clustering_sem_big5) |>
  mutate(Cluster = factor(kmeans_sem_big5$cluster),
         Banco = bancos_sem_big5)
colnames(plot_data_sem_big5)[1:M_sem_big5] <- paste0("PC", 1:M_sem_big5)

centroides_pca_sem_big5 <- aggregate(dados_clustering_sem_big5,
                                      by = list(Cluster = kmeans_sem_big5$cluster),
                                      mean)

ggplot(plot_data_sem_big5, aes(x = PC1, y = PC2, color = Cluster, shape = Cluster)) +
  geom_point(size = 2.5, alpha = 0.6) +
  geom_point(data = data.frame(
    PC1 = centroides_pca_sem_big5$PC1,
    PC2 = centroides_pca_sem_big5$PC2,
    Cluster = factor(centroides_pca_sem_big5$Cluster)
  ),
  size = 8, shape = 4, stroke = 2, color = "black") +
  scale_color_brewer(palette = "Set1") +
  theme_minimal(base_size = 12) +
  labs(title = "K-Means Clustering - Sem Big 5",
       subtitle = sprintf("K=%d clusters | Silhueta média = %.3f | N = %d bancos",
                          K_sem_big5, mean(sil_final[, 3]), nrow(df_limpo_sem_big5)),
       x = sprintf("PC1 (%.1f%% variância)", pca_summary_sem_big5$Variancia_Explicada[1]),
       y = sprintf("PC2 (%.1f%% variância)", pca_summary_sem_big5$Variancia_Explicada[2])) +
  annotate("text", x = min(plot_data_sem_big5$PC1) + 0.5,
           y = max(plot_data_sem_big5$PC2) - 0.5,
           label = "X = Centróide", size = 4, hjust = 0)

dev.off()

# 6b. Biplot colorido por cluster
pdf("apresentacao_uriel/outputs/05_biplot_clusters.pdf", width = 12, height = 10)
fviz_pca_biplot(pca_sem_big5,
                geom.ind = "point",
                col.ind = factor(kmeans_sem_big5$cluster),
                palette = "Set1",
                addEllipses = TRUE,
                ellipse.level = 0.68,
                legend.title = "Cluster",
                title = "Biplot PCA - Clusters sem Big 5")
dev.off()

# 6c. Silhouette plot
pdf("apresentacao_uriel/outputs/05_silhouette_plot.pdf", width = 10, height = 8)
fviz_silhouette(sil_final, palette = "Set1",
                print.summary = TRUE,
                title = "Silhouette Plot - Sem Big 5")
dev.off()

# 6d. Boxplots por cluster
bancos_com_cluster_sem_big5 <- df_limpo_sem_big5 |>
  mutate(Cluster = factor(kmeans_sem_big5$cluster))

pdf("apresentacao_uriel/outputs/05_boxplots_clusters.pdf", width = 14, height = 10)
bancos_com_cluster_sem_big5 |>
  pivot_longer(-Cluster, names_to = "Variavel", values_to = "Valor") |>
  ggplot(aes(x = Cluster, y = Valor, fill = Cluster)) +
  geom_boxplot() +
  facet_wrap(~Variavel, scales = "free_y") +
  scale_fill_brewer(palette = "Set1") +
  theme_minimal() +
  labs(title = "Distribuições por Cluster - Sem Big 5",
       x = "Cluster", y = "Valor")
dev.off()

# --- 7. CLUSTERING HIERÁRQUICO (SEM BIG 5) ---

cat("\n=== CLUSTERING HIERÁRQUICO (sem Big 5) ===\n")

dist_sem_big5 <- dist(dados_clustering_sem_big5, method = "euclidean")
hclust_sem_big5 <- hclust(dist_sem_big5, method = "ward.D2")

# Dendrograma
pdf("apresentacao_uriel/outputs/05_dendrograma.pdf", width = 14, height = 8)
plot(hclust_sem_big5, labels = FALSE,
     main = "Dendrograma - Ward's Method (Sem Big 5)",
     xlab = "", sub = "")
rect.hclust(hclust_sem_big5, k = K_sem_big5, border = "red")
dev.off()

# Cortar dendrograma
clusters_hierarquico_sem_big5 <- cutree(hclust_sem_big5, k = K_sem_big5)

# Comparar K-Means vs Hierárquico
comparacao_sem_big5 <- table(K_Means = kmeans_sem_big5$cluster,
                              Hierarquico = clusters_hierarquico_sem_big5)

cat("\n=== COMPARAÇÃO K-MEANS vs HIERÁRQUICO (sem Big 5) ===\n")
print(comparacao_sem_big5)

write.csv(comparacao_sem_big5,
          "apresentacao_uriel/outputs/05_comparacao_metodos.csv")

# Concordância
n_total_sem_big5 <- length(kmeans_sem_big5$cluster)
concordancia_sem_big5 <- sum(diag(comparacao_sem_big5)) / n_total_sem_big5
cat("\nConcordância:", round(concordancia_sem_big5, 3), "\n")

# --- 8. ESTATÍSTICAS COMPARATIVAS ---

cat("\n=== COMPARAÇÃO: COM vs SEM BIG 5 ===\n")

comparacao_analises <- data.frame(
  Metrica = c("N bancos", "M componentes PCA", "Var. PC1", "Var. PC2",
              "m fatores EFA", "K clusters", "Silhueta média"),
  Com_Big5 = c(1055, 2, 66.4, 13.6, 2, 2, 0.972),
  Sem_Big5 = c(
    nrow(df_limpo_sem_big5),
    M_sem_big5,
    round(pca_summary_sem_big5$Variancia_Explicada[1], 1),
    round(pca_summary_sem_big5$Variancia_Explicada[2], 1),
    m_escolhido_sem_big5,
    K_sem_big5,
    round(mean(sil_final[, 3]), 3)
  )
)

cat("\n")
print(comparacao_analises)

write_csv(comparacao_analises, "apresentacao_uriel/outputs/05_comparacao_com_vs_sem_big5.csv")

# --- 9. INTERPRETAÇÃO DOS NOVOS CLUSTERS ---

cat("\n=== INTERPRETAÇÃO DOS CLUSTERS (sem Big 5) ===\n")

for(k in 1:K_sem_big5) {
  cat("\n--- CLUSTER", k, "---\n")

  # Tamanho
  n_cluster <- sum(kmeans_sem_big5$cluster == k)
  cat("Tamanho:", n_cluster, "bancos (", round(n_cluster/nrow(df_limpo_sem_big5)*100, 1), "%)\n")

  # Centróide
  cat("\nCentróide (variáveis principais):\n")
  centroide <- centroides_sem_big5[centroides_sem_big5$Cluster == k, ]

  # Identificar variáveis mais altas/baixas
  valores <- centroide[, -1]  # Remove coluna Cluster
  cat("  Ativo Total:", format(valores$ativo_total, big.mark = ","), "\n")
  cat("  Carteira Crédito:", format(valores$carteira_de_credito, big.mark = ","), "\n")
  cat("  Número de Agências:", round(valores$numero_de_agencias, 1), "\n")
  cat("  Índice Basileia:", round(valores$indice_de_basileia * 100, 1), "%\n")

  # Exemplos de bancos
  cat("\nExemplos de bancos neste cluster:\n")
  exemplos <- bancos_cluster_sem_big5 |> filter(Cluster == k) |> head(5)
  for(i in 1:min(5, nrow(exemplos))) {
    cat("  ", i, ".", exemplos$Banco[i], "\n")
  }
}

cat("\n=== ANÁLISE SEM BIG 5 CONCLUÍDA ===\n")
cat("Total de outputs criados: ~25 arquivos em outputs/05_*\n")
cat("\nPróximo passo: Analisar CHECKPOINT 5 para interpretar novos clusters\n")
