#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --job-name="align_reads"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --mem=1G
#SBATCH --partition=pibu_el8
#SBATCH --output=../logs/%x_%j.out
#SBATCH --error=../logs/%x_%j.err

# Stop at the first error
set -euo pipefail

# Settings
PROJECT_DIR=/data/users/jarcila/rna_course
HELPERS=${PROJECT_DIR}/scripts/helpers

# Make sure every directory exists
mkdir -p "${PROJECT_DIR}/logs"

# Build hisat2 index for the reference genome
INDEX_JOB=$(sbatch --parsable "${HELPERS}/build_hisat2_index.sh")

# Count samples and create array 
find "${PROJECT_DIR}/raw_data" -maxdepth 1 -type f -name '*_1.fastq.gz' | sort > "${PROJECT_DIR}/raw_data/samples.txt"

N_SAMPLES=$(wc -l < "${PROJECT_DIR}/raw_data/samples.txt")

# Map reads using hisat2 once the indexing job is done
MAPPING_JOB=$(sbatch --parsable \
    --dependency=afterok:${INDEX_JOB} \
    --array=1-"${N_SAMPLES}"%5 \
    "$HELPERS/mapping.sh")

# Sort and index BAM files once the mapping job is done
sbatch --parsable \
    --dependency=afterok:$MAPPING_JOB \
    --array=1-"${N_SAMPLES}"%5 \
    "$HELPERS/process_bam.sh"