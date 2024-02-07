#!/usr/bin/bash -l
#SBATCH -p short -c 12 --mem 24gb --out logs/LSU_extract.log

CPU=12
module load samtools
module load barrnap

for genome_file in $(ls genomes/*.fasta genomes/*.fna); do
    base=$(basename -- "$genome_file")
    base="${base%.*}"

    mkdir -p results/LSU/$base

    # Extract the top hit from the ssearch result
    top_hit=$(awk 'NR==1 {print $2}' results/LSU/$base.SSEARCH.tab)

    echo "Processing $genome_file, top hit: $top_hit"

    # Extract the sequence corresponding to the top hit
    samtools faidx $genome_file $top_hit > results/LSU/$base/LSU_scaffolds.fasta

    perl -i -p -e "s/>/>${base}_/" results/LSU/$base/rrna.fasta

done
