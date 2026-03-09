#!/bin/bash

# ===============================================
# MultiOmic Breast Cancer Project
# Genomic Variant Calling Pipeline
# ===============================================

# * Download raw sequencing data *
# Example: download FASTQ from ENA using wget
# wget -O data/raw/sample1_R1.fastq.gz "https://www.ebi.ac.uk/ena/browser/api/fastq/PRJNAxxxx?download=true"
# wget -O data/raw/sample1_R2.fastq.gz "https://www.ebi.ac.uk/ena/browser/api/fastq/PRJNAxxxx?download=true"

# * Initial Quality Control *
# FastQC per sample
fastqc -o results/qc/ data/raw/*.fastq.gz

# Combine QC reports
multiqc results/qc/ -o results/qc/

# * Adapter trimming / preprocessing *
# Using Trimmomatic as an example
# Paired-end trimming
trimmomatic PE \
  -threads 4 \
  data/raw/sample1_R1.fastq.gz data/raw/sample1_R2.fastq.gz \
  results/tmp_trimmed/sample1_R1_paired.fastq.gz results/tmp_trimmed/sample1_R1_unpaired.fastq.gz \
  results/tmp_trimmed/sample1_R2_paired.fastq.gz results/tmp_trimmed/sample1_R2_unpaired.fastq.gz \
  ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# Quality check of trimmed reads
fastqc -o results/qc/ results/tmp_trimmed/*.fastq.gz
multiqc results/qc/ -o results/qc/

# * Alignment with BWA *
# Index reference genome
# bwa index data/reference/hg38.fa

# Align paired-end reads
bwa mem -t 4 data/reference/hg38.fa \
  results/tmp_trimmed/sample1_R1_paired.fastq.gz \
  results/tmp_trimmed/sample1_R2_paired.fastq.gz \
  > results/bwa_alignments/sample1.sam

# Convert SAM to BAM, sort, and index
samtools view -Sb results/bwa_alignments/sample1.sam | samtools sort -o results/bwa_alignments/sample1_sorted.bam
samtools index results/bwa_alignments/sample1_sorted.bam

# * Variant Calling *
# Using bcftools as an example
bcftools mpileup -f data/reference/hg38.fa results/bwa_alignments/sample1_sorted.bam | \
  bcftools call -mv -Oz -o results/variants/sample1_raw.vcf.gz

# Index VCF
bcftools index results/variants/sample1_raw.vcf.gz

