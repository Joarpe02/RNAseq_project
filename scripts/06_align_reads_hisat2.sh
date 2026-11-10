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
mkdir -p "${PROJECT_DIR}/logs" "${PROJECT_DIR}/raw_data" "${PROJECT_DIR}/results/mapping/bam"

# Build hisat2 index for the reference genome
INDEX_JOB=$(sbatch --parsable "${HELPERS}/build_hisat2_index.sh")

# 2\. Generar lista de muestras R1 find "${PROJECT\_DIR}/raw\_data" -maxdepth 1 -type f -name '\*\_1.fastq.gz' | sort &gt; "${PROJECT\_DIR}/raw\_data/samples.txt" N\_SAMPLES=$(wc -l &lt; "${PROJECT\_DIR}/raw\_data/samples.txt") if [ "$N\_SAMPLES" -eq 0 ]; then echo "ERROR: No se encontraron archivos FASTQ R1 en ${PROJECT\_DIR}/raw\_data" exit 1 fi echo "Muestras encontradas: ${N\_SAMPLES}. Lanzando trabajos de alineamiento..." # 3\. Mapear y procesar BAM directamente con dependencia del trabajo de indexación sbatch --parsable \\ --dependency=afterok:${INDEX\_JOB} \\ --array=1-"${N\_SAMPLES}"%5 \\ "${HELPERS}/mapping.sh"

# --------------------------------
# 3. Count samples and create array
# --------------------------------
find raw_data -maxdepth 1 -type f \
    -name '*_1.fastq.gz' | sort > raw_data/samples.txt

N_SAMPLES=$(wc -l < raw_data/samples.txt)

if [ "$N_SAMPLES" -eq 0 ]; then
    echo "ERROR: No FASTQ R1 files found"
    exit 1
fi

# Map reads using hisat2 once the indexing job is done
MAPPING_JOB=$(sbatch --parsable \
    --dependency=afterok:$INDEX_JOB \
    --array=1-"${N_SAMPLES}"%5 \
    "$HELPERS/mapping.sh")

# Sort and index BAM files once the mapping job is done
sbatch --parsable \
    --dependency=afterok:$MAPPING_JOB \
    --array=1-"${N_SAMPLES}"%5 \
    "$HELPERS/process_bam.sh"