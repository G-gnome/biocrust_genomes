#!/usr/bin/bash -l
#SBATCH -p short -N 1 -c 32 --mem 8gb --out logs/search.%A.log 

CPU=8

module load fasta
module load parallel
TARGET=ITS
mkdir -p results/$TARGET
Q=query/$TARGET.fa
parallel -j $CPU ssearch36 -E 1e-3 -m 8c $Q {} \> results/$TARGET/{/.}.SSEARCH.tab ::: $(ls genomes/*.fasta)
