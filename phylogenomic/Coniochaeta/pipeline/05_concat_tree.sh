#!/usr/bin/bash -l
#SBATCH -p short -c 16 -N 1 -n 1 --mem 24gb --out logs/tree.log

module load mafft
module load fasttree
module load iqtree
module load clipkit
module load seqtk
module load phykit
mkdir -p tree

ITS=aln_ITS/ALL_ITS_full.fasaln.clipkit
ITS_out=tree/ALL_ITS_rename.fasaln.clipkit
LSU=aln_LSU/ALL_LSU_full.fasaln.clipkit
LSU_out=tree/ALL_LSU_rename.fasaln.clipkit
speciesname=Coniochaeta_JDC7


# Alignment

#note: replaces the species of interest name with speciesname variable. Works only on one species, can't do if there are multiple species of interest. 
python rename_underscore.py $ITS $ITS_out $speciesname
python rename_underscore.py $LSU $LSU_out $speciesname

phykit create_concat -a alignmentlist.txt -p concatenated_output 

mv concatenated* tree

# Tree build
iqtree2 -nt AUTO -s tree/concatenated_output.fa -alrt 1000 -bb 1000 -m MFP

