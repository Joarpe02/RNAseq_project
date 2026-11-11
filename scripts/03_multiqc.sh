#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --job-name="multiqcqc"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=1G
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/jarcila/rna_course/logs/%x_%j.out
#SBATCH --error=/data/users/jarcila/rna_course/logs/%x_%j.err

# Stop at the first error
set -euo pipefail

# Settings
PROJECT_DIR=/data/users/jarcila/rna_course
RESULTS_DIR=${PROJECT_DIR}/results
CONTAINER=/containers/apptainer/multiqc-1.33.sif

# Make sure every directory exists
mkdir -p "${PROJECT_DIR}/logs" "${PROJECT_DIR}/results"

# Run MultiQC
apptainer exec ${CONTAINER} multiqc ${RESULTS_DIR} -o ${RESULTS_DIR} -n multiqc.html