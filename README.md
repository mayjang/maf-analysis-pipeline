# TCGA-BLCA Somatic Mutation Analysis Pipeline  
A reproducible Nextflow workflow

---

## **Overview**

This repository contains an automated somatic mutation analysis workflow for the TCGA Bladder Urothelial Carcinoma (BLCA) dataset. It processes Mutation Annotation Format (MAF) files, summarizes mutation statistics, generates maftools plots, and produces a polished HTML report.

The pipeline is designed for reproducibility, modular analysis, and separation of steps using Nextflow.

---

# **Workflow background**

Bladder cancer is characterized by high mutational burden and well known driver events such as TP53, FGFR3, and KDM6A. Large scale datasets like TCGA provide rich somatic mutation data, however:

- Raw GDC downloads contain nested folders,  
- Files may be compressed (`.maf.gz`) or in mixed formats,  
- Manual merging is prone to error and difficult to reproduce,  
- Visualization requires multiple maftools commands,  
- Researchers need an end-to-end analysis pipeline.

This workflow solves these issues by providing:

- MAF merging into one multi-MAF for analysis
- Modular analysis steps using maftools in R
- A HTML report with embedded plots  
- Containerized execution for reproducibility

Hypothesis:
- Somatic mutations in the TCGA BLCA cohort are expected to be dominated by single nucleotide variants (SNVs) and missense mutations. These missense mutations will be enriched in known bladder cancer driver genes (ex. TP53, FGFR3, KDM6A, PIK3CA, ARID1A, RB1), reflecting selective pressure on protein coding changes that alter gene function while preserving basic protein structure. By analyzing all BLCA MAF files, we expect to see a characteristic pattern of recurrently mutated genes and a mutation classification profile in which missense mutations represent the largest proportion of coding variants.

Aim:
- To build a reproducible, containerized Nextflow pipeline that quantifies and visualizes the mutation spectrum, with a particular focus on:
  - the relative burden of missense mutations compared to other variant classes, and
  - the distribution of these mutations across recurrently altered genes in TCGA BLCA.

---

# **Dataset: already preprocessed using: `bin/flatten_mafs.py`**

- Format: Mutation Annotation Format (MAF) files
- Source: GDC Data Portal Project - TCGA-BLCA
  - https://portal.gdc.cancer.gov
  - downloaded mutation annotation files from GDC data portal for 408 cases with 415 maf files of bladder cancer dataset that are open access and of tumour tissue type

This preprocessing step has resulted in:

- Extracting only `.maf` files from nested structure of raw gdc_download folder (not in github repo due to size limit)
- Removed `.maf.gz`  
- Flattend all valid MAFs into one directory:

```
data/all_maf_flat/
```

- for the purpose of this project, only 17 MAF files were kept under data/all_maf_flat folder due to files exceeding the github size limit
- the 17 MAF files were kept at random in order to avoid bias under the data/all_maf_flat/ directory (input for the pipeline)

---

# **Pipeline Overview**

The following steps are performed in this pipeline:

* The preprocessed mutation files under data/all_maf_flat/ are merged into a single multi-sample MAF file using the `maftools::merge_mafs()` function and generated under results/merged_maf. This step ensures that downstream mutation analysis is performed cohesively across the BLCA samples.

* The merged MAF file is then loaded and annotated using `maftools::read.maf()`, which computes key cohort statistics such as the total number of variants, mutated genes, and tumor samples.

* Multiple maftools visualizations is generated, including variant classifications, variant types, mutation burdens, frequently mutated genes, Ti/Tv spectra, oncoplots, and genome wide rainfall plots. These plots provide a detailed overview of mutation characteristics across the BLCA cohort and generated under results/plots/.

* All summary metrics and visualizations are compiled into a complete HTML report. The report embeds every plot directly (using Base64), producing a clean, standalone document that requires no external files and fully summarizes the mutation landscape of TCGA BLCA and generated under results/report.html.

---

# **Workflow Diagram**


<img width="960" height="540" alt="Untitled presentation" src="https://github.com/user-attachments/assets/f06675a3-7591-483d-bc90-b21e1a5e35e8" />


---

# **Environment**

* Nextflow: 25.10.1 build 10547
* openjdk: 17.0.10
* Docker: 24.0.6, build ed223bc
* python: 3.14.0
* R: 4.5.1
  * maftools: 2.26.0
  * ggplot2: 4.0.0
  * dplyr: 1.1.4
  * readr: 2.1.5
  * tidyverse: 2.0.0
  * data.table: 1.17.8
  * optparse: 1.7.5
  * R.utils: 2.13.0
  * BiocManager: 3.22
  * base64enc: 0.1.3

---

# **Docker Setup**

Please confirm that Docker is active in the background and that your working directory is set to the project folder before executing any Nextflow commands!
Once confirmed, begin by building the dockerfile using one of the following commands:

**Standard build:**:

```bash
docker build -t tcga-maftools-blca-fixed:latest .
```

**For M1/M2/M3 Macs:**

```bash
docker buildx build --platform linux/amd64     -t tcga-maftools-blca-fixed:latest .
```

---

# **Run the Pipeline**

```bash
nextflow run main.nf -profile docker
```
In the nextflow.config, the parameters are already set to the relative directories:
```bash
params {
    maf_dir = "data/all_maf_flat"   
    outdir  = "results"
}
```
### `maf_dir`

* **Purpose:** Specifies the directory containing the input MAF files.
* **Default:** `data/all_maf_flat`
* **Details:**
  This directory should only contain `.maf` files (can be produced by `flatten_mafs.py`)
  The pipeline will read every MAF file in this folder and pass them to the `COMBINE_MAFS` process for merging.

### `outdir`

* **Purpose:** The output directory where all pipeline results will be written.
* **Default:** `results`
* **Details:**
  Nextflow will store:

  * `merged.maf`
  * `intermediate.rds`
  * `summary.tsv`
  * all generated `plots/`
  * `report.html`
---

# **Expected Outputs (can be found under `expected_results`) contain:**

### **plots/**  
Includes all maftools plots:
- Variant classification
- Variant type
- Mutation burden curve
- Top 40 samples
- Top 30 genes
- Ti/Tv spectrum
- Sample summary dashboard
- Oncoplot
- Rainfall plot
- Aggregated rainfall

### **summary.tsv**  
Contains mutation counts and gene/sample statistics

### **report.html**  
HTML report with embedded plots

--- 
# **Citations for Tools Used**

P. Di Tommaso, et al. Nextflow enables reproducible computational workflows. Nature Biotechnology 35, 316–319 (2017) doi:10.1038/nbt.3820
Merkel, D. (2014). Docker: lightweight Linux containers for consistent development and deployment. Linux Journal, 2014(239), 2.
Mayakonda A, Lin DC, Assenov Y, Plass C, Koeffler HP. 2018. Maftools: efficient and comprehensive analysis of somatic variants in cancer. Genome Research. PMID: 30341162

