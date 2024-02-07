#!/usr/bin/bash -l
#SBATCH -p short -c 16 -N 1 -n 1 --mem 24gb --out logs/tree.log

module load mafft
module load fasttree
module load iqtree
module load clipkit
mkdir -p aln

# Alignment

for genome_file in $(ls genomes/*.fasta genomes/*.fna); do
    base=$(basename -- "$genome_file")
    base="${base%.*}"

    # ITS alignment
    cat results/ITSx/$base/ITSx.full.fasta > aln/${base}_ITS_full_LSU.fas

    # LSU alignment (excluding the first line)
    seqkit seq -r results/LSU/$base/LSU_scaffolds.fasta > aln/LSU_scaffolds.rev.fasta
    
    tail -n +2 aln/LSU_scaffolds.rev.fasta >> aln/${base}_ITS_full_LSU.fas

    cat lib/sporobolomyces_roseus_ITS.fasta > aln/sporobolomyces_roseus_ITS_LSU.fasta
    
    tail -n +2 lib/sporobolomyces_roseus_LSU.fasta >> aln/sporobolomyces_roseus_ITS_LSU.fasta

done

python append_sequences.py Rhodo_ITS.fasta Rhodo_LSU.fasta merge_report.txt

# Combine individual alignments into a single file
cat aln/*_ITS_full_LSU.fas > aln/ALL_ITS_full_LSU.fas
cat merged_sequences.fasta >> aln/ALL_ITS_full_LSU.fas
cat aln/sporobolomyces_roseus_ITS_LSU.fasta >> aln/ALL_ITS_full_LSU.fas

# Perform MAFFT alignment on the combined file
mafft aln/ALL_ITS_full_LSU.fas > aln/ALL_ITS_full_LSU.fasaln

# clickpit
clipkit aln/ALL_ITS_full_LSU.fasaln

# Tree build
FastTreeMP -nt -gamma aln/ALL_ITS_full_LSU.fasaln.clipkit > aln/Rhodotorula_ITS_LSU.fasaln.tre
iqtree2 -nt AUTO -s aln/ALL_ITS_full_LSU.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP
