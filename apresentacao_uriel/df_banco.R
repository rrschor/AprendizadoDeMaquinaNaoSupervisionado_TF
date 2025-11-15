library(dplyr)
library(purrr)
library(tidyverse)
library(janitor)
library(data.table)
library(psych)
library(corrplot)

dados <- read_csv2(
  "dados.csv",
  locale = locale(decimal_mark = ",", grouping_mark = ".")
) |>
  clean_names() |>                            # nomes padronizados
  select(-x22) |>                             # remove coluna vazia, se existir
  filter(if_all(everything(), ~ . != "NI")) |> # remove "NI"
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
        gsub(",", ".",                # vírgula → ponto
             gsub("%", "",                 # remove símbolo de %
                  gsub("\\.", "", .)))          # remove separadores de milhar
      )
    )
  ) |>
  na.omit()

#### seleção

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
## há algum na?

sum(is.na(df_bancos))

## salva nomes bancos

bancos <- dados$instituicao

## padronizar

df_padro <- scale(df_bancos)

###

### correlação

cor_mat_1 <- cor(df_padro)

## DF limpo

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
  )


## correlação após limpeza
df_limpo_padro <- scale(df_limpo)
cor_mat <- cor(df_limpo_padro)
corrplot(cor_mat, method = "color", type = "upper", tl.cex = 0.7)



### Testes KMO e Bartlett

KMO(df_limpo_padro)
cortest.bartlett(df_limpo_padro)




