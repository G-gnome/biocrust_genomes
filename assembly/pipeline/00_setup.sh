#!/bin/bash -l
#SBATCH -p batch -N 1 -n 24 --mem 64gb --out logs/setup.log

cp /bigdata/stajichlab/shared/projects/SeqData/SeqCoast/4472_202401__KianKelly_BioCrust_fungi_genomes/*.gz input

gunzip input/*

cat input/4472_3Reseq_S74_R1_001.fastq >> input/4472_3_S66_R1_001.fastq
cat input/4472_3Reseq_S74_R2_001.fastq >> input/4472_3_S66_R2_001.fastq

cat input/4472_2Reseq_S2_R1_001.fastq >> input/4472_2_S72_R1_001.fastq
cat input/4472_2Reseq_S2_R2_001.fastq >> input/4472_2_S72_R2_001.fastq

rm input/4472_3Reseq_S74_R1_001.fastq input/4472_3Reseq_S74_R2_001.fastq input/4472_2Reseq_S2_R1_001.fastq input/4472_2Reseq_S2_R2_001.fastq

mv input/4472_1_S71_R1_001.fastq input/rhodotorula_sp_vb21_R1.fastq
mv input/4472_1_S71_R2_001.fastq input/rhodotorula_sp_vb21_R2.fastq

mv input/4472_2_S72_R1_001.fastq input/coniochaeta_sp_jdc7_R1.fastq
mv input/4472_2_S72_R2_001.fastq input/coniochaeta_sp_jdc7_R2.fastq

mv input/4472_3_S66_R1_001.fastq input/exophiala_crusticola_khk47_R1.fastq
mv input/4472_3_S66_R2_001.fastq input/exophiala_crusticola_khk47_R2.fastq

gzip input/*
