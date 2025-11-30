#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(base64enc)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
    stop("Usage: generate_html_report.R summary_tsv plots_dir report_html_out")
}

summary_file <- args[1]
plots_dir    <- args[2]
report_file  <- args[3]

cat("HTML: Reading summary from:", summary_file, "\n")

summ <- read.table(
    summary_file,
    header           = TRUE,
    sep              = "\t",
    stringsAsFactors = FALSE
)

get_metric <- function(name) {
    as.numeric(summ$value[summ$metric == name])
}

num_variants <- get_metric("num_variants")
num_samples  <- get_metric("num_samples")
num_genes    <- get_metric("num_genes")

embed_image_base64 <- function(path) {
    if (!file.exists(path)) {
        warning("Image not found for embedding: ", path)
        return("")
    }
    base64enc::dataURI(file = path, mime = "image/png")
}

html_header <- "
<html>
<head>
<title>TCGA BLCA Mutation Analysis Report</title>
<style>
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
    margin: 40px;
    background: #fafafa;
    color: #333;
}
h1, h2 { color: #2c3e50; }
h1 { border-bottom: 3px solid #2c3e50; padding-bottom: 5px; }
.section { margin-top: 50px; }
img { margin-top: 10px; border-radius: 4px; border: 1px solid #bbb; }
p { max-width: 900px; }
.info-box {
    background: #eef3f7;
    padding: 15px 20px;
    border-left: 5px solid #2c3e50;
    border-radius: 6px;
    margin-bottom: 30px;
}
</style>
</head>

<body>

<h1>TCGA BLCA Mutation Analysis Report</h1>

<div class='info-box'>
<p><b>Name:</b> May Jang - 97079776 <br>
<b>Course:</b> BIOF 501 - Term Project <br>
<b>Institution:</b> University of British Columbia<br>
<b>Date:</b> November 29th, 2025</p>
</div>

<div class='info-box'>
<p>
This project analyzes somatic mutation data from the TCGA Bladder Urothelial Carcinoma (BLCA)
cohort using a reproducible Nextflow pipeline and R-based maftools analysis.
The workflow summarizes mutation burden, identifies recurrently mutated genes,
characterizes variant types, and visualizes genome-wide mutation patterns.
These analyses provide genomic insights into bladder cancer biology.
</p>
</div>
"

write(html_header, file = report_file)

## Summary section
cat("<div class='section' id='summary'><h2>Summary</h2>", file = report_file, append = TRUE)
cat("<p><b>Number of variants:</b> ", num_variants, "<br>", file = report_file, append = TRUE)
cat("<b>Number of samples:</b> ",  num_samples,  "<br>", file = report_file, append = TRUE)
cat("<b>Number of genes:</b> ",    num_genes,    "</p></div>\n", file = report_file, append = TRUE)

## Plot section
cat("<div class='section' id='plots'><h2>Plots</h2>\n", file = report_file, append = TRUE)

plots <- list(
    list("variant_classification.png", "Variant Classification",
         "Distribution of mutation classifications in BLCA:"),
    list("variant_type.png", "Variant Type",
         "Distribution of SNPs, INDELs, and complex variants:"),
    list("mutation_burden_curve.png", "Mutation Burden Curve",
         "Ranked mutation burden across BLCA samples:"),
    list("mutation_burden_top40.png", "Mutation Burden (Top 40 Samples)",
         "Most mutated bladder cancer samples:"),
    list("top_genes.png", "Top 30 Mutated Genes",
         "Most recurrently mutated genes in BLCA:"),
    list("titv.png", "Transition / Transversion Spectrum",
         "Relative frequency of transitions vs transversions:"),
    list("sample_summary.png", "Sample Mutation Summary",
         "Overview of mutation counts, variant types, and QC metrics:"),
    list("oncoplot.png", "Oncoplot (Top 20 Genes)",
         "High-level mutation matrix across the cohort:"),
    list("rainfall_single.png", "Rainfall Plot (Single View)",
         "Inter-mutation distances to highlight clustered mutations (kataegis):"),
    list("rainfall_aggregated.png", "Aggregated Rainfall Summary",
         "Genome-wide mutation density across all BLCA samples:")
)

for (p in plots) {
    fname   <- p[[1]]
    title   <- p[[2]]
    caption <- p[[3]]

    img_path <- file.path(plots_dir, fname)
    img_b64  <- embed_image_base64(img_path)

    cat("<h3>", title, "</h3>\n", file = report_file, append = TRUE)
    cat("<p>", caption, "</p>\n", file = report_file, append = TRUE)
    display_width <- if (fname %in% c("sample_summary.png", "oncoplot.png")) 1400 else 900

    cat("<img src='", img_b64, "' width='", display_width, "'><br><br>\n",
        file = report_file, append = TRUE)
}

cat("</div>\n", file = report_file, append = TRUE)
cat("</body></html>\n", file = report_file, append = TRUE)

cat("HTML report written to:", report_file, "\n")
#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(base64enc)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
    stop("Usage: generate_html_report.R summary_tsv plots_dir report_html_out")
}

summary_file <- args[1]
plots_dir    <- args[2]
report_file  <- args[3]

cat("HTML: Reading summary from:", summary_file, "\n")

summ <- read.table(
    summary_file,
    header           = TRUE,
    sep              = "\t",
    stringsAsFactors = FALSE
)

get_metric <- function(name) {
    as.numeric(summ$value[summ$metric == name])
}

num_variants <- get_metric("num_variants")
num_samples  <- get_metric("num_samples")
num_genes    <- get_metric("num_genes")

embed_image_base64 <- function(path) {
    if (!file.exists(path)) {
        warning("Image not found for embedding: ", path)
        return("")
    }
    base64enc::dataURI(file = path, mime = "image/png")
}

html_header <- "
<html>
<head>
<title>TCGA BLCA Mutation Analysis Report</title>
<style>
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
    margin: 40px;
    background: #fafafa;
    color: #333;
}
h1, h2 { color: #2c3e50; }
h1 { border-bottom: 3px solid #2c3e50; padding-bottom: 5px; }
.section { margin-top: 50px; }
img { margin-top: 10px; border-radius: 4px; border: 1px solid #bbb; }
p { max-width: 900px; }
.info-box {
    background: #eef3f7;
    padding: 15px 20px;
    border-left: 5px solid #2c3e50;
    border-radius: 6px;
    margin-bottom: 30px;
}
</style>
</head>

<body>

<h1>TCGA BLCA Mutation Analysis Report</h1>

<div class='info-box'>
<p><b>Name:</b> May Jang - 97079776 <br>
<b>Course:</b> BIOF 501 - Term Project <br>
<b>Institution:</b> University of British Columbia<br>
<b>Date:</b> November 29th, 2025</p>
</div>

<div class='info-box'>
<p>
This project analyzes somatic mutation data from the TCGA Bladder Urothelial Carcinoma (BLCA)
cohort using a reproducible Nextflow pipeline and R-based maftools analysis.
The workflow summarizes mutation burden, identifies recurrently mutated genes,
characterizes variant types, and visualizes genome-wide mutation patterns.
These analyses provide genomic insights into bladder cancer biology.
</p>
</div>
"

write(html_header, file = report_file)

## Summary section
cat("<div class='section' id='summary'><h2>Summary</h2>", file = report_file, append = TRUE)
cat("<p><b>Number of variants:</b> ", num_variants, "<br>", file = report_file, append = TRUE)
cat("<b>Number of samples:</b> ",  num_samples,  "<br>", file = report_file, append = TRUE)
cat("<b>Number of genes:</b> ",    num_genes,    "</p></div>\n", file = report_file, append = TRUE)

## Plot section
cat("<div class='section' id='plots'><h2>Plots</h2>\n", file = report_file, append = TRUE)

plots <- list(
    list("variant_classification.png", "Variant Classification",
         "Distribution of mutation classifications in BLCA:"),
    list("variant_type.png", "Variant Type",
         "Distribution of SNPs, INDELs, and complex variants:"),
    list("mutation_burden_curve.png", "Mutation Burden Curve",
         "Ranked mutation burden across BLCA samples:"),
    list("mutation_burden_top40.png", "Mutation Burden (Top 40 Samples)",
         "Most mutated bladder cancer samples:"),
    list("top_genes.png", "Top 30 Mutated Genes",
         "Most recurrently mutated genes in BLCA:"),
    list("titv.png", "Transition / Transversion Spectrum",
         "Relative frequency of transitions vs transversions:"),
    list("sample_summary.png", "Sample Mutation Summary",
         "Overview of mutation counts, variant types, and QC metrics:"),
    list("oncoplot.png", "Oncoplot (Top 20 Genes)",
         "High-level mutation matrix across the cohort:"),
    list("rainfall_single.png", "Rainfall Plot (Single View)",
         "Inter-mutation distances to highlight clustered mutations (kataegis):"),
    list("rainfall_aggregated.png", "Aggregated Rainfall Summary",
         "Genome-wide mutation density across all BLCA samples:")
)

for (p in plots) {
    fname   <- p[[1]]
    title   <- p[[2]]
    caption <- p[[3]]

    img_path <- file.path(plots_dir, fname)
    img_b64  <- embed_image_base64(img_path)

    cat("<h3>", title, "</h3>\n", file = report_file, append = TRUE)
    cat("<p>", caption, "</p>\n", file = report_file, append = TRUE)
    display_width <- if (fname %in% c("sample_summary.png", "oncoplot.png")) 1400 else 900

    cat("<img src='", img_b64, "' width='", display_width, "'><br><br>\n",
        file = report_file, append = TRUE)
}

cat("</div>\n", file = report_file, append = TRUE)
cat("</body></html>\n", file = report_file, append = TRUE)

cat("HTML report written to:", report_file, "\n")
