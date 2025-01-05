# MAG Snakemake Workflow


## Contents

- [Overview](#overview)
- [System Requirements](#system-requirements)
- [Workflow setup](#Workflow-setup)
- [Running pipeline](#running-pipeline)
- [CPU time](#CPU-time)
- [License](./LICENSE)
- [Issues](https://github.com/Finn-Lab/MAG_Snakemake_wf/issues)
- [Citation](#citation)

# Overview

该流程可用于从短读长、宿主相关的宏基因组数据集中恢复和质量评估原核生物的MAGs（基因组组装）。分析的数据通过两个文件进行指定，这两个文件详细说明了要分析的联合组装样本和单独运行。文件 runs.txt 包含单独运行的SRA登录号，每行一个不同的登录号。文件 coassembly_runs.txt 指定了联合组装样本。该文件采用三列表格格式，第一列指定生成的联合组装样本的名称。r1 和 r2 列分别指定构成每个联合组装样本的正向和反向读长的路径，每个读长路径以逗号分隔。在该流程中，我们使用了 Almeida 等人之前分析过的一小部分肠道数据集。共有40个单独运行和2个联合组装样本。联合组装样本的命名基于用于执行联合组装所选择的元数据。如果运行数据不公开，应该将其放置在相对于 Snakefile 的子目录 data/raw 中。正向和反向读长的扩展名必须分别为 _1.fastq 和 _2.fastq。请注意，该流程中使用的 kneaddata 版本仍然要求读长后缀为 /1 和 /2，因此头信息必须相应地格式化。如果运行数据是公开的，请在 runs.txt 文件中指定它们，sra_download 模块将使用它们的SRA登录号从SRA下载这些运行到目录 data/raw。

# System Requirements

## Hardware Requirements

HPC with at least 500 gigabytes of memory

The CPU times below are generated using the cluster config file included in the repo

## Software Requirements

MAG Snakemake pipeline (https://github.com/Finn-Lab/MAG_Snakemake_wf)

Singularity 3.5.0 (https://github.com/hpcng/singularity)

Snakemake (version 5.18) (https://github.com/snakemake/snakemake) 

Running the MAG Snakemake pipeline will automatically download the sequencing data from the SRA. It will also download the relevant singularity containers so the relevant software needed for our pipeline can be used. Alternatively, the tools can be manually downloaded from:

ncbi-genome-download (version 0.3.0) (https://github.com/kblin/ncbi-genome-download)

mash (version 2.2.1) (https://github.com/marbl/Mash)

parallel-fastq-dump (version 0.6.6) & fastq-dump (version 2.8.0) (https://github.com/rvalieris/parallel-fastq-dump)

fastqc (version 0.11.7) (https://github.com/s-andrews/FastQC)

multiqc (version 1.3) (https://github.com/ewels/MultiQC)

kneaddata (version 0.7.4) with Trimmomatic (version 0.39) & Bowtie (version 2.4.2) (https://github.com/biobakery/kneaddata)

metaSPAdes (version 3.14.0) (https://github.com/ablab/spades)

metaWRAP (version 1.2.2) (https://github.com/bxlab/metaWRAP)

CheckM (version 1.0.12) (https://github.com/Ecogenomics/CheckM)

Bowtie (version 2.4.1) (https://github.com/BenLangmead/bowtie2)

Prokka (version 1.14.5) (https://github.com/tseemann/prokka)

CMSeq (version 1.0) (https://bitbucket.org/CibioCM/cmseq)

mummer (version 3.23) (https://github.com/mummer4/mummer)

dRep (version 2.3.2) (https://github.com/MrOlm/drep)

GTDB_Tk (version 1.2.0) (https://github.com/Ecogenomics/GTDBTk)

bwa (version 0.7.17) (https://github.com/lh3/bwa)

samtools (version 1.9) (https://github.com/samtools/samtools) 

## Other

RefSeq complete bacterial genomes (downloaded May 2020) (https://www.ncbi.nlm.nih.gov/refseq/)

GTDB database (release 95) (https://data.ace.uq.edu.au/public/gtdb/data/releases/) 


# Workflow setup


Download the GTDB database using:
```
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/release95/95.0/auxillary_files/gtdbtk_r95_data.tar.gz
```

Download all RefSeq bacterial genomes using:
```
ncbi-genome-download bacteria --formats fasta --section refseq --assembly-levels complete
```
Next generate a Mash sketch of the database with default k-mer and sketch size from the main directory using:

```
mash sketch -o refseq.msh /path/to/RefSeq/*fasta
```

Download the code for the pipeline from (https://github.com/Finn-Lab/MAG_Snakemake_wf) in a location that has at least 1.5 TB of disk space. Change directory to this folder. Move the GTDB database and the RefSeq Mash sketch to the subfolder /data/databases using:

```
cd /path/to/MAG_Snakemake_wf/
mkdir -p data/databases
mv /path/to/refseq.msh data/databases
mv /path/to/gtdbtk_r95_data.tar.gz data/databases
tar -xvzf data/databases/gtdbtk_r95_data.tar.gz
```

Install snakemake into an environment using:

```
conda create -c conda-forge -c bioconda -n snakemake snakemake=5.18
```

Then activate the environment before using snakemake: 
```
conda activate snakemake
```


# Running pipeline 

### Submitting jobs

To run pipeline on the small gut dataset specified in runs.txt and coassembly_runs.txt, submit jobs with SLURM scheduler:
```
snakemake --use-singularity --restart-times 3 -k -j 50 --cluster-config clusterconfig.yaml --cluster "sbatch -n {cluster.nCPU} --mem {cluster.mem} -e {cluster.error} -o {cluster.output} -t {cluster.time}"
```

Submit jobs with LSF scheduler:
```
snakemake --use-singularity --restart-times 3 -k --jobs 50 --cluster-config clusterconfig.yaml --cluster "bsub -n {cluster.nCPU} -M {cluster.mem} -e {cluster.error} -o {cluster.output}"
```

# CPU-time

The CPU time for the demo dataset and the cluster configuration file provided is as follows:

Data Download: 16 hours

Preprocessing: 48 hours 

Assembly/Co-assembly:  2600 hours

Binning: 100 hours 

Quality Assessment & Bin Refinement; Estimate completeness and contamination of MAGs: 25 hours

Quality Assessment & Bin Refinement; Estimate strain heterogeneity of MAGs: 700 hours

Quality Assessment & Bin Refinement; Compare MAGs to RefSeq genomes: 1 hour

Quality Assessment & Bin Refinement; Bin refinement: 260 hours

Dereplicate MAGs: 4 hours

Taxonomic Classification: 3 hours

Evaluate Bottlenecks: 120 hours




# Citation
For a walk-through of this pipeline, please visit: 
Saheb Kashaf, S., Almeida, A., Segre, J.A. et al. Recovering prokaryotic genomes from host-associated, short-read shotgun metagenomic sequencing data. Nat Protoc (2021). https://doi.org/10.1038/s41596-021-00508-2

To generate results from the paper associated with this pipeline, please select a figure to reproduce in the Snakefile.



