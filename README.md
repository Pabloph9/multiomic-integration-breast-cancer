# MultiOmic-Integration-Breast-Cancer

## Project Overview

The objective of this project is to perform a multi-omics integration analysis of breast cancer using publicly available genomics and proteomics datasets.

Due to limitations in finding paired patient data from the same study, this project focuses on a single breast cancer cell line, MCF7, using similar experimental conditions across genomics and proteomics datasets to ensure a valid and demonstrable integration.

The goal of the integration is to unify genomic and proteomic insights to provide a more comprehensive understanding of the molecular mechanisms in breast cancer.

## Dataset Description

## Project Objectives

- Analyze genomic variants to uncover relevant mutations and potential biomarkers.

- Quantify protein abundances and identify key proteomic signatures.

- Integrate genomic and proteomic data to reveal molecular correlations and generate actionable biological insights.


## Workflow Overview

1. Genomics workflow

    - Download raw sequencing data from public repositories for the selected breast cancer cell line (MCF7).
    - Perform quality control using FastQC for individual samples and summarize results with MultiQC.
    - Trim adapters and low-quality bases using tools such as Trim Galore or Cutadapt.
    - Align reads to the reference genome.
    - Proceed to variant calling using GATK.
    - Apply base quality score recalibration, marking duplicates, and variant calling to generate VCF files.
    - Annotate variants using VEP. including application of ACMG guidelines.
    - Generate processed VCF files with annotated variants ready for downstream integration.

2. Proteomics workflow

    - Download RAW files from public repositories.
    - Organize files by sample and condition to match genomics datasets.
    - Convert RAW files to mzML or suitable formats using ProteoWizard.
    - Perform peptide identification and quantification using software such as MaxQuant, OpenMS, or MSFragger.
    - Filter and normalize protein abundance values.
    - Generate processed tables with quantified protein abundances for downstream analysis.

3. Integration workflow

    - Match genomics and proteomics data by sample or condition.
    - Combine processed VCF data with protein abundance tables into a unified dataset.
    - Perform exploratory analysis on integrated data.
    - Assess correlations between variants and protein expression.
    - Identify potential biomarkers or molecular signatures supported by both omics layers.
    - Visualize integrated results using heatmaps or scatterplots.


## Analysis Steps

## Results

## Conclusion

## Instructions for use

Place your raw or processed datasets inside the data/ folder. Metadata files for genomics and proteomics are included to guide the download and organization of raw datasets and reference files.

Run the analysis scripts individually, located in the scripts/ folder, according to your study design.

All output files, figures, and processed data will be saved in the results/ folder.

When available, the Dockerfile can be used to run the entire workflow in a reproducible environment, ensuring consistent results across platforms.


## References
