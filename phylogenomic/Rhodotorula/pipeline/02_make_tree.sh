#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 8 --mem 8gb

module load fasttree
module load clipkit
module load mafft

mafft YAP1_ITS_all.fas > YAP1_ITS_all.fasaln
clipkit YAP1_ITS_all.fasaln
FastTreeMP -nt -gtr -gamma < YAP1_ITS_all.fasaln.clipkit > YAP1_ITS_all.FT.tre
