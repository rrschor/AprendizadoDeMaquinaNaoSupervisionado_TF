# ==============================================================================
# PREPARAÇÃO DE DADOS - ANÁLISE BANCÁRIA
# ==============================================================================
# Fonte: IF.data - Sistema de Informações Financeiras (Banco Central do Brasil)
#        https://www3.bcb.gov.br/ifdata/
# Período: Março/2025
# Instituições: 1,055 bancos (de 1,414 após limpeza)
#
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
