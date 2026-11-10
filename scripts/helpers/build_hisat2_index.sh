#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --job-name="hisat2_index"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=03:00:00
#SBATCH --mem=8G
#SBATCH --partition=pibu_el8
#SBATCH --output=../logs/%x_%j.out
#SBATCH --error=../logs/%x_%j.err

# Stop at the first error
set -euo pipefail

# Settings
PROJECT_DIR=/data/users/jarcila/rna_course
GENOME=${PROJECT_DIR}/reference_genome/Mus_musculus.GRCm39.dna.primary_assembly.fa
INDEX_BASENAME=${PROJECT_DIR}/reference_genome/hisat2_index
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif

# Unzip genome .gz
if [ ! -f "${GENOME}" ] && [ -f "${GENOME}.gz" ]; then
    gunzip -k "${GENOME}.gz"
fi

# Make sure it does not already exist
if [ ! -f "${INDEX_BASENAME}.1.ht2" ]; then 
    # Build all required index
    apptainer exec ${CONTAINER} hisat2-build \
        -p ${SLURM_CPUS_PER_TASK} \
        ${GENOME} \
        ${INDEX_BASENAME}
fi