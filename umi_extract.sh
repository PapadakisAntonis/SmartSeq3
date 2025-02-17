#!/bin/bash

##Step 1: UMI extraction
#Extract reads that have tag+UMI+GGG and add UMI to read names

#This command uses UMI-tools to extract Unique Molecular Identifiers (UMIs) from paired-end sequencing data. 
#I am using a regular expression to identify the correct pattern.
#Currently, the regex pattern defines:
#A sequence to discard (everything up to and including "TGCGCAATG")
#The UMI itself (8 characters after the first pattern)
#Another discard sequence ("GGG" and everything after it)

SOURCE_DIR=$1
#Create output directory
mkdir -p processed_umis

# Loop through all R1 files in the source directory
for R1_FILE in ${SOURCE_DIR}/*R1*.fastq.gz; do
# Get the matching R2 file by replacing R1 with R2 in the filename
R2_FILE="${R1_FILE/R1/R2}"
 # Extract base name without path and extension
 BASENAME=$(basename $R1_FILE .fastq.gz | sed 's/_R1.*$//')
 
# Define output files based on input basename
R1_OUTPUT="processed_umis/${BASENAME}_UMIs.R1.fastq.gz"
R2_OUTPUT="processed_umis/${BASENAME}_UMIs.R2.fastq.gz"
R1_FILTERED="processed_umis/${BASENAME}_noUMI.R1.fastq.gz"
R2_FILTERED="processed_umis/${BASENAME}_noUMI.R2.fastq.gz"
LOG_FILE="processed_umis/${BASENAME}_umi.log"
READ_IDS="processed_umis/${BASENAME}_readIDS.txt"
READ_NUM="${BASENAME}_rn.txt"
UMI="${BASENAME}_UMIs.txt"
R1_TOTAL="${BASENAME}_final.R1.fastq.gz"
R2_TOTAL="${BASENAME}_final.R2.fastq.gz"
    
echo "Processing $BASENAME..."
    
# Run umi_tools with variables
umi_tools extract --extract-method=regex --bc-pattern='(?P<discard_1>.*TGCGCAATG)(?P<umi_1>.{8})(?P<discard_2>GGG).*' \
                  --stdin=${R1_FILE} --stdout=${R1_OUTPUT} \
                  --read2-in=${R2_FILE} --read2-out=${R2_OUTPUT} \
                  --filtered-out ${R1_FILTERED} --filtered-out2 ${R2_FILTERED} \
                  --log=${LOG_FILE}

    
#Reads with no UMIs in R1 get separated from reads with UMIs in R1.
#I may want to search for UMIs in the R2 reads of pairs that didn't have UMIs in R1. In this case I would run the same command on the noUMI files.
                    
#umi_tools extract --extract-method=regex --bc-pattern='(?P<discard_1>.*TGCGCAATG)(?P<umi_1>.{8})(?P<discard_2>GGG).*' \
#                  --stdin=test_noUMI.R2.fastq.gz --stdout=test_UMIs.R2.R2.fastq.gz \
#                  --read2-in=test_noUMI.R1.fastq.gz --read2-out=test_UMIs.R2.R1.fastq.gz \
#                  --filtered-out test_defnoUMI.R2.fastq.gz --filtered-out2 test_defnoUMI.R1.fastq.gz   \
#                  --log=test_umi2.log
                  
#For now, let's assume all UMI reads are in R1 because it would make my life easier. But this should be tested.

#I would prefer not to align UMI and non-UMI reads separately since that would increase running time. Better to align first and then separate the reads.

#Record the IDs of reads without UMIs 
#zcat ${R2_FILTERED}| grep '^@' | sed 's/@//' | sed 's/ .*//' > ${READ_IDS} #This does not work because some quality scores start with @
zcat ${R2_FILTERED} | awk 'NR % 4 == 1 {print substr($1, 2)}' > ${READ_IDS} #This works

# Calculate and save percentage of UMI reads
echo "  Calculating UMI statistics..."
rn=$(zcat "${R1_FILE}" | awk 'END {print NR/4}')
echo "Reads: $rn" > "${READ_NUM}"
nb_umis=$(zcat "${R1_OUTPUT}" | awk 'END {print NR/4}')
echo "UMI percentage: $(( nb_umis * 100 / nb_totFrag ))" > "${UMI}"

# Create total reads files
echo "  Creating final total read files..."
cat ${R1_FILTERED} >> ${R1_OUTPUT}
mv ${R1_OUTPUT} ${R1_TOTAL}
cat ${R2_FILTERED} >> ${R2_OUTPUT}  # Ensure all R2 reads are included
mv ${R2_OUTPUT} ${R2_TOTAL}
echo "Completed processing $BASENAME"	

done    


               
                  



