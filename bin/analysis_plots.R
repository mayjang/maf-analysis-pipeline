#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(maftools)
    library(ggplot2)
    library(dplyr)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
    stop("Usage: analysis_step2_plots.R intermediate_rds plots_dir")
}

rds_in   <- args[1]
plotsdir <- args[2]

dir.create(plotsdir, showWarnings = FALSE, recursive = TRUE)

cat("Step2: Loading RDS:", rds_in, "\n")
obj <- readRDS(rds_in)
maf <- obj$maf
dat <- obj$dat

## Helper
save_plot <- function(plot, filename, w = 9, h = 6){
    ggsave(
        filename = file.path(plotsdir, filename),
        plot     = plot,
        width    = w,
        height   = h,
        dpi      = 200
    )
}

### Variant Classification
vc <- dat %>% count(Variant_Classification, sort = TRUE)

p_vc <- ggplot(vc, aes(x = reorder(Variant_Classification, n), y = n)) +
    geom_col(fill = "#69b3a2") +
    coord_flip() +
    labs(title = "Variant Classification", y = "Count", x = "") +
    theme_minimal(base_size = 14)

save_plot(p_vc, "variant_classification.png")

### Variant Type
vt <- dat %>% count(Variant_Type, sort = TRUE)

p_vt <- ggplot(vt, aes(x = reorder(Variant_Type, n), y = n)) +
    geom_col(fill = "#8da0cb") +
    coord_flip() +
    labs(title = "Variant Type", y = "Count", x = "") +
    theme_minimal(base_size = 14)

save_plot(p_vt, "variant_type.png")

### Mutation Burden Per Sample
sb <- dat %>% count(Tumor_Sample_Barcode, sort = TRUE)

p_sb_curve <- ggplot(sb, aes(x = rank(n), y = n)) +
    geom_line(color = "#fc8d62", linewidth = 1.2) +
    labs(
        title = "Mutation Burden Curve",
        x     = "Sample Rank (Low → High)",
        y     = "# Mutations"
    ) +
    theme_minimal(base_size = 14)

save_plot(p_sb_curve, "mutation_burden_curve.png")

### Top 40 Samples by Mutation Burden
sb_top <- sb %>% arrange(desc(n)) %>% head(40)

p_sb_top <- ggplot(sb_top, aes(x = reorder(Tumor_Sample_Barcode, n), y = n)) +
    geom_col(fill = "#fc8d62") +
    coord_flip() +
    labs(
        title = "Mutation Burden (Top 40 Samples)",
        y     = "# Mutations",
        x     = "Sample"
    ) +
    theme_minimal(base_size = 14)

save_plot(p_sb_top, "mutation_burden_top40.png")

### Top 30 Mutated Genes
tg <- dat %>% count(Hugo_Symbol, sort = TRUE) %>% head(30)

p_tg <- ggplot(tg, aes(x = reorder(Hugo_Symbol, n), y = n)) +
    geom_col(fill = "#e78ac3") +
    coord_flip() +
    labs(
        title = "Top 30 Mutated Genes",
        y     = "Count",
        x     = "Gene"
    ) +
    theme_minimal(base_size = 14)

save_plot(p_tg, "top_genes.png")

### Ti/Tv Spectrum
cat("Step2: Creating Ti/Tv plot\n")
png(file.path(plotsdir, "titv.png"), width = 900, height = 600)
titv(maf, plot = TRUE)
dev.off()

### Sample Summary Dashboard
cat("Step2: Creating sample summary dashboard\n")
png(file.path(plotsdir, "sample_summary.png"), width = 2000, height = 1500)
plotmafSummary(maf, rmOutlier = TRUE, addStat = "median", dashboard = TRUE)
dev.off()

### Oncoplot
cat("Step2: Creating oncoplot\n")
png(file.path(plotsdir, "oncoplot.png"), width = 1200, height = 1000)
oncoplot(maf, top = 20)
dev.off()

### Single-Sample Rainfall (all samples combined view as in maftools)
cat("Step2: Creating single-sample rainfall plot\n")
png(file.path(plotsdir, "rainfall_single.png"), width = 1200, height = 900)
rainfallPlot(maf, detectChangePoints = TRUE, pointSize = 0.6)
dev.off()

### Aggregated Rainfall Summary (your custom faceted histogram)

cat("Step2: Creating aggregated rainfall summary\n")

agg <- dat %>%
    dplyr::select(Chromosome, Start_Position) %>%
    mutate(
        chr = Chromosome,
        pos = Start_Position
    )

# Normalize chromosome names: remove "chr", "CHR"
agg$chr <- gsub("^chr", "", agg$chr, ignore.case = TRUE)

# Uppercase chromosomes
agg$chr <- toupper(agg$chr)

# Keep only chromosomes 1–22, X, Y, M/MT
valid_chr <- c(as.character(1:22), "X", "Y", "M", "MT")
agg <- agg %>% filter(chr %in% valid_chr)

# Convert MT -> M to standardize
agg$chr[agg$chr == "MT"] <- "M"

agg_png <- file.path(plotsdir, "rainfall_aggregated.png")

if (nrow(agg) == 0) {
    png(agg_png, width = 1200, height = 400)
    plot.new()
    text(
        0.5, 0.5,
        "Aggregated rainfall plot unavailable:\nNo valid chromosome positions found",
        cex = 1.3
    )
    dev.off()
} else {
    agg$chr <- factor(agg$chr, levels = c(as.character(1:22), "X", "Y", "M"))
    
    p_agg <- ggplot(agg, aes(x = pos)) +
        geom_histogram(binwidth = 1e6, fill = "#7fc97f", color = "white") +
        facet_wrap(~ chr, scales = "free_x", ncol = 4) +
        labs(
            title    = "Aggregated Rainfall Summary",
            subtitle = "Genome-wide mutation density across BLCA samples",
            x        = "Genomic Position",
            y        = "Mutation Count (per 1 Mb bin)"
        ) +
        theme_minimal(base_size = 13)
    
    ggsave(agg_png, p_agg, width = 12, height = 10, dpi = 200)
}

cat("Step2: All plots generated in", plotsdir, "\n")
