#!/usr/bin/bash -l
#SBATCH -p short -N 1 -c 32 --mem 8gb --out logs/search.%A.log 

CPU=8

module load fasta
module load parallel
mkdir -p results/LSU
Q=query/LSU.fa
parallel -j $CPU ssearch36 -E 1e-5 -m 8c $Q {} \> results/LSU/{/.}.SSEARCH.tab ::: $(ls genomes/*.fasta genomes/*.fna)
