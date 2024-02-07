#!/usr/bin/bash -l
#SBATCH -p short -c 16 -N 1 -n 1 --mem 24gb --out logs/single_loci_trees.%A.log

module load mafft
module load fasttree
module load iqtree
module load clipkit
module load seqtk

outdir_LSU="aln_LSU"
outdir_ITS="aln_ITS"
indir_LSU="results/LSU"
indir_ITS="results/ITSx"
LSU_filename="LSU_scaffolds.fasta"
ITS_filename="ITSx.full.fasta"
LSU_library="lib/Rhodo_LSU.fasta"
ITS_library="lib/Rhodo_ITS.fasta"
outgroup="lib/sporobolomyces_roseus_LSU.fasta"

mkdir -p "$outdir_LSU"
mkdir -p "$outdir_ITS"

# Alignment
for genome_file in genomes/*.fasta genomes/*.fna; do
    base=$(basename -- "$genome_file")
    base="${base%.*}"

    # LSU
    infile_LSU="$indir_LSU/$base/$LSU_filename"
    outfile_LSU="$outdir_LSU/${base}_LSU_rev.fas"

    # Change header in LSU to $base with underscores replaced by spaces
    sed "s/>.*/>${base//_/ }/" "$infile_LSU" > "$outdir_LSU/LSU_intermediate.fa"
    
    # Reverse complement the LSU sequence
    seqtk seq -r "$outdir_LSU/LSU_intermediate.fa" > "$outfile_LSU"
    
    rm "$outdir_LSU/LSU_intermediate.fa"
    
    # ITS
    infile_ITS="$indir_ITS/$base/$ITS_filename"
    outfile_ITS="$outdir_ITS/${base}_ITS_full.fas"

    # Change header in ITSx.full.fasta to $base with underscores replaced by spaces
    sed "s/>.*/>${base//_/ }/" "$infile_ITS" > "$outfile_ITS"

done

# LSU concatenation and alignment
cat "$outdir_LSU"/*.fas "$LSU_library" "$outgroup" > "$outdir_LSU/ALL_LSU.fas"
mafft "$outdir_LSU/ALL_LSU.fas" > "$outdir_LSU/ALL_LSU_full.fasaln"
clipkit "$outdir_LSU/ALL_LSU_full.fasaln"

iqtree2 -nt AUTO -s "$outdir_LSU/ALL_LSU_full.fasaln.clipkit" -alrt 1000 -bb 1000 -m MFP

# ITS concatenation and alignment
cat "$outdir_ITS"/*.fas "$ITS_library" "$outgroup" > "$outdir_ITS/ALL_ITS.fas"
mafft "$outdir_ITS/ALL_ITS.fas" > "$outdir_ITS/ALL_ITS_full.fasaln"
clipkit "$outdir_ITS/ALL_ITS_full.fasaln"

iqtree2 -nt AUTO -s "$outdir_ITS/ALL_ITS_full.fasaln.clipkit" -alrt 1000 -bb 1000 -m MFP