#!/bin/bash
clear

echo ""
echo "Load Balancer: Fetch Instance with least CPU and Login"
echo "======================================================"
timestamp=$(date)
echo "DATE:" "$timestamp" 
echo ""
echo ""

# Destination path/filename to save results to
CPU_FILE=CPUUtilization.out

# source list of host IPs to read from
INSTANCE_ID_FILE=InstanceID.out

# Removing temporary Files
rm -f $CPU_FILE $INSTANCE_ID_FILE

echo "Fetching all the Instance IDs..."  
echo ""

# Returns a list of instances in the Auto-scaling group.
#aws ec2 describe-instances  --query Reservations[*].Instances[*].[InstanceId] > $INSTANCE_ID_FILE
for i in $(aws autoscaling describe-auto-scaling-instances --query AutoScalingInstances[].InstanceId --output text);
do
  echo "$i" >> $INSTANCE_ID_FILE
done

cat $INSTANCE_ID_FILE

# Total number of instances
instance_count=$(wc -l $INSTANCE_ID_FILE |awk '{print $1}')

echo ""
echo ""
echo "Total number of instances: $instance_count"
echo ""
echo ""

# Extract Current Time
now=$(date +"%T")
echo "Current time : $now"
echo ""
echo "Getting the CPU Utilization of the instances during the last hour."

# Format Timestamp

start_time=$(date -d '1 hour ago' +"%Y-%m-%dT%H:%M:%SZ")
end_time=$(date +"%Y-%m-%dT%H:%M:%SZ")

# Iterate through line items in INSTANCE_ID_FILE and
# return the CPU Utilization of the instances for the past One Hour
# write it to DEST path/file


cat $INSTANCE_ID_FILE | while read instance_id
do
  cpu_utilization=$(aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --period 3600 --statistics Maximum --dimensions Name=InstanceId,Value=${instance_id} --start-time ${start_time} --end-time ${end_time} |grep DATAPOINTS |awk '{print $2}')
  printf "$instance_id %0.2f\n" $cpu_utilization >> $CPU_FILE
  echo "" >> $CPU_FILE
done

# Fetching the instance ID and CPU Utilization
echo ""
echo "CPU Utilization percentages of the instances"
echo ""
cat $CPU_FILE


# Get the least utilized machine
inst_id=$(grep . $CPU_FILE | sort -nk2 |head -1 |awk '{print $1}')
cpu=$(grep . $CPU_FILE | sort -nk2 |head -1 |awk '{print $2}')
echo ""
echo ""
echo "Least utilized machine with instance ID is" "$inst_id" " having CPU utiliztion" "$cpu" "% during the last one-hour."

echo ""

# Removing temporary Files
rm -f $CPU_FILE $INSTANCE_ID_FILE

echo ""

echo "Do you want to login to the instance ID" "$inst_id" "?. Enter Y(or y)/N(or n)% during the last one-hour."
read -p "Yes or No? (type Y or N) " answer
case $answer in
y|Y)
    # Logging in to the host
    clear
    echo ""
    echo "Logging in to the instance..."
    echo ""
    aws ssm start-session --target ${inst_id}
;;
n|N)
    echo "Not logging in to instance. Thank you."
;;
*)
	  echo "No valid answer, exiting.."
	  exit
;;
esac
