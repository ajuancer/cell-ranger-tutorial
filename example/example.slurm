#!/bin/bash

# SLURM job script

##################################
# CONFIG
##################################

# Parameters for allocating resources
#SBATCH --chdir=/path/to/your/dir     # CHANGE THIS!!!!
#SBATCH --cpus-per-task=16              # same as -c
#SBATCH --mem=128G
#SBATCH --time=48:00:00
#SBATCH --partition standard            # same as -p

# Other job parameters
#SBATCH --job-name=example-run
#SBATCH --output=example-run-%j.out     # %j placeholder is replaced with job id


##################################
# START OF SCRIPT TO RUN
##################################
echo "SLURM DATA"
echo "Job ID: ${SLURM_JOBID}"
echo "Job Name: ${SLURM_JOB_NAME}"
echo "Node List: ${SLURM_NODELIST}"
echo "Number of tasks: ${SLURM_NTASKS}"
echo "CPUs per task: ${SLURM_CPUS_PER_TASK}"
echo "Memory per CPU: ${SLURM_MEM_PER_CPU}"
echo "Job Partition: ${SLURM_JOB_PARTITION}"
echo "Script started at: $(date)"

#### [1/5] Prepare the data
echo "[1/5] Prepare the data"
mkdir -p data
cd data

# Download files in the urls.txt file
# -n 2 and -P 4 to speed up the process
cat ../urls.txt
xargs -n 2 -P 4 curl -O < ../urls.txt

# Extract and delete compressed files
for file in *.tar.gz; do
    echo "File $(file) will be extracted and deleted"
    tar -xzf "$file"
    rm "$file"
done

#### [2/5] Load required packages
echo "[2/5] Load required packages"
module load CellRanger/7.2.0

#### [3/5] Convert BAM to FASTQ
echo "[3/5] Convert BAM to FASTQ"
cellranger bamtofastq C05.bam.1 normal
cellranger bamtofastq C07.bam.1 irradiated
# we should optimize removing prev file

#### [4/5] Run the study
echo "[4/5] Run the study"
cd ..
cellranger count --id=normal \
                  --transcriptome=./data/refdata-gex-GRCm39-2024-A \
                  --fastqs=./data/normal/indepth_C05_MissingLibrary_1_HL5G3BBXX,./data/normal/indepth_C05_MissingLibrary_1_HNNWNBBXX
mv outs normal_outs                     # view note 1

cellranger count --id=irradiated \
                  --transcriptome=./data/refdata-gex-GRCm39-2024-A \
                  --fastqs=./data/irradiated/indepth_C07_MissingLibrary_1_HL5G3BBXX,./data/irradiated/indepth_C07_MissingLibrary_1_HNNWNBBXX
mv outs irradiated_outs                 # view note 1

# note 1: outs dir not specified in documentation
ls . -print > files_after_count.txt
mv ./data/normal/outs normal_outs
mv ./data/irradiated/outs irradiated_outs

# the following line is not included in the data-example
# regardless of the original location of outs,
# they should now be in "example/normal_outs" and "example/irradiated_outs".
# these routes are written in libraries.csv
cellranger aggr --id=aggr --csv=libraries.csv

# debugging porpuses
ls . -print > files_after_aggr.txt

#### [5/5] Compress files
echo "[5/5] Compress files"
tar czvf example-results.tar.gz . --exclude=data

# Results should be available at example-results.tar.gz

##################################
# END OF SCRIPT TO RUN
##################################


