# Infering population structure via ADMIXTURE

By Ashley Sendell-Price

#

## ITRODUCTION
This Github repository provides scripts and a step-by-step guide for running ADMIXTURE - a tool to estimate individual ancestry from single nucletotide polymorphism (SNP) data sets. 

ADMIXTURE normally requires input in binary PLINK (.bed), ordinary PLINK (.ped), or EIGENSTRAT (.geno) formatted files. However, in this guide we make use of Steve Mussmann's Admixure pipeline (https://github.com/stevemussmann/admixturePipeline) which accepts a single VCF as the input format. This GitHub repository also provides necessary commands to summarise Admixure output across runs, and R code to plot results.

## STEP 1: Installing dependencies
The following programs (plus Steve Mussmann's Admixture pipeline) are required to perform analyses:
1. admixture
2. plink
3. vcftools
4. Tabix

In command line run the following commands to install dependencies:
(Note: requires Miniconda to be installed on your computer - see [here](https://docs.conda.io/projects/continuumio-conda/en/latest/user-guide/install/macos.html)

```bash
#install programmes using Miniconda
conda install -c bioconda admixture
conda install -c bioconda plink
conda install -c bioconda vcftools
conda install -c bioconda tabix
conda install -c anaconda git

#Clone steve Mussmann's GitHub repository
git clone https://github.com/stevemussmann/admixturePipeline
```


## STEP 2: Checking input VCF and creating PopMap file
Steve Mussmann's Admixture pipeline requires a **single** VCF file containing all indiviudals. If you have seperate VCF files for individuals you will need to merge these. VCF file merging can be conducted with 





```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --array=1-187:1
#SBATCH --job-name=snp-array
#SBATCH --output=snp-array.log
#SBATCH --error=snp-array.error
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=ashley.sendell-price@zoo.ox.ac.uk

module load java/1.8.0

```
