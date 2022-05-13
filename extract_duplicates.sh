#!/bin/bash
#
#--------------------------------------------------------------------------------------------------------------------------
# SCRIPT NAME       : extract_duplicates.sh
# USAGE             : ./extract_duplicates.sh <filename>
# DESCRIPTION       : The script is used to check if there are any duplicate ID values in the CSV provided. If duplicate 
#                     values are found the same will be redirected to a separate CSV output file duplicate.csv
#                     
# AUTHOR            : Suhash Baidya
# CREATED           : May 11 2022
#--------------------------------------------------------------------------------------------------------------------------

if [ $# -eq 0 ]
  then
    echo -e "\nERROR: No input file name supplied."
    echo -e "Usage: ./extract_duplicates.sh input_filename.csv\n"
    exit
fi

FILE=$1
OUTFILE=duplicates.csv

if [[ -r $FILE && -s $FILE ]];
then
	cut -d, -f2 $FILE |sort |uniq -d |grep -Fv 2r > $OUTFILE
	if [[ -s $OUTFILE ]];
	then
		echo -e "\nDuplicates extracted. Output present in $OUTFILE \n"
	else
		echo -e "\nNo duplicates found. \n"
	fi
else
	echo -e "\nERROR: Input file not present or not readable.\n"
	exit
fi