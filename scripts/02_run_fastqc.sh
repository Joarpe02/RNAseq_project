#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --job-name="fastqc"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=1G
#SBATCH --partition=pibu_el8
#SBATCH --array=1-30%5
#SBATCH --output=../logs/%x_%j.out
#SBATCH --error=../logs/%x_%j.err

# Stop at the first error
set -euo pipefail

# Settings
PROJECT_DIR=/data/users/jarcila/rna_course
RESULTS_DIR=${PROJECT_DIR}/results
READS_DIR=${PROJECT_DIR}/raw_data
FILES=(${READS_DIR}/*.fastq.gz)
CONTAINER=/containers/apptainer/fastqc-0.12.1.sif

# Make sure every directory exists
mkdir -p "${PROJECT_DIR}/logs" "${PROJECT_DIR}/raw_data" "${PROJECT_DIR}/results"

# Check quality of the data with fastqc
FILE=${FILES[${SLURM_ARRAY_TASK_ID}-1]}
apptainer exec ${CONTAINER} fastqc -t ${SLURM_CPUS_PER_TASK} -o ${RESULTS_DIR} ${FILE}