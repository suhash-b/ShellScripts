#!/bin/bash

#Original Folder
FOLDER='Automator/pdf/'

# Declaring folder name variables
# L_NEW_FOLDER : New folder which should contain PDFs containing Letter in the file name.
# E_NEW_FOLDER : New folder which should contain PDFs containing Envelope in the file name.

L_NEW_FOLDER='Automator/Letter_New_Folder/'
E_NEW_FOLDER='Automator/Envelope_New_Folder/'

# Find PDFs matching Letter and Envelope and move them to respective folders
find $FOLDER -maxdepth 1 -name "*letter*.pdf" -exec mv {} $L_NEW_FOLDER \;
find $FOLDER -maxdepth 1 -name "*envelope*.pdf" -exec mv {} $E_NEW_FOLDER \;

# Combine All Letter PDF files into one Folder
cd $L_NEW_FOLDER
ls *.pdf | xargs "/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o Letter_final.pdf

# Combine All Envelope PDF files into one Folder
cd $E_NEW_FOLDER
ls *.pdf | xargs "/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o Envelope_final.pdf


# Removing the individual Files that weren't combined
cd $FOLDER
rm -rf *.pdf
