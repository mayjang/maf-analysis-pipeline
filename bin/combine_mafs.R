#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(maftools))

args <- commandArgs(trailingOnly=TRUE)
maf_dir  <- args[1]
outfile  <- args[2]

cat("[FAST] Combining MAFs from directory:", maf_dir, "\n")

maf_files <- list.files(maf_dir, pattern = "\\.maf$", full.names = TRUE)

if (length(maf_files) == 0) {
    stop("No MAF files found in directory: ", maf_dir)
}

cat("Found", length(maf_files), "MAF files.\n")

# Combine maf files
combined <- merge_mafs(maf_files)

# Write output
write.mafSummary(maf = combined, basename = outfile)
write.table(combined@data, file = outfile, sep="\t", quote=FALSE, row.names=FALSE)

cat("[FAST] Combined MAF written to:", outfile, "\n")

