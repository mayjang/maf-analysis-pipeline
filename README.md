<<<<<<< HEAD

# TCGA-BLCA Somatic Mutation Analysis Pipeline  
*A reproducible Nextflow + Docker + R (maftools) workflow*

---

## **Overview**

This repository contains a fully automated **somatic mutation analysis** workflow for the **TCGA Bladder Urothelial Carcinoma (BLCA)** dataset. It processes Mutation Annotation Format (MAF) files, summarizes mutation statistics, generates maftools plots, and produces a polished HTML report.

The pipeline is designed for **high reproducibility**, **modular analysis**, and **clean separation of steps** using Nextflow.

---

# **Workflow background**

Bladder cancer is characterized by high mutational burden and well-defined driver events (e.g., *TP53, FGFR3, KDM6A*). Large-scale datasets like TCGA provide rich somatic mutation data, but:

- Raw GDC downloads contain **deeply nested folders**,  
- Files may be **compressed (`.maf.gz`) or mixed formats**,  
- Manual merging is **error-prone and not reproducible**,  
- Visualization requires **multiple maftools commands**,  
- Students/researchers need a **turnkey, end-to-end analysis pipeline**.

This workflow solves these issues by providing:

- Automated preprocessing (flattening + cleaning)  
- Deterministic MAF merging  
- Modular analysis steps  
- A complete HTML report with embedded plots  
- Containerized execution for 100% reproducibility  

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
│   ├── gdc_download_20251128_235135.992686/
│   └── all_maf_flat/
├── Dockerfile
├── nextflow.config
├── main.nf
└── README.md
```

---

# **Input Preparation: `flatten_mafs.py`**

Run:

```bash
python3 bin/flatten_mafs.py     --input data/gdc_download_20251128_235135.992686     --output data/all_maf_flat
```

This step:

- Extracts only `.maf` files  
- Removes `.maf.gz`  
- Flattens all valid MAFs into one directory:

```
data/all_maf_flat/
```

This is the final input for the pipeline.

---

# **Pipeline Overview**

```
COMBINE_MAFS  →  LOAD_STATS  →  GENERATE_PLOTS  →  GENERATE_HTML
```

HTML is generated after plots.

---

# **Workflow Diagram (Oval DAG)**







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
Contains mutation counts and gene/sample statistics.

### **report.html**  
Fully embedded HTML report.

=======
# maf-analysis-pipeline
TCGA BLCA somatic mutation analysis pipeline using Nextflow, R, maftools, and Docker
>>>>>>> f58fa5dbdf5cd781dbbdcf0f89ca577c2dfef012
