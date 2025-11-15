# Análise de Dados Bancários - Aprendizado Não Supervisionado

## Descrição

Este projeto realiza análise exploratória e aplicação de técnicas de aprendizado de máquina não supervisionado (PCA, EFA e Clustering) em dados bancários brasileiros extraídos do sistema IF.data do Banco Central do Brasil.

## Fonte dos Dados

**Sistema**: IF.data - Sistema de Informações Financeiras do Banco Central do Brasil
**URL**: https://www3.bcb.gov.br/ifdata/
**Período de Referência**: Março/2025
**Instituições Analisadas**: 1,055 bancos (de 1,414 originais após limpeza)
**Detalhes**: Ver `DATA_SOURCE.md` para informações completas sobre origem e metodologia

## Estrutura dos Dados

O dataset contém informações financeiras e operacionais de instituições bancárias brasileiras, incluindo:

- **Ativo Total**: Total de ativos da instituição
- **Carteira de Crédito**: Volume de operações de crédito
- **Títulos e Valores Mobiliários**: Investimentos em títulos
- **Passivo Exigível**: Obrigações totais
- **Captações**: Recursos captados
- **Patrimônio Líquido**: Capital próprio da instituição
- **Lucro Líquido**: Resultado financeiro
- **Patrimônio de Referência**: Base para cálculo de índices regulatórios
- **Índice de Basileia**: Indicador de solidez financeira
- **Índice de Imobilização**: Proporção de ativos imobilizados
- **Número de Agências**: Rede de atendimento física
- **Número de Postos de Atendimento**: Pontos de atendimento

## Pré-requisitos

### Bibliotecas R Necessárias

```r
# Instalação completa de todos os pacotes necessários
install.packages(c(
  # Manipulação de dados
  "tidyverse",      # dplyr, ggplot2, tidyr, readr, etc.
  "janitor",        # Limpeza de nomes de colunas
  "data.table",     # Manipulação eficiente

  # Análise multivariada
  "psych",          # PCA, EFA, testes KMO/Bartlett
  "factoextra",     # Visualizações de PCA e clustering
  "FactoMineR",     # Análise fatorial adicional
  "GPArotation",    # Rotações fatoriais (Varimax, Promax)

  # Clustering
  "cluster",        # K-Means, silhueta, clustering hierárquico
  "mclust",         # Métricas de validação (ARI)

  # Visualizações
  "corrplot",       # Matrizes de correlação

  # Documentação
  "knitr",          # R Markdown
  "rmarkdown",      # Compilação de relatórios
  "kableExtra"      # Tabelas formatadas
))
```

### Requisitos de Sistema
- **R**: Versão 4.0 ou superior
- **RStudio**: Recomendado (opcional)
- **Memória**: Mínimo 4GB RAM (dataset de 1,055 observações)

## Processamento dos Dados

O script `apresentacao_uriel/df_banco.R` realiza:

1. **Limpeza dos dados**
   - Padronização de nomes de colunas
   - Remoção de valores ausentes e "NI"
   - Conversão de formatos numéricos (formato brasileiro → padrão)

2. **Transformação**
   - Conversão de percentuais para proporções
   - Padronização (z-score) das variáveis

3. **Análise Exploratória**
   - Matriz de correlação
   - Teste KMO (Kaiser-Meyer-Olkin)
   - Teste de Bartlett

## Uso

```r
source("apresentacao_uriel/df_banco.R")
```

## Outputs

- `df_bancos`: Dataset completo padronizado
- `df_limpo`: Dataset com variáveis selecionadas
- `cor_mat`: Matriz de correlação
- Visualizações de correlação via `corrplot`

## Arquivos de Dados

### Dataset Principal
- **Arquivo**: `apresentacao_uriel/dados.csv`
- **Formato**: CSV com separador ponto-e-vírgula (;)
- **Encoding**: UTF-8
- **Tamanho**: 246.8 KB
- **Observações Originais**: 1,414 instituições
- **Período**: Março/2025
- **Fonte**: IF.data (Banco Central do Brasil)

### Documentação
- **DATA_SOURCE.md**: Informações detalhadas sobre origem, metodologia e qualidade dos dados
- **PLANO_EXECUCAO.md**: Plano conceitual das análises (estrutura geral)
- **docs/plans/2025-11-15-analise-bancaria-unsupervised-ml.md**: Plano de implementação detalhado
- **PROGRESSO.md**: Status atual do projeto e próximos passos

## Estrutura do Projeto

```
.
├── apresentacao_uriel/
│   ├── dados.csv                          # Dataset IF.data (março/2025)
│   ├── df_banco.R                         # Preparação e padronização
│   ├── 01_analise_descritiva.R            # Estatísticas e visualizações
│   ├── 02_pca.R                           # Análise de Componentes Principais
│   ├── 03_efa.R                           # Análise Fatorial Exploratória
│   ├── 04_clustering.R                    # K-Means e Hierárquico (pendente)
│   ├── relatorio_final.Rmd                # Relatório completo (pendente)
│   ├── apresentacao.Rmd                   # Slides apresentação (pendente)
│   └── outputs/                           # Resultados das análises
│       ├── 01_*.{csv,pdf}                 # Análise descritiva (9 arquivos)
│       ├── 02_*.{csv,pdf}                 # PCA (7 arquivos)
│       ├── 03_*.{csv,pdf}                 # EFA (8 arquivos)
│       ├── CHECKPOINT_1_decisoes.md       # Decisões: outliers, correlações
│       ├── CHECKPOINT_2_decisoes.md       # Decisões: M componentes PCA
│       └── CHECKPOINT_3_decisoes.md       # Decisões: m fatores, PCA vs EFA
├── docs/
│   └── plans/                             # Planos de implementação
├── DATA_SOURCE.md                         # Documentação da fonte de dados
├── PLANO_EXECUCAO.md                      # Plano conceitual
├── PROGRESSO.md                           # Status do projeto
└── README.md                              # Este arquivo
```

## Resultados Preliminares

### Análise Descritiva
- **Correlações fortes**: 14 pares com |r| > 0.7
- **Maior correlação**: Ativo Total × Carteira de Crédito (r = 0.991)
- **Outliers**: 12-16% em variáveis financeiras (grandes bancos)
- **Distribuições**: Extrema assimetria à direita (mediana ≪ média)
- **Adequação**: KMO = 0.796 ("Médio/Bom"), Bartlett p < 0.001

### PCA (Análise de Componentes Principais)
- **Componentes retidas**: M = 2 (consenso de critérios)
- **Variância explicada**: 80.0%
- **PC1 (66.4%)**: "Tamanho do Banco" - todas variáveis financeiras (loadings ~-0.43)
- **PC2 (13.6%)**: "Saúde Financeira" - Basileia (+0.72) vs Imobilização (-0.70)
- **Redução**: 8 variáveis → 2 componentes (75% compressão)

### EFA (Análise Fatorial Exploratória)
- **Fatores retidos**: m = 2 (análise paralela sugere 3, mas Fator 3 inútil)
- **Variância explicada**: 68.5% (variância comum)
- **Fator 1 (35.7%)**: "Escala Operacional" - agências (0.92), tamanho financeiro
- **Fator 2 (32.8%)**: "Performance Financeira" - lucro (0.85), patrimônio (0.80)
- **Comunalidades**: >95% para variáveis operacionais/financeiras, ~0% para índices regulatórios
- **Rotação**: Varimax (ortogonal, sem Heywood cases)

### Convergência PCA vs EFA
- **Alta convergência (85%)**: Ambos identificam estrutura bidimensional
- **Diferença principal**: EFA separa infraestrutura física (F1) de resultado financeiro (F2); PCA combina em PC1
- **Achado crítico**: Índices regulatórios têm variância ESPECÍFICA (h²≈0%), independente dos fatores comuns
- **Implicação**: Risco/Solidez é ortogonal a Tamanho/Performance
