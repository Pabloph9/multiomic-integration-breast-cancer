#!/bin/bash

set -e
set -o pipefail

# ===============================================
# MultiOmic Breast Cancer Project
# Genomic Variant Calling
# ===============================================

# * Create directories if they don't exist *

mkdir -p data/raw
mkdir -p data/reference
mkdir -p results/qc
mkdir -p results/tmp_trimmed
mkdir -p results/bwa_alignments



# Reference Genome

REFERENCE="data/reference/hg38.fa"

# Download reference genome if not exist
if [ ! -f "$REFERENCE" ]; then
    echo "Reference genome not found. Downloading hg38..."

    wget -O data/reference/hg38.fa.gz \
    https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/GRCh38.primary_assembly.genome.fa.gz

    gunzip data/reference/hg38.fa.gz
fi

# Index genome for BWA if needed
if [ ! -f "data/reference/hg38.fa.bwt" ]; then
    echo "Indexing reference genome with BWA..."
    bwa index data/reference/hg38.fa
fi

# Index genome for samtools if needed
if [ ! -f "data/reference/hg38.fa.fai" ]; then
    echo "Indexing reference genome with samtools..."
    samtools faidx data/reference/hg38.fa
fi



# Download raw sequencing data

# wget -O data/raw/sample1_R1.fastq.gz "https://www.ebi.ac.uk/ena/browser/api/fastq/PRJNAxxxx?download=true"
# wget -O data/raw/sample1_R2.fastq.gz "https://www.ebi.ac.uk/ena/browser/api/fastq/PRJNAxxxx?download=true"



# Initial Quality Control


# FastQC per sample
fastqc -o results/qc/ data/raw/*.fastq.gz

# Combine QC reports
multiqc results/qc/ -o results/qc/



# Preprocessing


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



# Alignment with BWA


# Align paired-end reads
bwa mem -t 4 data/reference/hg38.fa \
  results/tmp_trimmed/sample1_R1_paired.fastq.gz \
  results/tmp_trimmed/sample1_R2_paired.fastq.gz \
  > results/bwa_alignments/sample1.sam



# Convert SAM to BAM, sort, and index


samtools view -Sb results/bwa_alignments/sample1.sam | \
samtools sort -o results/bwa_alignments/sample1_sorted.bam

samtools index results/bwa_alignments/sample1_sorted.bam