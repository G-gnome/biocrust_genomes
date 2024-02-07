#!/bin/bash -l
#SBATCH --nodes=1 --ntasks=8 --mem=16G --time=24:00:00 --output=logs/busco.%a.log -J busco

# This generates summary BUSCO for the genome assemblies
# This expects to be run as slurm array jobs where the number passed into the array corresponds
# to the line in the samples.csv file

module load busco

# For Augustus training
export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config

CPU=${SLURM_CPUS_ON_NODE}
N=${SLURM_ARRAY_TASK_ID}

if [ -z "$CPU" ]; then
    CPU=2
fi

if [ -z "$N" ]; then
    N=$1
    if [ -z "$N" ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi

if [ -z "${SLURM_ARRAY_JOB_ID}" ]; then
    SLURM_ARRAY_JOB_ID=$$
fi

GENOMEFOLDER=genomes
EXT=sorted.fasta
BUSCODB=/srv/projects/db/BUSCO/v10/
LINEAGE_DB=$BUSCODB/lineages/fungi_odb10
OUTFOLDER=BUSCO
TEMP=/scratch/${SLURM_ARRAY_JOB_ID}_${N}
mkdir -p "$TEMP"

SAMPLEFILE=samples.csv
NAME=$(awk -F',' -v n="$N" 'NR==n {print $1}' "$SAMPLEFILE")
NAME=$(tail -n +2 $SAMPLEFILE | sed -n ${N}p  | cut -d, -f1)
GENOMEFILE=$(realpath "$GENOMEFOLDER/${NAME}.${EXT}")
LINEAGE=$(realpath "$LINEAGE_DB")
# this is the closest Rhodotorula install in the folder however
SPECIES=rhodotorula_graminis_nrrl_y-2474
mkdir -p "$OUTFOLDER"

tail -n +2 "$SAMPLEFILE" | sed -n "${N}p" | while IFS=',' read BASE PHYLUM SEED_SPECIES; do
    if [ -d "$OUTFOLDER/run_${NAME}" ]; then
        echo "Already have run $NAME in folder busco - do you need to delete it to rerun?"
        exit
    else
        pushd "$OUTFOLDER"
        busco -i "$GENOMEFILE" -l "$LINEAGE" -o "$NAME" -m geno --cpu "$CPU"  --scaffold_composition --offline 
        popd
    fi
done

rm -rf "$TEMP"