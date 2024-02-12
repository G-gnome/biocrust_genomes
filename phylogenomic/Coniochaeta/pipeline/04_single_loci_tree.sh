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
LSU_library="lib/Conio_LSU.fasta"
ITS_library="lib/Conio_ITS.fasta"
outgroup_ITS="lib/Chaetosphaeria_ciliata_ITS.fasta"
outgroup_LSU="lib/Chaetosphaeria_ciliata_LSU.fasta"

mkdir -p "$outdir_LSU"
mkdir -p "$outdir_ITS"

# Alignment
for genome_file in genomes/*.fasta genomes/*.fna; do
    base=$(basename -- "$genome_file")
    base="${base%.*}"

    # LSU
    infile_LSU="$indir_LSU/$base/$LSU_filename"
    outfile_LSU="$outdir_LSU/$LSU_filename"
    
    cp "$infile_LSU" $outdir_LSU/intermediate.fasta
    
    # Reverse complement the LSU sequence
    seqtk seq -r $outdir_LSU/intermediate.fasta > "$outfile_LSU"
  
    
    
    # ITS
    infile_ITS="$indir_ITS/$base/$ITS_filename"
    outfile_ITS="$outdir_ITS/$ITS_filename"

    # Change header in ITSx.full.fasta to $base with underscores replaced by spaces
    cp "$infile_ITS" "$outfile_ITS"

done

# LSU concatenation and alignment
cat "$outdir_LSU/$LSU_filename" "$LSU_library" "$outgroup_LSU" > "$outdir_LSU/ALL_LSU.fas"
mafft "$outdir_LSU/ALL_LSU.fas" > "$outdir_LSU/ALL_LSU_full.fasaln"
clipkit "$outdir_LSU/ALL_LSU_full.fasaln"

iqtree2 -nt AUTO -s "$outdir_LSU/ALL_LSU_full.fasaln.clipkit" -alrt 1000 -bb 1000 -m MFP

# ITS concatenation and alignment
cat "$outdir_ITS"/"$ITS_filename" "$ITS_library" "$outgroup_ITS" > "$outdir_ITS/ALL_ITS.fas"
mafft "$outdir_ITS/ALL_ITS.fas" > "$outdir_ITS/ALL_ITS_full.fasaln"
clipkit "$outdir_ITS/ALL_ITS_full.fasaln"

iqtree2 -nt AUTO -s "$outdir_ITS/ALL_ITS_full.fasaln.clipkit" -alrt 1000 -bb 1000 -m MFP