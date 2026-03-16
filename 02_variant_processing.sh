#!/bin/bash

set -e
set -o pipefail

# ===============================================
# MultiOmic Breast Cancer Project
# Genomic Variant Processing
# ===============================================

# Input BAM from Script 01
INPUT_BAM="results/bwa_alignments/sample1_sorted.bam"
REFERENCE="data/reference/hg38.fa"

# Output directories
mkdir -p results/dedup
mkdir -p results/recalibration
mkdir -p results/variants
mkdir -p results/annotation
mkdir -p data/reference
mkdir -p data/vep_cache


# Reference dictionary check


if [ ! -f "data/reference/hg38.dict" ]; then
    echo "Creating genome dictionary..."
    gatk CreateSequenceDictionary \
        -R data/reference/hg38.fa \
        -O data/reference/hg38.dict
fi



# Download known variant sites if missing


KNOWN_SITES_DBSNP="data/reference/dbsnp.vcf.gz"
KNOWN_SITES_INDELS="data/reference/Mills_and_1000G_gold_standard.indels.vcf.gz"

if [ ! -f "$KNOWN_SITES_DBSNP" ]; then
    echo "Downloading dbSNP..."
    wget -O $KNOWN_SITES_DBSNP \
    https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.40.gz

    tabix -p vcf $KNOWN_SITES_DBSNP
fi

if [ ! -f "$KNOWN_SITES_INDELS" ]; then
    echo "Downloading Mills indels..."
    wget -O $KNOWN_SITES_INDELS \
    https://storage.googleapis.com/gatk-best-practices/somatic-hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

    tabix -p vcf $KNOWN_SITES_INDELS
fi



# Mark PCR duplicates


picard MarkDuplicates \
  I=$INPUT_BAM \
  O=results/dedup/sample1_dedup.bam \
  M=results/dedup/sample1_metrics.txt \
  CREATE_INDEX=true



# Base Quality Score Recalibration

gatk BaseRecalibrator \
  -R $REFERENCE \
  -I results/dedup/sample1_dedup.bam \
  --known-sites $KNOWN_SITES_DBSNP \
  --known-sites $KNOWN_SITES_INDELS \
  -O results/recalibration/sample1_recal_data.table


# Apply recalibration

gatk ApplyBQSR \
  -R $REFERENCE \
  -I results/dedup/sample1_dedup.bam \
  --bqsr-recal-file results/recalibration/sample1_recal_data.table \
  -O results/recalibration/sample1_recal.bam


# Index recalibrated BAM

samtools index results/recalibration/sample1_recal.bam



# Variant Calling

gatk HaplotypeCaller \
  -R $REFERENCE \
  -I results/recalibration/sample1_recal.bam \
  -O results/variants/sample1_raw_variants.vcf.gz \
  -ERC GVCF


# Index VCF if needed

if [ ! -f "results/variants/sample1_raw_variants.vcf.gz.tbi" ]; then
    tabix -p vcf results/variants/sample1_raw_variants.vcf.gz
fi



# Variant Filtering

gatk VariantFiltration \
  -R $REFERENCE \
  -V results/variants/sample1_raw_variants.vcf.gz \
  -O results/variants/sample1_filtered_variants.vcf.gz \
  --filter-name "QD2" --filter-expression "QD < 2.0" \
  --filter-name "FS60" --filter-expression "FS > 60.0" \
  --filter-name "MQ40" --filter-expression "MQ < 40.0"


if [ ! -f "results/variants/sample1_filtered_variants.vcf.gz.tbi" ]; then
    tabix -p vcf results/variants/sample1_filtered_variants.vcf.gz
fi


# Variant Annotation

vep \
  -i results/variants/sample1_filtered_variants.vcf.gz \
  -o results/annotation/sample1_annotated_variants.vcf \
  --cache \
  --dir_cache data/vep_cache \
  --assembly GRCh38 \
  --everything \
  --vcf


# Compress final annotated VCF

bgzip results/annotation/sample1_annotated_variants.vcf
tabix -p vcf results/annotation/sample1_annotated_variants.vcf.gz