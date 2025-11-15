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
