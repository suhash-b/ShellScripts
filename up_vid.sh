#!/bin/bash
#
#--------------------------------------------------------------------------------------------------------------------------
# SCRIPT NAME       : up_vid.sh
# USAGE             : ./up_vid.sh sample_suffix_abc
# DESCRIPTION       : The script is used to upload a video to Google Drive. The video being uploaded is the latest file
#                     from the current folder.
#                     Google Drive Folder Directory ID to be updated in Line No 48. For getting the ID run "gdrive list"
# AUTHOR            : Suhash Baidya
# CREATED           : Mar 30 2022
#--------------------------------------------------------------------------------------------------------------------------

clear
echo -e "\n Upload a video to Google Drive"
echo " =============================="

#Extract Timestamp
timestamp=`date`
echo -e "\nDATE: " $timestamp
echo ""

#Read suffix which will be part of the new filename from argument passed during execution
suffix=`echo $1`
if [ $# -ne 1 ]
  then
    echo "Argument Error. Please enter the suffix which will be part of the new filename during execution of the script. Exiting..."
    echo -e "Usage: ./up_vid.sh sample_suffix_abc\n"
    exit
fi
echo "Suffix to be appended in the file name is" $suffix

#Get the most recent file from the current directory
latest_file=`ls -Art *mp4 | tail -n 1`
filename=`echo $latest_file |sed 's/.mp4//g'`
echo -e "\nMost recent file in the current directory is: " $latest_file
echo $latest_file > temp_file

#Change file name to append _ + parameter at end of file name
while IFS= read -r file; do mv -- "$file" "$filename"_"$suffix".mp4""; done < temp_file
video_file=`ls -Art *mp4 | tail -n 1`
echo "File name updated with suffix provided:" $video_file
rm temp_file

#Upload the video to a Google Drive folder using "gdrive"
echo -e "\nUploading the file" $video_file "to Google Drive folder..."

#Google Drive Folder Directory ID. For getting the ID run "gdrive list"
parent_id=""

#gdrive Utility Usage
gdrive upload --parent $parent_id "$video_file" > gdrive.out

fileid=`cat gdrive.out |grep Uploaded |awk '{print $2}'`

#Display URL
echo "URL: https://drive.google.com/file/d/"$fileid"/view?usp=sharing"

rm gdrive.out
echo ""
