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

    # Extract the top hit from the ssearch result
    top_hit=$(awk 'NR==1 {print $2}' results/ITS/$base.SSEARCH.tab)

    echo "Processing $genome_file, top hit: $top_hit"

    # Extract the sequence corresponding to the top hit
    samtools faidx $genome_file $top_hit > results/ITSx/$base/ITS_scaffolds.fasta

    ITSx -i results/ITSx/$base/ITS_scaffolds.fasta -t F -o results/ITSx/$base/ITSx

    perl -i -p -e "s/>/>${base}_/" results/ITSx/$base/ITSx.full.fasta
    
done
