#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --job-name="hisat2_mapping"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --partition=pibu_el8
#SBATCH --output=../logs/%x_%j.out
#SBATCH --error=../logs/%x_%j.err

# Stop at the first error
set -euo pipefail

# Settings
PROJECT_DIR=/data/users/jarcila/rna_course
INDEX_BASENAME=${PROJECT_DIR}/reference_genome/hisat2_index
READS_DIR=${PROJECT_DIR}/raw_data
OUTPUT_DIR=${PROJECT_DIR}/results/mapping/unsorted_bam
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif

# Make sure every directory exists
mkdir -p "${OUTPUT_DIR}"

# Get sample corresponding to the array task
R1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${READS_DIR}/samples.txt")

if [[ -z ${R1} || ! -f ${R1} ]]; then
    echo "ERROR: File not found: ${R1}"
    exit 1
fi

# Find corresponding R2
R2="${R1/_1.fastq.gz/_2.fastq.gz}"

if [[ ! -f "$R2" ]]; then
    echo "ERROR: File not found: ${R2}"
    exit 1
fi

# Extract sample name
SAMPLE=$(basename "${R1}" _1.fastq.gz)
UNSORTED_BAM="${OUTPUT_DIR}/${SAMPLE}_unsorted.bam"

# HISAT2 mapping + SAM to BAM conversion
apptainer exec ${CONTAINER} hisat2 \
-p ${SLURM_CPUS_PER_TASK} \
-x ${INDEX_BASENAME} \
-1 "$R1" -2 "$R2" \
--rna-strandedness RF | \
apptainer exec ${CONTAINER} samtools view -bs - > "${UNSORTED_BAM}" 