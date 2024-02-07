#!/usr/bin/bash -l
#SBATCH -p short -c 16 -N 1 -n 1 --mem 24gb --out logs/tree.log

module load mafft
module load fasttree
module load iqtree
module load clipkit
mkdir -p aln_ITS

# Alignment

for genome_file in $(ls genomes/*.fasta genomes/*.fna); do
    base=$(basename -- "$genome_file")
    base="${base%.*}"

    # ITS alignment
    input_file="results/ITSx/$base/ITSx.full.fasta"
    output_file="aln_ITS/${base}_ITS_full.fas"

    # Change header in ITSx.full.fasta to $base with underscores replaced by spaces
    sed "s/>.*/>${base}/" "$input_file" > aln_ITS/ITS.fa


done

# Combine individual fastas into a single file
cat aln_ITS/*_ITS_full.fas > aln_ITS/ALL_ITS.fas
cat lib/Rhodo_ITS.fasta >> aln_ITS/ALL_ITS.fas
cat lib/sporobolomyces_roseus_ITS.fasta >> aln_ITS/ALL_ITS.fas

# Perform MAFFT alignment on the combined file
mafft aln_ITS/ALL_ITS.fas > aln_ITS/ALL_ITS.fasaln

# clipkit
clipkit aln_ITS/ALL_ITS.fasaln

# Tree build
iqtree2 -nt AUTO -s aln_ITS/ALL_ITS.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP
