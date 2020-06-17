# Infering population structure via ADMIXTURE

By Ashley Sendell-Price

#

## ITRODUCTION
This Github repository provides scripts and a step-by-step guide for running ADMIXTURE - a tool to estimate individual ancestry from single nucletotide polymorphism (SNP) data sets. 

ADMIXTURE normally requires input in binary PLINK (.bed), ordinary PLINK (.ped), or EIGENSTRAT (.geno) formatted files. However, in this guide we make use of Steve Mussmann's Admixure pipeline (https://github.com/stevemussmann/admixturePipeline) which accepts a single VCF as the input format. This GitHub repository also provide necessary commands to summarise Admixure output across runs, and R code to plot results.

## STEP 1: Installing dependencies












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
