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
rm -rf irradiated
rm -rf __irradiated.mro
rm -rf normal
cd data
rm -rf normal
rm -rf C05.bam.1
curl -n 2 -P 4 -O https://sra-pub-src-1.s3.amazonaws.com/SRR7611046/C05.bam.1

#### [2/5] Load required packages
echo "[2/5] Load required packages"
module load CellRanger/7.2.0

#### [3/5] Convert BAM to FASTQ
echo "[3/5] Convert BAM to FASTQ"
cellranger bamtofastq C05.bam.1 normal

#### [4/5] Run the study
echo "[4/5] Run the study"
echo "cellranger count: normal mouse"
cd ./normal
cellranger count --id=normal \
                  --transcriptome=../refdata-gex-GRCm39-2024-A \
                  --fastqs=./indepth_C05_MissingLibrary_1_HL5G3BBXX,./indepth_C05_MissingLibrary_1_HNNWNBBXX
echo "cellranger count: irradiated mouse"
cd ../irradiated
cellranger count --id=irradiated \
                  --transcriptome=../data/refdata-gex-GRCm39-2024-A \
                  --fastqs=./indepth_C07_MissingLibrary_1_HL5G3BBXX,./indepth_C07_MissingLibrary_1_HNNWNBBXX

echo "moving outs dirs"
cd ../../
mv ./data/normal/outs normal_outs
mv ./data/irradiated/outs irradiated_outs

echo "cellranger aggr"
cellranger aggr --id=aggr --csv=libraries.csv


#### [5/5] Compress files
echo "[5/5] Compress files"
tar czvf example-results.tar.gz . --exclude=data

# Results should be available at example-results.tar.gz

echo "Script finished at: $(date)"

##################################
# END OF SCRIPT TO RUN
##################################


