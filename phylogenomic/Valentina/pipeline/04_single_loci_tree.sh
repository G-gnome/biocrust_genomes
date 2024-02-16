#!/usr/bin/bash -l
#SBATCH -p short -c 16 -N 1 -n 1 --mem 24gb --out logs/tree.%A.log

module load mafft
module load fasttree
module load iqtree
module load clipkit
module load seqtk

outdir="aln"

mkdir -p "$outdir"

iqtree2 -nt AUTO -s $outdir/aligments.fasta -alrt 1000 -bb 1000 -m MFP