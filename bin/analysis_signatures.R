#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(maftools)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
    stop("Usage: analysis_step4_signatures.R intermediate_rds signatures_dir")
}

rds_in  <- args[1]
sig_dir <- args[2]

dir.create(sig_dir, showWarnings = FALSE, recursive = TRUE)

cat("Step4: Loading RDS for signatures:", rds_in, "\n")
obj <- readRDS(rds_in)
maf <- obj$maf

make_placeholder <- function(path, msg) {
    png(path, width = 1200, height = 400)
    plot.new()
    text(0.5, 0.5, msg, cex = 1.3)
    dev.off()
}

contrib_png   <- file.path(sig_dir, "signature_contributions.png")
matrix_png    <- file.path(sig_dir, "signature_matrix.png")
compare_png   <- file.path(sig_dir, "signature_comparison.png")
sigs_rds      <- file.path(sig_dir, "signatures.rds")

success <- TRUE

tryCatch({
    cat("Step4: Building trinucleotide matrix...\n")
    # NOTE: may require BSgenome.Hsapiens.UCSC.hg19 or hg38 to be installed in the image
    tnm <- trinucleotideMatrix(maf = maf, useSyn = TRUE)
    
    cat("Step4: Extracting signatures...\n")
    sigs <- extractSignatures(mat = tnm, n = 4)
    
    cat("Step4: Plotting signature contributions...\n")
    png(contrib_png, width = 1200, height = 900)
    plotSignatures(sigs, title_size = 1.2)
    dev.off()
    
    cat("Step4: Plotting trinucleotide matrix...\n")
    png(matrix_png, width = 1400, height = 1000)
    plotTrinucleotideMatrix(tnm)
    dev.off()
    
    cat("Step4: Comparing reconstructed vs original signatures...\n")
    png(compare_png, width = 1400, height = 1000)
    compareSignatures(sigs)
    dev.off()
    
    saveRDS(sigs, sigs_rds)
    
}, error = function(e) {
    success <<- FALSE
    warning("Signature analysis failed: ", conditionMessage(e))
})

if (!success) {
    msg <- "Mutational signature analysis unavailable:\nsee logs for details."
    make_placeholder(contrib_png, msg)
    make_placeholder(matrix_png,  msg)
    make_placeholder(compare_png, msg)
}

cat("Step4: Signature step complete. Outputs in", sig_dir, "\n")
