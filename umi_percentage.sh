#!/bin/bash

#Step 0: Check what the UMI distribution looks like

# Make output file
OUTPUT_FILE="umi_percentage_results.txt"
echo "UMI Percentage Results" > $OUTPUT_FILE
echo "=====================" >> $OUTPUT_FILE

for R1_FILE in $1/*R1*.fastq.gz; do
R2_FILE=${R1_FILE/R1/R2}
# Define UMI sequences. Maybe make a function here so that it is more flexible.
ORIGINAL_UMI_PATTERN="ATTGCGCAATG[ACGT]{8}GGG" # Forward 10bp UMI pattern
ALTERNATE_UMI_PATTERN="ATTGCGCAATG[ACGT]{8}GGG" # Alternative 10bp UMI pattern
UMI_PATTERN="TGCGCAATG[ACGT]{8}GGG" # Forward 8bp UMI pattern
REVERSE_UMI_PATTERN="CCC[ACGT]{8}CATTGCGCA" # Reverse complement UMI pattern
COMPLEMENT_UMI_PATTERN="ACGCGTTAC[TCGA]{8}CCC" # Complement UMI pattern

# Calculate total number of reads (assumes 4 lines per read)
nb_lines_R1=$(zcat ${R1_FILE} | wc -l)
nb_lines_R2=$(zcat ${R2_FILE} | wc -l)
nb_totFrag_R1=$(( nb_lines_R1 / 4 ))
nb_totFrag_R2=$(( nb_lines_R2 / 4 ))

# I should write a function here to calculate percentage, but this is easier for the moment.

# Find percentage of original UMI reads in R1
nb_umis_R1=$(zgrep -P -o "${ORIGINAL_UMI_PATTERN}" ${R1_FILE} | wc -l)
percent_umis_R1_original=$(echo "scale=3; $nb_umis_R1 * 100 / $nb_totFrag_R1" | bc)

# Find percentage of original UMI reads in R2
nb_umis_R2=$(zgrep -P -o "${ORIGINAL_UMI_PATTERN}" ${R2_FILE} | wc -l)
percent_umis_R2_original=$(echo "scale=3; $nb_umis_R2 * 100 / $nb_totFrag_R2" | bc)

# Find percentage of alternate UMI reads in R1
nb_umis_R1=$(zgrep -P -o "${ALTERNATE_UMI_PATTERN}" ${R1_FILE} | wc -l)
percent_umis_R1_alternate=$(echo "scale=3; $nb_umis_R1 * 100 / $nb_totFrag_R1" | bc)

# Find percentage of alternate UMI reads in R2
nb_umis_R2=$(zgrep -P -o "${ALTERNATE_UMI_PATTERN}" ${R2_FILE} | wc -l)
percent_umis_R2_alternate=$(echo "scale=3; $nb_umis_R2 * 100 / $nb_totFrag_R2" | bc)

# Find percentage of UMI reads in R1
nb_umis_R1=$(zgrep -P -o "${UMI_PATTERN}" ${R1_FILE} | wc -l)
percent_umis_R1=$(echo "scale=3; $nb_umis_R1 * 100 / $nb_totFrag_R1" | bc)

# Find percentage of UMI reads in R2
nb_umis_R2=$(zgrep -P -o "${UMI_PATTERN}" ${R2_FILE} | wc -l)
percent_umis_R2=$(echo "scale=3; $nb_umis_R2 * 100 / $nb_totFrag_R2" | bc)

# Find percentage of UMI reads in R1 using reverse complement
nb_umis_R1_revcomp=$(zgrep -P -o "${REVERSE_UMI_PATTERN}" ${R1_FILE} | wc -l)
percent_umis_R1_revcomp=$(echo "scale=3; $nb_umis_R1_revcomp * 100 / $nb_totFrag_R1" | bc)

# Find percentage of UMI reads in R2 using reverse complement
nb_umis_R2_revcomp=$(zgrep -P -o "${REVERSE_UMI_PATTERN}" ${R2_FILE} | wc -l)
percent_umis_R2_revcomp=$(echo "scale=3; $nb_umis_R2_revcomp * 100 / $nb_totFrag_R2" | bc)

# Find percentage of UMI reads in R1 using complement
nb_umis_R1_complement=$(zgrep -P -o "${COMPLEMENT_UMI_PATTERN}" ${R1_FILE} | wc -l)
percent_umis_R1_complement=$(echo "scale=3; $nb_umis_R1_complement * 100 / $nb_totFrag_R1" | bc)

# Find percentage of UMI reads in R2 using complement
nb_umis_R2_complement=$(zgrep -P -o "${COMPLEMENT_UMI_PATTERN}" ${R2_FILE} | wc -l)
percent_umis_R2_complement=$(echo "scale=3; $nb_umis_R2_complement * 100 / $nb_totFrag_R2" | bc)

# Output results
echo "Results for $R1_FILE and $R2_FILE" >> $OUTPUT_FILE
    echo "------------------------------------" >> $OUTPUT_FILE
    echo "$R1_FILE: Percentage of 10bp UMI reads in R1: $percent_umis_R1_original%" >> $OUTPUT_FILE
    echo "$R2_FILE: Percentage of 10bp UMI reads in R2: $percent_umis_R2_original%" >> $OUTPUT_FILE
    echo "$R1_FILE: Percentage of 10bp (alternative) UMI reads in R1: $percent_umis_R1_alternate%" >> $OUTPUT_FILE
    echo "$R2_FILE: Percentage of 10bp (alternative) UMI reads in R2: $percent_umis_R2_alternate%" >> $OUTPUT_FILE
    echo "$R1_FILE: Percentage of 8bp UMI reads in R1: $percent_umis_R1%" >> $OUTPUT_FILE
    echo "$R2_FILE: Percentage of 8bp UMI reads in R2: $percent_umis_R2%" >> $OUTPUT_FILE
    echo "$R1_FILE: Percentage of UMI reads in R1 (Reverse complement): $percent_umis_R1_revcomp%" >> $OUTPUT_FILE
    echo "$R2_FILE: Percentage of UMI reads in R2 (Reverse complement): $percent_umis_R2_revcomp%" >> $OUTPUT_FILE
    echo "$R1_FILE: Percentage of UMI reads in R1 (Complement): $percent_umis_R1_complement%" >> $OUTPUT_FILE
    echo "$R2_FILE: Percentage of UMI reads in R2 (Complement): $percent_umis_R2_complement%" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE

done
