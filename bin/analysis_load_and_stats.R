#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(maftools)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
    stop("Usage: analysis_step1_load_and_stats.R merged_maf_file intermediate_rds_out summary_tsv_out")
}

merged_maf_file <- args[1]
rds_out         <- args[2]
summary_out     <- args[3]

cat("Step1: Reading merged MAF:", merged_maf_file, "\n")

maf <- read.maf(
    maf     = merged_maf_file,
    verbose = FALSE
)

dat <- maf@data

num_variants <- nrow(dat)
num_samples  <- length(unique(dat$Tumor_Sample_Barcode))
num_genes    <- length(unique(dat$Hugo_Symbol))

cat("Step1: Variants:", num_variants,
    "Samples:", num_samples,
    "Genes:", num_genes, "\n")

## Save RDS for downstream steps
saveRDS(
    object = list(maf = maf, dat = dat),
    file   = rds_out
)

## Write a simple summary TSV (no extra packages needed)
summary_df <- data.frame(
    metric = c("num_variants", "num_samples", "num_genes"),
    value  = c(num_variants,    num_samples,    num_genes),
    stringsAsFactors = FALSE
)

write.table(
    summary_df,
    file      = summary_out,
    sep       = "\t",
    quote     = FALSE,
    row.names = FALSE
)

cat("Step1: Saved RDS to", rds_out, "and summary to", summary_out, "\n")
