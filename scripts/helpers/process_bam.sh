#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --job-name="process_bam"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --time=01:00:00
#SBATCH --mem=25G
#SBATCH --partition=pibu_el8
#SBATCH --output=../logs/%x_%j.out
#SBATCH --error=../logs/%x_%j.err

# Stop at the first error
set -euo pipefail

# Settings
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif
INPUT=results/mapping/bam
OUTPUT=results/mapping/sorted_bam

mkdir -p "$OUTPUT"

# Get sample corresponding to the array task
R1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" raw_data/samples.txt)

SAMPLE=$(basename "$R1" _1.fastq.gz)

BAM="$INPUT/${SAMPLE}.bam"
SORTED_BAM="$OUTPUT/${SAMPLE}_sorted.bam"

if [[ ! -f "$BAM" ]]; then
    echo "ERROR: BAM file not found: $BAM"
    exit 1
fi

echo "Processing sample: $SAMPLE"

# Sort BAM file
apptainer exec ${CONTAINER} samtools sort \
    -@ "$SLURM_CPUS_PER_TASK" \
    -o "$OUT_DIR/${SAMPLE}_sorted.bam"

# Index sorted BAM file
apptainer exec ${CONTAINER} samtools index "$OUT_DIR/${SAMPLE}_sorted.bam"