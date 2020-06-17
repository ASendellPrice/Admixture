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
5. bcftools

In command line run the following commands to install dependencies:
(Note: requires Miniconda to be installed on your computer - see [here](https://docs.conda.io/projects/continuumio-conda/en/latest/user-guide/install/macos.html))

```bash
#install programmes using Miniconda
conda install -c bioconda admixture
conda install -c bioconda plink
conda install -c bioconda vcftools
conda install -c bioconda tabix
conda install -c bioconda bcftools
conda install -c anaconda git

#Clone steve Mussmann's GitHub repository
git clone https://github.com/stevemussmann/admixturePipeline

wget 
```


## STEP 2: Checking input VCF and creating PopMap file
Steve Mussmann's Admixture pipeline requires a **single** VCF file containing all indiviudals. If you have seperate VCF files for individuals you will need to merge these. VCF file merging can be conducted with bcftools like so:

```bash
bcftools merge \
*.vcf \
--output Merged.vcf
```

**Note:** bcftools merge presumes that samples within each VCF file have unique names. If they don't bcftools will exit with an error message, unless the option "--force-samples" is given.

Admixure pipeline requires a file which specifes which population a given sample belongs to. This file, which we will call PopMap.txt, is a simple tab-delimited file with two columns. Column 1 specifies sample name in VCF file and column 2 specifies the samples population. Here is an example:

```bash
Sample_1  Pop_A
Sample_2  Pop_A
Sample_3  Pop_B
Sample_4  Pop_B
Sample_5  Pop_B
Sample_6  Pop_C
```

## STEP 3: Filter VCF file so that only biallelic SNPs present in all individuals are retained. 
Admixture only considers biallelic SNPs (sites where there is only one alternative allele). As data missingness can cause problems we will also remove SNPs not genotyped in all individuals. 

```bash
#Use vcftools to filter vcf file
vcftools --vcf Merged.vcf \
--min-alleles 2 \
--max-alleles 2 \
--max-missing 1 \
--recode

#Rename outputted vcf file something sensible
mv out.recode.vcf Merged_BiallelicOnly_NoMissing.vcf
```

## STEP 3: Conducting LD-filtering of VCF file
The authors of ADMIXTURE recommend avoiding SNPs with high linkage disequilibrium (LD), so we will use PLINK to remove SNPs with LD greater than 0.8 within 1Mb windows. LD filtering is conducting as follows:

```bash
#Specify VCF file name
VCF_File_prefix=Merged_BiallelicOnly_NoMissing #minus extension ".vcf"

#Annotate vcf file
#This in effect gives each SNP an identifier (Scaffold_Position) which can be later used to select loci during filtering step.
bash ./plink_pruning_prep.sh ${VCF_File_prefix}.vcf

#Convert to plink input files (bim, bed, fam)
plink --vcf ${VCF_File_prefix}_annot.vcf \
--allow-extra-chr \
--out ${VCF_File_prefix}_annot

#Filter based on LD (using 1Mb window, a 1SNP step, and an r2 threshold of 0.8 - remove loci with very high linkage)
plink --bfile ${VCF_File_prefix}_annot \
--indep-pairwise 1000 kb 1 0.8 \
--out ${VCF_File_prefix}_annot \
--allow-extra-chr


```





