nextflow.enable.dsl=2

params.maf_dir = params.maf_dir ?: "data/all_maf_flat"
params.outdir  = params.outdir  ?: "results"

workflow {

    // MAF directory inside the container
    def container_maf_dir = "/pipeline/${params.maf_dir}"

    println "[NF] Host directory:      ${params.maf_dir}"
    println "[NF] Container directory: ${container_maf_dir}"

    // Combine all MAFs into one merged file
    merged_ch = COMBINE_MAFS(container_maf_dir)

    // Load MAF, compute basic stats, and produce:
    //   intermediate.rds
    //   summary.tsv
    def (stats_rds, summary_tsv) = LOAD_STATS(merged_ch)

    // Generate all maftools plots
    plots_ch = GENERATE_PLOTS(stats_rds)

    // Build the HTML report using summary + plots
    GENERATE_HTML(
        summary_tsv,
        plots_ch
    )
}

//
// PROCESS DEFINITIONS
//

process COMBINE_MAFS {
    tag "combine_mafs"
    publishDir "${params.outdir}", mode: "copy"

    input:
    val maf_dir

    output:
    path "merged.maf"

    script:
    """
    echo "[NF] Combining all MAFs in: ${maf_dir}"
    ls -l ${maf_dir} | head || true

    Rscript /pipeline/bin/combine_mafs.R \
        ${maf_dir} \
        merged.maf
    """
}

process LOAD_STATS {
    tag "load_stats"
    publishDir "${params.outdir}", mode: "copy"

    input:
    path merged_maf

    output:
    path "intermediate.rds"
    path "summary.tsv"

    script:
    """
    Rscript /pipeline/bin/analysis_load_and_stats.R \
        ${merged_maf} \
        intermediate.rds \
        summary.tsv
    """
}

process GENERATE_PLOTS {
    tag "generate_plots"
    publishDir "${params.outdir}", mode: "copy"

    input:
    path stats_rds

    output:
    path "plots"

    script:
    """
    mkdir -p plots
    Rscript /pipeline/bin/analysis_plots.R \
        ${stats_rds} \
        plots
    """
}

process GENERATE_HTML {
    tag "generate_html"
    publishDir "${params.outdir}", mode: "copy"

    input:
    path summary_tsv
    path plots

    output:
    path "report.html"

    script:
    """
    Rscript /pipeline/bin/generate_html_report.R \
        ${summary_tsv} \
        ${plots} \
        report.html
    """
}

workflow.onComplete {
    println "pipeline complete"
}


// nextflow.enable.dsl=2

// params.maf_dir = params.maf_dir ?: "data/all_maf_flat"
// params.outdir  = params.outdir  ?: "results"

// workflow {

//     // MAF directory inside the container
//     def container_maf_dir = "/pipeline/${params.maf_dir}"

//     println "[NF] Host directory:      ${params.maf_dir}"
//     println "[NF] Container directory: ${container_maf_dir}"

//     //
//     // STEP 0 — Combine all MAF files
//     //
//     merged_ch = COMBINE_MAFS(container_maf_dir)

//     //
//     // STEP 1 — Load MAF, compute summary, and output:
//     //  - intermediate.rds
//     //  - summary.tsv
//     //
//     def (stats_rds, summary_tsv) = STEP1_LOAD_STATS(merged_ch)

//     //
//     // STEP 2 — Generate all base maftools plots
//     //
//     plots_ch = STEP2_PLOTS(stats_rds)

//     //
//     // STEP 3 — Mutational signature analysis
//     //
//     sigs_ch = STEP4_SIGNATURES(stats_rds)

//     //
//     // STEP 4 — Build full HTML report
//     //
//     STEP3_HTML_REPORT(
//         summary_tsv,
//         plots_ch,
//         sigs_ch
//     )
// }

// //
// // PROCESS DEFINITIONS
// //

// process COMBINE_MAFS {
//     tag "combine"
//     publishDir "${params.outdir}", mode: "copy"

//     input:
//     val maf_dir

//     output:
//     path "merged.maf"

//     script:
//     """
//     echo "[NF] Combining all MAFs in: ${maf_dir}"
//     ls -l ${maf_dir} | head || true

//     Rscript /pipeline/bin/combine_mafs.R \
//         ${maf_dir} \
//         merged.maf
//     """
// }

// process STEP1_LOAD_STATS {
//     tag "step1_load"
//     publishDir "${params.outdir}", mode: "copy"

//     input:
//     path merged_maf

//     output:
//     path "intermediate.rds"
//     path "summary.tsv"

//     script:
//     """
//     Rscript /pipeline/bin/analysis_load_and_stats.R \
//         ${merged_maf} \
//         intermediate.rds \
//         summary.tsv
//     """
// }

// process STEP2_PLOTS {
//     tag "step2_plots"
//     publishDir "${params.outdir}", mode: "copy"

//     input:
//     path stats_rds

//     output:
//     path "plots"

//     script:
//     """
//     mkdir -p plots
//     Rscript /pipeline/bin/analysis_plots.R \
//         ${stats_rds} \
//         plots
//     """
// }

// process STEP3_SIGNATURES {
//     tag "step3_signatures"
//     publishDir "${params.outdir}", mode: "copy"

//     input:
//     path stats_rds

//     output:
//     path "signatures"

//     script:
//     """
//     mkdir -p signatures
//     Rscript /pipeline/bin/analysis_signatures.R \
//         ${stats_rds} \
//         signatures
//     """
// }

// process STEP4_HTML_REPORT {
//     tag "step4_html"
//     publishDir "${params.outdir}", mode: "copy"

//     input:
//     path summary_tsv
//     path plots
//     path signatures

//     output:
//     path "report.html"

//     script:
//     """
//     Rscript /pipeline/bin/generate_html_report.R \
//         ${summary_tsv} \
//         ${plots} \
//         ${signatures} \
//         report.html
//     """
// }

// workflow.onComplete {
//     println "pipeline complete"
// }

///////////////////////////// separation

// nextflow.enable.dsl=2

// params.maf_dir = params.maf_dir ?: "data/all_maf_flat"
// params.outdir  = params.outdir  ?: "results"

// workflow {

//     // container sees host project at /pipeline because we mounted pipeline/bin
//     def container_maf_dir = "/pipeline/${params.maf_dir}"

//     println "[NF] Host directory:      ${params.maf_dir}"
//     println "[NF] Container directory: ${container_maf_dir}"

//     merged = COMBINE_MAFS(container_maf_dir)
//     MAFTOOLS_ANALYSIS(merged)
// }

// process COMBINE_MAFS {
//     tag "combine"
//     publishDir "${params.outdir}", mode: "copy"

//     input:
//     val maf_dir

//     output:
//     path "merged.maf"

//     script:
//     """
//     echo "[NF] Combining all MAFs in: ${maf_dir}"
//     ls -l ${maf_dir} | head || true

//     Rscript /pipeline/bin/combine_mafs.R \
//         ${maf_dir} \
//         merged.maf
//     """
// }

// process MAFTOOLS_ANALYSIS {
//     tag "maftools"
//     publishDir "${params.outdir}", mode: "copy"

//     input:
//     path merged_maf

//     output:
//     path "plots"
//     path "report.html"

//     script:
//     """
//     mkdir -p plots

//     Rscript /pipeline/bin/maftools_analysis.R \
//         ${merged_maf} \
//         plots \
//         report.html
//     """
// }

// workflow.onComplete {
//     println "pipeline complete"
// }
