#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --job-name="download_data"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=1G
#SBATCH --partition=pibu_el8
#SBATCH --output=../logs/%x_%j.out
#SBATCH --error=../logs/%x_%j.err

# Stop at the first error
set -euo pipefail

# Settings
PROJECT_DIR=/data/users/jarcila/rna_course
READS_DIR=/data/courses/rnaseq_course/toxoplasma_de/reads_Lung
DEST_DIR=${PROJECT_DIR}/raw_data

# Make sure every directory exists
mkdir -p "${PROJECT_DIR}/logs" "${PROJECT_DIR}/raw_data"

# Download reads
ln -s ${READS_DIR} ${DEST_DIR}