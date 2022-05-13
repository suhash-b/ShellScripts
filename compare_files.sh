#!/bin/bash
#
#--------------------------------------------------------------------------------------------------------------------------
# SCRIPT NAME       : compare_files.sh
# USAGE             : ./compare_files.sh <filename1> <filename2> .. <filenameN>
# DESCRIPTION       : The script is used to compare a list of CSVs and and check if there are any duplicate ID values in 
#                     the CSV provided. If duplicate values are found the same will be redirected to a separate CSV 
#                     output file compare_files_out.csv
#                     
# AUTHOR            : Suhash Baidya
# CREATED           : May 12 2022
#--------------------------------------------------------------------------------------------------------------------------

if [ $# -eq 0 ]
  then
    echo -e "\nERROR: No input file names supplied."
    echo -e "Usage: ./compare_files.sh input_filename1.csv input_filename2.csv .. input_filenameN.csv\n"
    exit
fi

for i; do
	if [[ ! -r $i && ! -s $i ]];
	then
		echo -e "\nERROR: One or more input files are not present or not readable. Please check.\n"
		exit
	fi
done

OUTFILE=compare_files_out.csv

INFILE1=$1
INFILE2=$2

tr -d '\r' < $INFILE1 | cut -d, -f1 |sed 's/.txt//g' |sed 's/.exe//g' |sort -u > i.csv
tr -d '\r' < $INFILE2 | cut -d, -f1 |sed 's/.txt//g' |sed 's/.exe//g' |sort -u > j.csv

sort i.csv j.csv | uniq -d > $OUTFILE
if [[ -s $OUTFILE ]];
 then
 	echo -e "\nDuplicates extracted. Output present in $OUTFILE \n"
 else
 	echo -e "\nNo duplicates found. \n"
 fi

 rm -f i.csv j.csv
