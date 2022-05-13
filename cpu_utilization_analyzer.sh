#!/bin/bash
#
#--------------------------------------------------------------------------------------------------------------------------
# SCRIPT NAME       : cpu_utilization_analyzer.sh
# USAGE             : ./cpu_utilization_analyzer.sh
# DESCRIPTION       : The script is used to check average CPU utilization in the system (average of 1 hour)
#                     If avg CPU utilization goes below the given threshold i.e. 5% then the script will shut down the whole instance.
#                     
# AUTHOR            : Suhash Baidya
# CREATED           : Apr 08 2022
#--------------------------------------------------------------------------------------------------------------------------

#Extract Timestamp
#-----------------
DATE=$(date "+%Y-%m-%d %H:%M:")

#Extract CPU Utilization %
#-------------------------
CPU_USAGE=`awk '{print $1}' /proc/loadavg` 


#CPU Utilization output Data points redirected to file cpu_usage.out
#-------------------------------------------------------------------
CPU_USAGE="$DATE CPU: $CPU_USAGE"%
echo $CPU_USAGE >> cpu_usage.out


#System Parameters
#-----------------
minutes=60
cpu_threshold=5

#CPU Utilization 1 Hour Average validation Block
#-----------------------------------------------
count=`wc -l cpu_usage.out |awk '{print $1}'` 

if [ $count -lt $minutes ] 
then
	#Exit if the data points available are less than 60 i.e. 1 hour
	echo "Not enough data points.Exiting..."
	exit
else
	#Compute CPU Utilization average of the last 60 minutes
	count=0;
	total=0;
	
	for i in $( tail -60 cpu_usage.out | awk '{ print $4; }' | sed 's/%//g' )
	do
		total=$(echo $total+$i | bc )
		((count++))
	done

	avg=`echo "scale=0; $total / $count" | bc`

	#Check if CPU Utilization 1 hour average is less than 5%
	if [ $avg -lt $cpu_threshold ]
	then
		echo "CPU Utilization average for the last 60 minutes is less than 5%"
		echo "Shutting down the instance..."
		
		#Shutdown Instance
		shutdown
	fi

fi
