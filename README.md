# TCGA-BLCA Somatic Mutation Analysis Pipeline  
A reproducible Nextflow + Docker + R (maftools) workflow

---

## **Overview**

This repository contains a fully automated somatic mutation analysis workflow for the TCGA Bladder Urothelial Carcinoma (BLCA) dataset. It processes Mutation Annotation Format (MAF) files, summarizes mutation statistics, generates maftools plots, and produces a polished HTML report.

The pipeline is designed for reproducibility, modular analysis, and separation of steps using Nextflow.

---

# **Workflow background**

Bladder cancer is characterized by high mutational burden and well-defined driver events (e.g., *TP53, FGFR3, KDM6A*). Large-scale datasets like TCGA provide rich somatic mutation data, but:

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

---

# **Directory Structure**

```
.
├── bin/
│   ├── combine_mafs.R
│   ├── analysis_load_and_stats.R
│   ├── analysis_plots.R
│   ├── generate_html_report.R
│   └── flatten_mafs.py
├── data/
│   └── all_maf_flat/
├── Dockerfile
├── nextflow.config
├── main.nf
└── README.md
```

---

# **(Already preprocessed) Input Preparation using: `flatten_mafs.py`**

- downloaded mutation annotation files from tcga-blca bladder cancer from 408 cases with 415 maf files that are open access and tumour tissue type
- for the purpose of this project, only 17 maf files were kept under data/all_maf_flat folder due to files exceeding the github size limit
- the 17 files were kept at random in order to avoid bias

the 415 files were already preprocessed using:

```
python3 bin/flatten_mafs.py  
```

This step has resulted in:

- Extracting only `.maf` files from nested structure of gdc_download folder
- Removed `.maf.gz`  
- Flattend all valid MAFs into one directory:

```
data/all_maf_flat/
```

This directory is the final input for the pipeline, and contains 17 MAF files.

---

# **Pipeline Overview**

```
COMBINE_MAFS  →  LOAD_STATS  →  GENERATE_PLOTS  →  GENERATE_HTML
```

HTML is generated after plots.

---

# **Workflow Diagram**


<img width="960" height="540" alt="Untitled presentation" src="https://github.com/user-attachments/assets/f06675a3-7591-483d-bc90-b21e1a5e35e8" />



---

# **Docker Setup**

Standard:

```bash
docker build -t tcga-maftools-blca-fixed:latest .
```

**For M1/M2/M3 Macs:**

```bash
docker buildx build --platform linux/amd64     -t tcga-maftools-blca-fixed:latest .
```

---

# **Running the Pipeline**

```bash
nextflow run main.nf -profile docker
```

Outputs appear in:

```
results/
```

---

# **Expected Outputs**

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
Fully embedded HTML report

=======
# maf-analysis-pipeline
TCGA BLCA somatic mutation analysis pipeline using Nextflow, R, maftools, and Docker
