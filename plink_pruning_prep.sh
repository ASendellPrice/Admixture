#!/bin/bash

#This script was produced by GitHub user janxkoci (https://gist.github.com/janxkoci)

# SCRIPT USAGE:
# bash plink_pruning_prep.sh filtered_snp_file.vcf

# REQUIREMENTS:
# This script uses several software packages, all available from [Bioconda channel](https://bioconda.github.io/).
# They can be installed with simple:
# conda install tabix bcftools plink

# Alternatively you can install them by other means. For example all these packages are in Debian repos.
# So e.g. on Ubuntu 16.04 you can install them with:
# sudo apt install tabix bcftools plink1.9

# STORY:
# Plink uses it's own files plink.prune.in & plink.prune.out to LD prune snips,
# but they contain IDs of variants, which in our non-model organism case defaults to "." = not practical.
# To fix this, we need to prepare annotation file, compress it and index it using tabix
# (bgzip is part of the package, just conda install tabix). Then we annotate our vcf with bcftools annotate tool.

# STEPS NEEDED:
# - extract CHROM and POS fields from vcf and merge them into new ID field (combine bash cut & paste commands, see below)
# - compress annotation file with bgzip (part of tabix package, available in Bioconda channel)
# - index it with tabix
# - run bcftools annotation to add new IDs
# - then run plink --indep 50 5 2
# - run plink PCA / MDS with the --extract plink.prune.in flag

# CODE:
VCF_in=$1 # extracts input name from command line, when calling script
VCF_out=$(basename -s .vcf $VCF_in)_annot.vcf # output name with _annot appended

# make annotation file with this oneliner
echo preparing annotation file using bash kung-fu...
cat \
<(grep '#CHROM' $VCF_in | cut -f 1-3) \
<(paste \
<(grep -v '#' $VCF_in | cut -f 1,2) \
<(grep -v '#' $VCF_in | cut -f 1,2 | sed 's/\t/_/g')) > annotation_file.tab

# compress
echo compressing using bgzip...
bgzip annotation_file.tab

# index
echo indexing using tabix...
tabix -p vcf annotation_file.tab.gz

# annotate VCF
echo annotating using bcftools...
bcftools annotate -c CHROM,POS,ID -a annotation_file.tab.gz $VCF_in -o $VCF_out

echo Ready for plink! Have fun :\)

# now you are ready to run plink pruning on the output file (--allow-extra-chr is needed for nonhuman organisms), e.g.
# plink --indep 50 5 2 --vcf $VCF_out --allow-extra-chr
# plink --extract plink.prune.in --vcf $VCF_out --genome --recode --out plinkMDS --allow-extra-chr
# plink --file plinkMDS --read-genome plinkMDS.genome --cluster --mds-plot 2 --allow-extra-chr
