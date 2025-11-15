# ==============================================================================
# CLUSTERING - K-MEANS E HIERÁRQUICO
# ==============================================================================
# Objetivo: Agrupar bancos, escolher K, caracterizar clusters
# Dependência: Executar df_banco.R, 02_pca.R primeiro
# Outputs: Clusters, centróides, visualizações em outputs/
# Data Source: IF.data (https://www3.bcb.gov.br/ifdata/)
# ==============================================================================

library(tidyverse)
library(cluster)
library(factoextra)

# Carregar dados
source("apresentacao_uriel/df_banco.R")
source("apresentacao_uriel/02_pca.R")  # Para usar escores PCA

cat("\n=== INICIANDO CLUSTERING ===\n")

# --- 1. PREPARAR DADOS PARA CLUSTERING ---

# Usar escores PCA (decisão do CHECKPOINT 3)
# Razão: Maximiza variância (80%), componentes ortogonais, sem Heywood cases
M <- 2  # Usar M=2 conforme CHECKPOINT 2
dados_clustering <- pca_result$x[, 1:M]

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

# Usar K com maior Silhueta
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

# 7b. Silhouette plot
pdf("apresentacao_uriel/outputs/04_silhouette_plot.pdf", width = 10, height = 8)
sil <- silhouette(kmeans_final$cluster, dist(dados_clustering))
fviz_silhouette(sil, palette = "jco",
                print.summary = TRUE,
                title = "Silhouette Plot - Qualidade dos Clusters")
dev.off()

# 7c. Parallel coordinates plot
bancos_com_cluster <- df_limpo |>
  mutate(Cluster = as.factor(kmeans_final$cluster),
         ID = row_number())

pdf("apresentacao_uriel/outputs/04_parallel_coords.pdf", width = 14, height = 8)
bancos_com_cluster |>
  sample_n(min(100, nrow(bancos_com_cluster))) |>  # Amostra se muitos bancos
  pivot_longer(-c(Cluster, ID), names_to = "Variavel", values_to = "Valor") |>
  ggplot(aes(x = Variavel, y = Valor, group = ID,
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

# Calcular concordância (proporção de observações no mesmo cluster)
n_total <- length(kmeans_final$cluster)
concordancia <- sum(comparacao[row(comparacao) == col(comparacao)]) / n_total
cat("\nConcordância K-Means vs Hierárquico:", round(concordancia, 3), "\n")
cat("Interpretação:", ifelse(concordancia > 0.8, "Alta concordância",
                          ifelse(concordancia > 0.5, "Concordância moderada",
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
cat("\nPróximo passo: Revisar CHECKPOINT 4 em PROGRESSO.md\n")
