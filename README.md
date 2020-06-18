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


## STEP 2: Checking input VCF
Steve Mussmann's Admixture pipeline requires a **single** VCF file containing all indiviudals. If you have seperate VCF files for individuals you will need to merge these. VCF file merging can be conducted with bcftools like so:

```bash
bcftools merge \
*.vcf \
--output Merged.vcf
```

**Note:** bcftools merge presumes that samples within each VCF file have unique names. If they don't bcftools will exit with an error message, unless the option "--force-samples" is given.


## STEP 3: Filter VCF file so that only biallelic SNPs present in all individuals are retained. 
As Admixture only considers biallelic SNPs (sites where there is only one minor allele) we will filter the VCF file to remove non-variant sites and sites with more 1 minor allele. As data missingness can cause problems we will also remove SNPs not genotyped in all individuals.

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

## STEP 4: Conducting LD-filtering of VCF file
The authors of ADMIXTURE recommend avoiding SNPs with high linkage disequilibrium (LD), so we will use PLINK to identify SNPs with LD > 0.8 within 1Mb windows and remove these using vcftools. LD filtering is conducting as follows:

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

#This will output a list of SNPs to retain in the file with extension ".prune.in"
#Use the following command to find out how many SNPs will be retained after filtering:
wc -l *.prune.in

#Use ".prune.in" file to filter VCF retaining SNPs with LD <0.8:
vcftools --vcf ${VCF_File_prefix}_annot.vcf \
--snps ${VCF_File_prefix}_annot.prune.in \
--recode

#Rename outputted vcf file something sensible
mv out.recode.vcf ${VCF_File_prefix}_LD_Pruned.vcf
```


## STEP 5: Running Admixture on LD-filtered VCF file.
Steve Mussmann's Admixure pipeline requires a file specifying which population a given sample belongs to. This file, which we will call PopMap.txt, is a simple tab-delimited file with two columns. Column 1 specifies sample name in VCF file and column 2 specifies the samples population. Here is an example:

```bash
Sample_1  Pop_A
Sample_2  Pop_A
Sample_3  Pop_B
Sample_4  Pop_B
Sample_5  Pop_B
Sample_6  Pop_C
```

Thankfully the Admixture Pipeline has hugely simplified running ADMIXTURE. You can run ADMIXTURE using the commands below:

```bash

#Set minimum and maximum values of K (number of possible populations to be tested):
Min_K=1
Max_K=5 #<-- change to something meaningful for your samples, this could be max number of location, presumed populations etc.

#Specify name of vcf file:
VCF=Merged_BiallelicOnly_NoMissing_LD_Pruned.vcf

#Specify number of independent runs required:
RUNS=100

#Specify the cross-validation number for the admixture program (default = 20)
CROSSVAL=20

#Specify the number of processors. Currently the only multithreaded program is Admixture.
PROCESSORS=1

ulimit -n 3000
python admixturePipeline/admixturePipeline.py \
-v $VCF \
-m PopMap.txt \
-k $Min_K \
-K $Max_K \
-n $PROCESSORS \
-R $RUNS \
-c $CROSSVAL
```

ADMIXTURE will now start running. Depending on the number of loci/samples included in VCF and the number of independent runs selected it may take several hours to run -- bioinformatics is predominantly patience.

When complete ADMIXTURE will have outputted many files. For each run and each value of K ADMIXTURE will output the following:
1. .Q = ancestry fractions for each indivual
2. .P = the allele frequencies of the inferred ancestral populations
3. .stdout = output from cross-validation error estimation.

## STEP 6: Determining the best value of K

To determine the best value of K we will extract the cross-validation error from each run of each value of K and pipe that to a file we will call CV_Error_All_Runs.txt

```bash
grep -h CV *.stdout > CV_Error_All_Runs.txt
```
Now need to open CV_Error_All_Runs.txt in Excel and calculate mean cross-validation (CV) error for each value of K. Based on this which value of K has the lowest CV error for your data? 

```bash
BEST_K=X #<-- Insert best K value here
```
Create a new directory where we will move output for best K, switch to that directory and move output

```bash
mkdir Best_K
cd Best_K
mv ../*.${BEST_K}_*.Q
mv ../*.${BEST_K}_*.P
mv ../*.${BEST_K}_*.stdout
```

## STEP 7: Summarising output across runs
As we have conducted multiple runs of each value of K we will need to sumamrise runs for the best K value prior to plotting output. To do this we will use a programme called [CLUMPP](https://rosenberglab.stanford.edu/clumpp.html) that deals with label switching between runs. 


