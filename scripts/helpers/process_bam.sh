#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --job-name="process_bam"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --time=01:00:00
#SBATCH --mem=25G
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/jarcila/rna_course/logs/%x_%j.out
#SBATCH --error=/data/users/jarcila/rna_course/logs/%x_%j.err

# Stop at the first error
set -euo pipefail

# Settings
PROJECT_DIR=/data/users/jarcila/rna_course
INPUT_DIR=${PROJECT_DIR}/results/mapping/unsorted_bam
OUTPUT_DIR=${PROJECT_DIR}/results/mapping/sorted_bam
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif

mkdir -p "${OUTPUT_DIR}"

# Get sample corresponding to the array task
R1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${PROJECT_DIR}/samples.txt")

SAMPLE=$(basename "${R1}" _1.fastq.gz)

UNSORTED_BAM="${INPUT_DIR}/${SAMPLE}_unsorted.bam"
SORTED_BAM="${OUTPUT_DIR}/${SAMPLE}_sorted.bam"

if [[ ! -f "${UNSORTED_BAM}" ]]; then
    echo "ERROR: BAM file not found: ${UNSORTED_BAM}"
    exit 1
fi

# Sort BAM file
apptainer exec ${CONTAINER} samtools sort \
    -@ "${SLURM_CPUS_PER_TASK}" \
    -o "${OUTPUT_DIR}/${SAMPLE}_sorted.bam" \
    "${UNSORTED_BAM}"

# Index sorted BAM file
apptainer exec ${CONTAINER} samtools index "${SORTED_BAM}"

# Remove temporary unsorted bam files
rm -f "${UNSORTED_BAM}"