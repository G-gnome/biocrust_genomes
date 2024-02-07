#!/usr/bin/bash -l
#SBATCH -p short -c 12 --mem 24gb --out logs/ITSx_run.log

CPU=12
module load samtools
module load ITSx
mkdir -p results/ITSx

for genome_file in $(ls genomes/*.fasta genomes/*.fna); do
    base=$(basename -- "$genome_file")
    base="${base%.*}"

    mkdir -p results/ITSx/$base

    cat results/ITS/$base.SSEARCH.tab | while read QUERY TARGET PID X GAPO GAPE QS QE TS TE EVALUE SCORE; do
        samtools faidx $genome_file $TARGET
    done > results/ITSx/$base/ITS_scaffolds.fasta

    ITSx -i results/ITSx/$base/ITS_scaffolds.fasta -t F -o results/ITSx/$base/ITSx

    perl -i -p -e "s/>/>${base}_/" results/ITSx/$base/ITSx.full.fasta
done
