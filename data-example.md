# Analyze scRNA-Seq Data From a Publication Using 10x Software
Based on [official tutorial](https://www.10xgenomics.com/support/software/cell-ranger/latest/tutorials/cr-tutorial-gex-analysis-nature-publication)

## bam files on hercules
### Option A: download to computer and move via ssh
[SRR7611046](https://trace.ncbi.nlm.nih.gov/Traces/index.html?run=SRR7611046) bam file downloadable [here](https://sra-pub-src-1.s3.amazonaws.com/SRR7611046/C05.bam.1)

[SRR7611048](https://trace.ncbi.nlm.nih.gov/Traces/index.html?run=SRR7611048) bam file downloadable [here](https://sra-pub-src-1.s3.amazonaws.com/SRR7611048/C07.bam.1)

```
scp /path/to/file username@a:/path/to/destination
```

## Option B: Download directly on hercules
1. Connect to hercules
2. Start a interactive session
```
salloc --mem=16G -c 4 -t 06:00:00 -p standard srun --pty /bin/bash -i
```
3. Move to the dir where you want to download the data
4. Download using curl:
```
curl https://sra-pub-src-1.s3.amazonaws.com/SRR7611046/C05.bam.1
```
```
curl https://sra-pub-src-1.s3.amazonaws.com/SRR7611048/C07.bam.1
```
o usand wget:
```
wget https://sra-pub-src-1.s3.amazonaws.com/SRR7611046/C05.bam.1 && wget https://sra-pub-src-1.s3.amazonaws.com/SRR7611048/C07.bam.1
```

## Convert BAM to FASTQ
1. Load the package:
```
module aval
module load <name-cell-ranger-version>
```
> bamtofastq is available for Linux and is compatible with RedHat/CentOS 5.2 or later, and Ubuntu 8.04 or later.
> 
> bamtofastq comes pre-bundled with the latest versions of the Cell Ranger, Cell Ranger ARC, Cell Ranger ATAC, and Space Ranger pipelines. You can find the executable in the /lib/bin folder within the installation, e.g. cellranger-x.y.z/lib/bin/bamtofastq. Once your pipeline is installed and on your PATH, you can run [pipeline] bamtofastq, (e.g. cellranger bamtofastq, spaceranger bamtofastq).
> 
> [Official doc of bamtofastq](https://www.10xgenomics.com/support/software/cell-ranger/latest/miscellaneous/cr-bamtofastq)
2. Run the command
```
bamtofastq C05.bam.1 normal
bamtofastq C07.bam.1 irradiated
```

## `cellranger count`
1. Run the command
```
cd ./normal/
cellranger count --id=normal \
                  --transcriptome=/path/to/refdata-cellranger-mm10-3.0.0 \
                  --fastqs=./indepth_C05_MissingLibrary_1_HL5G3BBXX,./indepth_C05_MissingLibrary_1_HNNWNBBXX
```
Where is `/path/to/refdata-cellranger-mm10-3.0.0`? It should be available at [10xgenomics download page](https://www.10xgenomics.com/support/software/cell-ranger/downloads#reference-downloads).

repeat with the irradiated mouse

```
cd ./irradiated/
cellranger count --id=irradiated \
                  --transcriptome=/path/to/refdata-cellranger-mm10-3.0.0 \
                  --fastqs=./indepth_C07_MissingLibrary_1_HL5G3BBXX,./indepth_C07_MissingLibrary_1_HNNWNBBXX
```

## Copy the results
Results are saved in the `out` dir. 
1. Compress the dir
```
tar -czvf one-step-from-nobel.tar.gz ./out
```
2. Connect with scp, you can use a client like [WinSCP](https://winscp.net)
