# ==============================================================================
# CONVERTER PDFs PRINCIPAIS PARA PNG (para embedding em HTML)
# ==============================================================================

library(pdftools)
library(magick)

cat("=== CONVERTENDO PDFs PARA PNG ===\n")

# Lista de PDFs principais a converter
pdfs_principais <- c(
  "outputs/01_corrplot.pdf",
  "outputs/02_scree_plot.pdf",
  "outputs/02_biplot.pdf",
  "outputs/03_parallel_analysis.pdf",
  "outputs/04_kmeans_classico_nomes.pdf",
  "outputs/04_silhouette_scores.pdf",
  "outputs/07_kmeans_K5.pdf",
  "outputs/07_criterios_K.pdf"
)

for(pdf_file in pdfs_principais) {
  if(file.exists(pdf_file)) {
    png_file <- gsub("\\.pdf$", ".png", pdf_file)

    cat("Convertendo:", pdf_file, "->", png_file, "\n")

    # Converter PDF para PNG com alta resolução
    img <- image_read_pdf(pdf_file, density = 300)
    image_write(img, path = png_file, format = "png", quality = 95)

    cat("  OK\n")
  } else {
    cat("  SKIP (não existe)\n")
  }
}

cat("\n=== CONVERSÃO CONCLUÍDA ===\n")
