# ==============================================================================
# ANÁLISE COMPLETA SEM OS BIG 7
# ==============================================================================
# Objetivo: Refazer PCA, EFA e Clustering excluindo os 7 maiores outliers
# Justificativa: Big 7 mascaram estrutura dos bancos pequenos/médios
# Big 7: BB, Bradesco, Caixa, Itaú, Santander, BNDES, BTG Pactual
# Outputs: Resultados finais em outputs/06_*.{csv,pdf}
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

cat("\n╔════════════════════════════════════════════════════╗\n")
cat("║   ANÁLISE SEM OS BIG 7 - DESCOBRINDO SUBGRUPOS   ║\n")
cat("╚════════════════════════════════════════════════════╝\n")

# --- 1. IDENTIFICAR E REMOVER BIG 7 ---

# Big 7: Big 5 comerciais + BNDES + BTG Pactual
big7_nomes <- c(
  "BB - PRUDENCIAL",
  "BRADESCO - PRUDENCIAL",
  "CAIXA ECONÔMICA FEDERAL - PRUDENCIAL",
  "ITAU - PRUDENCIAL",
  "SANTANDER - PRUDENCIAL",
  "BNDES - PRUDENCIAL",
  "BTG PACTUAL - PRUDENCIAL"
)

cat("\n=== REMOVENDO BIG 7 ===\n")
cat("Bancos removidos:\n")
for(i in 1:length(big7_nomes)) {
  cat(" ", i, ".", big7_nomes[i], "\n")
}

# Encontrar índices
indices_big7 <- which(bancos %in% big7_nomes)
cat("\nÍndices encontrados:", length(indices_big7), "de 7 esperados\n")

# Criar datasets sem Big 7
df_sem_big7 <- df_limpo[-indices_big7, ]
bancos_sem_big7 <- bancos[-indices_big7]

cat("\n=== NOVO DATASET ===\n")
cat("N original:", nrow(df_limpo), "bancos\n")
cat("N sem Big 7:", nrow(df_sem_big7), "bancos\n")
cat("Removidos:", length(indices_big7), "bancos\n")
cat("Percentual restante:", round(nrow(df_sem_big7)/nrow(df_limpo)*100, 1), "%\n")

# RE-PADRONIZAR (CRÍTICO!)
df_sem_big7_padro <- scale(df_sem_big7)

cat("\n=== RE-PADRONIZAÇÃO (Z-scores recalculados) ===\n")
cat("Médias:", paste(round(range(colMeans(df_sem_big7_padro)), 10), collapse = " a "), "\n")
cat("Desvios:", paste(round(range(apply(df_sem_big7_padro, 2, sd)), 10), collapse = " a "), "\n")

# --- 2. ANÁLISE DESCRITIVA ---

cor_mat_sem_big7 <- cor(df_sem_big7)

cat("\n=== CORRELAÇÕES (sem Big 7) ===\n")

# Correlações fortes
cor_fortes_sem_big7 <- cor_mat_sem_big7 |>
  as.data.frame() |>
  rownames_to_column("var1") |>
  pivot_longer(-var1, names_to = "var2", values_to = "correlacao") |>
  filter(var1 < var2, abs(correlacao) > 0.7) |>
  arrange(desc(abs(correlacao)))

cat("Correlações |r| > 0.7:", nrow(cor_fortes_sem_big7), "pares\n")
write_csv(cor_fortes_sem_big7, "apresentacao_uriel/outputs/06_correlacoes_fortes.csv")

# Adequação
kmo_sem_big7 <- KMO(df_sem_big7_padro)
bartlett_sem_big7 <- cortest.bartlett(df_sem_big7_padro)

cat("\nKMO:", round(kmo_sem_big7$MSA, 3), "(",
    ifelse(kmo_sem_big7$MSA >= 0.8, "Bom", "Médio"), ")\n")
cat("Bartlett p:", format(bartlett_sem_big7$p.value, scientific = TRUE), "\n")

adequacao_sem_big7 <- data.frame(
  Teste = c("KMO", "Bartlett"),
  Valor = c(kmo_sem_big7$MSA, bartlett_sem_big7$chisq),
  p_value = c(NA, bartlett_sem_big7$p.value)
)
write_csv(adequacao_sem_big7, "apresentacao_uriel/outputs/06_adequacao.csv")

# --- 3. PCA SEM BIG 7 ---

cat("\n=== PCA SEM BIG 7 ===\n")

pca_sem_big7 <- prcomp(df_sem_big7_padro, scale. = FALSE)
eigenvalues_sem_big7 <- pca_sem_big7$sdev^2

# Variância
pca_var_sem_big7 <- data.frame(
  Componente = paste0("PC", 1:length(eigenvalues_sem_big7)),
  Autovalor = eigenvalues_sem_big7,
  Var_Pct = eigenvalues_sem_big7 / sum(eigenvalues_sem_big7) * 100,
  Var_Acum = cumsum(eigenvalues_sem_big7 / sum(eigenvalues_sem_big7) * 100)
)

cat("\nPrimeiras 5 componentes:\n")
print(pca_var_sem_big7[1:5, ])

write_csv(pca_var_sem_big7, "apresentacao_uriel/outputs/06_pca_variancia.csv")

# Critérios para M
m_kaiser <- sum(eigenvalues_sem_big7 >= 1)
m_75 <- which(pca_var_sem_big7$Var_Acum >= 75)[1]
m_80 <- which(pca_var_sem_big7$Var_Acum >= 80)[1]

cat("\nCritérios de escolha:\n")
cat("  Kaiser (λ≥1):", m_kaiser, "componentes\n")
cat("  Cut-off 75%:", m_75, "componentes\n")
cat("  Cut-off 80%:", m_80, "componentes\n")

criterios <- data.frame(
  Criterio = c("Kaiser", "75%", "80%"),
  M = c(m_kaiser, m_75, m_80)
)
write_csv(criterios, "apresentacao_uriel/outputs/06_pca_criterios.csv")

# Scree plot
pdf("apresentacao_uriel/outputs/06_scree_plot.pdf", width = 10, height = 6)
fviz_eig(pca_sem_big7, addlabels = TRUE,
         main = "Scree Plot - PCA sem Big 7 (N=1,048)")
dev.off()

# Loadings
loadings_sem_big7 <- pca_sem_big7$rotation
write_csv(as.data.frame(loadings_sem_big7) |> rownames_to_column("variavel"),
          "apresentacao_uriel/outputs/06_pca_loadings.csv")

cat("\nLoadings PC1-PC3:\n")
print(round(loadings_sem_big7[, 1:3], 3))

# Biplot
pdf("apresentacao_uriel/outputs/06_pca_biplot.pdf", width = 12, height = 10)
fviz_pca_biplot(pca_sem_big7,
                col.var = "contrib",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                col.ind = "gray50",
                alpha.ind = 0.5,
                title = "Biplot PCA - Sem Big 7 (N=1,048 bancos)")
dev.off()

# Escolher M
M_final <- max(m_kaiser, m_75)
cat("\nM escolhido:", M_final, "componentes\n")
cat("Variância retida:", round(pca_var_sem_big7$Var_Acum[M_final], 1), "%\n")

# Escores
scores_pca_sem_big7 <- pca_sem_big7$x[, 1:M_final]

# --- 4. EFA SEM BIG 7 ---

cat("\n=== EFA SEM BIG 7 ===\n")

# Análise paralela
parallel_sem_big7 <- fa.parallel(df_sem_big7_padro, fa = "fa", n.iter = 100,
                                  main = "Análise Paralela - Sem Big 7")
m_parallel <- parallel_sem_big7$nfact
cat("Análise paralela sugere:", m_parallel, "fatores\n")

pdf("apresentacao_uriel/outputs/06_efa_parallel.pdf", width = 10, height = 6)
fa.parallel(df_sem_big7_padro, fa = "fa", n.iter = 100,
            main = "Análise Paralela - Sem Big 7")
dev.off()

# Estimar modelo final
efa_sem_big7 <- fa(df_sem_big7_padro, nfactors = m_parallel,
                    rotate = "varimax", fm = "ml", scores = "regression")

cat("\nCargas fatoriais (Varimax, m=", m_parallel, "):\n")
print(round(efa_sem_big7$loadings, 3))

# Salvar
loadings_efa <- data.frame(
  variavel = rownames(efa_sem_big7$loadings),
  efa_sem_big7$loadings[1:nrow(efa_sem_big7$loadings), 1:m_parallel]
)
write_csv(loadings_efa, "apresentacao_uriel/outputs/06_efa_loadings.csv")

comunalidades <- data.frame(
  variavel = colnames(df_sem_big7_padro),
  comunalidade = efa_sem_big7$communality
)
write_csv(comunalidades, "apresentacao_uriel/outputs/06_efa_comunalidades.csv")

# --- 5. CLUSTERING: TESTAR K=2,3,4,5 ---

cat("\n=== CLUSTERING: TESTANDO MÚLTIPLOS K ===\n")

# Dados para clustering
dados_clust <- scores_pca_sem_big7

set.seed(123)

# Calcular WSS e Silhueta para K=1 a 10
wss <- numeric(10)
sil_scores <- numeric(9)

for(k in 1:10) {
  km <- kmeans(dados_clust, centers = k, nstart = 25)
  wss[k] <- km$tot.withinss

  if(k >= 2) {
    sil <- silhouette(km$cluster, dist(dados_clust))
    sil_scores[k-1] <- mean(sil[, 3])
  }
}

# Tabelas
cotovelo_df <- data.frame(K = 1:10, WSS = wss)
silhueta_df <- data.frame(K = 2:10, Silhueta = sil_scores)

write_csv(cotovelo_df, "apresentacao_uriel/outputs/06_cotovelo.csv")
write_csv(silhueta_df, "apresentacao_uriel/outputs/06_silhueta.csv")

cat("\nSilhuetas para diferentes K:\n")
print(silhueta_df[1:7, ])

# Plotar
pdf("apresentacao_uriel/outputs/06_criterios_K.pdf", width = 14, height = 6)
par(mfrow = c(1, 2))

# Cotovelo
plot(cotovelo_df$K, cotovelo_df$WSS, type = "b", pch = 19, cex = 1.5,
     main = "Método do Cotovelo (sem Big 7)",
     xlab = "K", ylab = "WSS", col = "steelblue", lwd = 2)
grid()

# Silhueta
plot(silhueta_df$K, silhueta_df$Silhueta, type = "b", pch = 19, cex = 1.5,
     main = "Coeficiente de Silhueta (sem Big 7)",
     xlab = "K", ylab = "Silhueta Média", col = "firebrick", lwd = 2)
abline(h = 0.5, lty = 2, col = "gray50")
grid()

dev.off()

# --- 6. GERAR SOLUÇÕES PARA K=3, K=4, K=5 ---

cat("\n=== GERANDO MÚLTIPLAS SOLUÇÕES DE CLUSTERING ===\n")

solucoes <- list()

for(K in 3:5) {
  cat("\n--- Solução K =", K, "---\n")

  set.seed(123)
  km <- kmeans(dados_clust, centers = K, nstart = 25)
  sil <- silhouette(km$cluster, dist(dados_clust))

  # Tamanhos
  tamanhos <- as.data.frame(table(km$cluster))
  colnames(tamanhos) <- c("Cluster", "N")
  tamanhos$Percentual <- round(tamanhos$N / nrow(df_sem_big7) * 100, 1)

  cat("Tamanhos dos clusters:\n")
  print(tamanhos)

  cat("Silhueta média:", round(mean(sil[, 3]), 3), "\n")

  # Centróides
  centroides <- aggregate(df_sem_big7,
                          by = list(Cluster = km$cluster),
                          mean)

  # Salvar
  write_csv(tamanhos, sprintf("apresentacao_uriel/outputs/06_tamanhos_K%d.csv", K))
  write_csv(centroides, sprintf("apresentacao_uriel/outputs/06_centroides_K%d.csv", K))

  # Bancos por cluster
  bancos_cluster <- data.frame(
    Banco = bancos_sem_big7,
    Cluster = km$cluster
  ) |>
    arrange(Cluster, Banco)

  write_csv(bancos_cluster, sprintf("apresentacao_uriel/outputs/06_bancos_K%d.csv", K))

  # Armazenar solução
  solucoes[[as.character(K)]] <- list(
    K = K,
    kmeans = km,
    silhueta = mean(sil[, 3]),
    tamanhos = tamanhos,
    centroides = centroides,
    bancos = bancos_cluster
  )

  # Plot
  pdf(sprintf("apresentacao_uriel/outputs/06_kmeans_K%d.pdf", K), width = 12, height = 10)

  plot_data <- as.data.frame(dados_clust) |>
    mutate(Cluster = factor(km$cluster))
  colnames(plot_data)[1:M_final] <- paste0("PC", 1:M_final)

  centroides_pca <- aggregate(dados_clust, by = list(Cluster = km$cluster), mean)

  p <- ggplot(plot_data, aes(x = PC1, y = PC2, color = Cluster, shape = Cluster)) +
    geom_point(size = 2.5, alpha = 0.6) +
    geom_point(data = data.frame(
      PC1 = centroides_pca$PC1,
      PC2 = centroides_pca$PC2,
      Cluster = factor(centroides_pca$Cluster)
    ),
    size = 8, shape = 4, stroke = 2.5, color = "black") +
    scale_color_brewer(palette = "Set1") +
    theme_minimal(base_size = 13) +
    labs(title = sprintf("K-Means: K=%d Clusters (sem Big 7)", K),
         subtitle = sprintf("Silhueta = %.3f | N = %d bancos",
                            mean(sil[, 3]), nrow(df_sem_big7)),
         x = sprintf("PC1 (%.1f%% var.)", pca_var_sem_big7$Var_Pct[1]),
         y = sprintf("PC2 (%.1f%% var.)", pca_var_sem_big7$Var_Pct[2]))

  print(p)
  dev.off()
}

# --- 7. ANÁLISE DETALHADA DA MELHOR SOLUÇÃO ---

# Escolher K baseado em silhueta ≥ 0.5 e interpretabilidade
K_escolhido <- 3  # Baseado em silhueta (K=3: 0.906, K=4: 0.868)

cat("\n╔════════════════════════════════════════════════════╗\n")
cat("║   SOLUÇÃO ESCOLHIDA: K =", K_escolhido, "CLUSTERS             ║\n")
cat("╚════════════════════════════════════════════════════╝\n")

solucao_final <- solucoes[[as.character(K_escolhido)]]

cat("\n=== CARACTERIZAÇÃO DOS", K_escolhido, "CLUSTERS ===\n")

for(k in 1:K_escolhido) {
  cat("\n┌─ CLUSTER", k, "──────────────────────────────────┐\n")

  # Tamanho
  n_cluster <- solucao_final$tamanhos$N[k]
  pct_cluster <- solucao_final$tamanhos$Percentual[k]
  cat("│ Tamanho:", n_cluster, "bancos (", pct_cluster, "%)           │\n")

  # Centróide (valores principais)
  cent <- solucao_final$centroides[k, ]

  cat("│                                              │\n")
  cat("│ Perfil Financeiro:                           │\n")
  cat("│  - Ativo Total: R$", format(round(cent$ativo_total/1e6, 1), nsmall=1), "milhões   │\n")
  cat("│  - Carteira Crédito: R$", format(round(cent$carteira_de_credito/1e6, 1), nsmall=1), "milhões │\n")
  cat("│  - Patrimônio: R$", format(round(cent$patrimonio_liquido/1e3, 1), nsmall=1), "mil       │\n")
  cat("│  - Lucro: R$", format(round(cent$lucro_liquido/1e3, 1), nsmall=1), "mil            │\n")
  cat("│                                              │\n")
  cat("│ Perfil Regulatório:                          │\n")
  cat("│  - Basileia:", round(cent$indice_de_basileia*100, 1), "%                    │\n")
  cat("│  - Imobilização:", round(cent$indice_de_imobilizacao*100, 1), "%              │\n")
  cat("│                                              │\n")
  cat("│ Infraestrutura:                              │\n")
  cat("│  - Agências:", round(cent$numero_de_agencias, 1), "                         │\n")
  cat("│  - Postos:", round(cent$numero_de_postos_de_atendimento, 1), "                   │\n")

  # Exemplos
  cat("│                                              │\n")
  cat("│ Exemplos de bancos:                          │\n")
  exemplos <- solucao_final$bancos |> filter(Cluster == k) |> head(8)
  for(i in 1:min(8, nrow(exemplos))) {
    banco_nome <- gsub(" - PRUDENCIAL", "", exemplos$Banco[i])
    if(nchar(banco_nome) > 35) banco_nome <- substr(banco_nome, 1, 35)
    cat("│  ", i, ".", banco_nome, "\n")
  }

  cat("└──────────────────────────────────────────────┘\n")
}

# --- 8. CLUSTERING HIERÁRQUICO ---

cat("\n=== CLUSTERING HIERÁRQUICO (sem Big 7) ===\n")

dist_sem_big7 <- dist(dados_clust, method = "euclidean")
hclust_sem_big7 <- hclust(dist_sem_big7, method = "ward.D2")

pdf("apresentacao_uriel/outputs/06_dendrograma.pdf", width = 14, height = 8)
plot(hclust_sem_big7, labels = FALSE,
     main = "Dendrograma - Ward's Method (Sem Big 7, N=1,048)",
     xlab = "", sub = "")
rect.hclust(hclust_sem_big7, k = K_escolhido, border = "red")
dev.off()

clusters_hier <- cutree(hclust_sem_big7, k = K_escolhido)

# Comparação
comparacao <- table(K_Means = solucao_final$kmeans$cluster,
                    Hierarquico = clusters_hier)

cat("\nComparação K-Means vs Hierárquico:\n")
print(comparacao)

write.csv(comparacao, "apresentacao_uriel/outputs/06_comparacao_metodos.csv")

# --- 9. VISUALIZAÇÃO FINAL ---

pdf("apresentacao_uriel/outputs/06_kmeans_final.pdf", width = 14, height = 10)

plot_data_final <- as.data.frame(dados_clust) |>
  mutate(Cluster = factor(solucao_final$kmeans$cluster))
colnames(plot_data_final)[1:M_final] <- paste0("PC", 1:M_final)

centroides_final <- aggregate(dados_clust,
                               by = list(Cluster = solucao_final$kmeans$cluster),
                               mean)

ggplot(plot_data_final, aes(x = PC1, y = PC2, color = Cluster, shape = Cluster)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_point(data = data.frame(
    PC1 = centroides_final$PC1,
    PC2 = centroides_final$PC2,
    Cluster = factor(centroides_final$Cluster)
  ),
  size = 10, shape = 4, stroke = 3, color = "black", show.legend = FALSE) +
  scale_color_manual(values = c("1" = "#E41A1C", "2" = "#377EB8", "3" = "#4DAF4A",
                                 "4" = "#984EA3", "5" = "#FF7F00")) +
  scale_shape_manual(values = c(16, 17, 15, 18, 8)) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "right") +
  labs(title = sprintf("K-Means: K=%d Clusters - Bancos Brasileiros (Sem Big 7)", K_escolhido),
       subtitle = sprintf("Silhueta = %.3f | N = %d bancos | Variância retida = %.1f%%",
                          solucao_final$silhueta, nrow(df_sem_big7),
                          pca_var_sem_big7$Var_Acum[M_final]),
       x = sprintf("PC1 - %.1f%% variância", pca_var_sem_big7$Var_Pct[1]),
       y = sprintf("PC2 - %.1f%% variância", pca_var_sem_big7$Var_Pct[2]),
       color = "Cluster",
       shape = "Cluster") +
  annotate("text", x = min(plot_data_final$PC1) + 0.3,
           y = max(plot_data_final$PC2) - 0.3,
           label = "X = Centróide do cluster", size = 4, hjust = 0)

dev.off()

# Boxplots por cluster
pdf("apresentacao_uriel/outputs/06_boxplots_K3.pdf", width = 14, height = 10)

df_sem_big7 |>
  mutate(Cluster = factor(solucao_final$kmeans$cluster)) |>
  pivot_longer(-Cluster, names_to = "Variavel", values_to = "Valor") |>
  ggplot(aes(x = Cluster, y = Valor, fill = Cluster)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~Variavel, scales = "free_y", ncol = 4) +
  scale_fill_manual(values = c("1" = "#E41A1C", "2" = "#377EB8", "3" = "#4DAF4A")) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10)) +
  labs(title = "Distribuições por Cluster (K=3, sem Big 7)",
       x = "Cluster", y = "Valor")

dev.off()

cat("\n╔════════════════════════════════════════════════════╗\n")
cat("║            ANÁLISE SEM BIG 7 CONCLUÍDA           ║\n")
cat("╚════════════════════════════════════════════════════╝\n")
cat("\nOutputs criados em: apresentacao_uriel/outputs/06_*\n")
cat("Total de arquivos: ~35\n")
cat("\nPróximo passo: Analisar CHECKPOINT 6 para interpretar os", K_escolhido, "novos clusters\n")
