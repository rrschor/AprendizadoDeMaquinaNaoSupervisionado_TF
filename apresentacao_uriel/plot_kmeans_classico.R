# ==============================================================================
# PLOT CLÁSSICO DO K-MEANS
# ==============================================================================
# Objetivo: Visualização clássica de clustering com centróides
# Dependência: Executar df_banco.R, 02_pca.R, 04_clustering.R primeiro
# ==============================================================================

library(tidyverse)

# Carregar dados e resultados
source("apresentacao_uriel/df_banco.R")
source("apresentacao_uriel/02_pca.R")
source("apresentacao_uriel/04_clustering.R")

cat("\n=== CRIANDO PLOT CLÁSSICO DO K-MEANS ===\n")

# --- 1. PREPARAR DADOS PARA PLOT ---

# Escores PCA (espaço 2D onde clustering foi executado)
pca_scores <- as.data.frame(dados_clustering)
colnames(pca_scores) <- c("PC1", "PC2")

# Adicionar cluster assignment e nome dos bancos
plot_data <- pca_scores |>
  mutate(
    Cluster = factor(kmeans_final$cluster,
                     levels = c(1, 2),
                     labels = c("Demais Bancos", "Big Five")),
    Banco = bancos
  )

# Calcular centróides no espaço PCA
centroides_pca <- aggregate(pca_scores,
                            by = list(Cluster = kmeans_final$cluster),
                            mean)

# --- 2. PLOT CLÁSSICO ---

pdf("apresentacao_uriel/outputs/04_kmeans_classico.pdf", width = 12, height = 10)

# Criar plot base
p <- ggplot(plot_data, aes(x = PC1, y = PC2, color = Cluster, shape = Cluster)) +
  # Pontos dos bancos
  geom_point(size = 3, alpha = 0.7) +

  # Centróides (marcados com X grande)
  geom_point(data = data.frame(
    PC1 = centroides_pca$PC1,
    PC2 = centroides_pca$PC2,
    Cluster = factor(centroides_pca$Cluster,
                     levels = c(1, 2),
                     labels = c("Demais Bancos", "Big Five"))
  ),
  aes(x = PC1, y = PC2, color = Cluster),
  size = 8, shape = 4, stroke = 2) +

  # Cores personalizadas
  scale_color_manual(values = c("Demais Bancos" = "#00BFC4",
                                 "Big Five" = "#F8766D")) +
  scale_shape_manual(values = c("Demais Bancos" = 16,
                                "Big Five" = 17)) +

  # Tema e labels
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "right",
    legend.title = element_text(face = "bold", size = 14),
    legend.text = element_text(size = 12),
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "K-Means Clustering - Setor Bancário Brasileiro",
    subtitle = sprintf("K=2 clusters | Silhueta média = 0.972 | N = 1,055 bancos"),
    x = "PC1 - Tamanho do Banco (66.4% variância)",
    y = "PC2 - Saúde Financeira (13.6% variância)",
    color = "Cluster",
    shape = "Cluster"
  ) +

  # Adicionar anotação para centróides
  annotate("text",
           x = min(plot_data$PC1) + 2,
           y = max(plot_data$PC2) - 0.5,
           label = "✕ = Centróide do cluster",
           size = 4, hjust = 0)

print(p)

dev.off()

# --- 3. VERSÃO ALTERNATIVA COM NOMES DOS BIG 5 ---

pdf("apresentacao_uriel/outputs/04_kmeans_classico_nomes.pdf", width = 14, height = 10)

# Identificar os Big 5 para rotular
big5_data <- plot_data |> filter(Cluster == "Big Five")

p2 <- ggplot(plot_data, aes(x = PC1, y = PC2, color = Cluster, shape = Cluster)) +
  # Pontos dos bancos
  geom_point(size = 3, alpha = 0.7) +

  # Centróides
  geom_point(data = data.frame(
    PC1 = centroides_pca$PC1,
    PC2 = centroides_pca$PC2,
    Cluster = factor(centroides_pca$Cluster,
                     levels = c(1, 2),
                     labels = c("Demais Bancos", "Big Five"))
  ),
  aes(x = PC1, y = PC2, color = Cluster),
  size = 8, shape = 4, stroke = 2) +

  # Labels para os Big 5
  geom_text(data = big5_data,
            aes(label = gsub(" - PRUDENCIAL", "", Banco)),
            vjust = -1, hjust = 0.5, size = 4, fontface = "bold",
            show.legend = FALSE) +

  # Cores personalizadas
  scale_color_manual(values = c("Demais Bancos" = "#00BFC4",
                                 "Big Five" = "#F8766D")) +
  scale_shape_manual(values = c("Demais Bancos" = 16,
                                "Big Five" = 17)) +

  # Tema
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "right",
    legend.title = element_text(face = "bold", size = 14),
    legend.text = element_text(size = 12),
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "K-Means Clustering - Identificação dos Big Five",
    subtitle = "Os 5 maiores bancos do Brasil identificados automaticamente pelo algoritmo",
    x = "PC1 - Tamanho do Banco (66.4% variância)",
    y = "PC2 - Saúde Financeira (13.6% variância)",
    color = "Cluster",
    shape = "Cluster"
  ) +

  annotate("text",
           x = min(plot_data$PC1) + 2,
           y = max(plot_data$PC2) - 0.5,
           label = "✕ = Centróide do cluster",
           size = 4, hjust = 0)

print(p2)

dev.off()

# --- 4. VERSÃO SIMPLIFICADA (SEM LEGENDA COMPLEXA) ---

pdf("apresentacao_uriel/outputs/04_kmeans_simples.pdf", width = 10, height = 8)

p3 <- ggplot(plot_data, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point(size = 2.5, alpha = 0.6) +

  # Centróides grandes
  geom_point(data = data.frame(
    PC1 = centroides_pca$PC1,
    PC2 = centroides_pca$PC2,
    Cluster = factor(centroides_pca$Cluster,
                     levels = c(1, 2),
                     labels = c("Demais Bancos", "Big Five"))
  ),
  size = 10, shape = 4, stroke = 3, show.legend = FALSE) +

  scale_color_manual(values = c("Demais Bancos" = "steelblue",
                                 "Big Five" = "firebrick")) +

  theme_minimal(base_size = 13) +
  theme(
    legend.position = c(0.85, 0.15),
    legend.background = element_rect(fill = "white", color = "gray80"),
    legend.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", hjust = 0.5)
  ) +
  labs(
    title = "K-Means: 2 Clusters no Espaço PCA",
    x = "PC1 (Tamanho)",
    y = "PC2 (Solidez)"
  )

print(p3)

dev.off()

cat("\n=== PLOTS CLÁSSICOS CRIADOS ===\n")
cat("1. 04_kmeans_classico.pdf - Plot padrão com legenda completa\n")
cat("2. 04_kmeans_classico_nomes.pdf - Com nomes dos Big 5\n")
cat("3. 04_kmeans_simples.pdf - Versão simplificada\n")
cat("\nTodos salvos em: apresentacao_uriel/outputs/\n")
