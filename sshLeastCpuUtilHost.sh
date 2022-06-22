#!/bin/bash
clear

# Username to connect via ssh
USER= <UserName>

# Destination path/filename to save results to
DEST=<Outputfile>

# source list of host IPs to read from
FILE=<hostIPs>

# source output of the instances for a loadbalancer
ELB_FILE=ELB_File.out

# Returns a list of instances connected to the ELB.
aws elb describe-instance-health --load-balancer-name <ELB name> > $ELB_FILE
<Code to extract the instance IDs>

# Returns among other things the IP address of the instance.
aws ec2 describe-instances <instance id>
aws ec2 describe-instances | grep PublicIpAddress | grep -o -P "\d+\.\d+\.\d+\.\d+" | grep -v '^10\.'

# Iterate through line items in FILE and
# execute ssh, if we connected successfully
# run proc/loadavg to find cpu load
# write it to DEST path/file
# if we don't connect successfully, write the hostname
# and "unable to connect to host" error to DEST path/file

for i in `cat $FILE`; do
  echo -n ".";
  CHK=`ssh -q -T -o ConnectTimeout=10 -o ConnectionAttempts=1 username@$i "echo success"`;
  if [ "success" = $CHK ] >/dev/null 2>&1
  then
    `ssh -q -T -o ConnectTimeout=10 -o ConnectionAttempts=1 username@$i "\
        printf "$i    ";
        echo "`cat /proc/loadavg | awk '{print $3}'`";" >> ${DEST}`;
  else
    printf "${i}\tUnable to connect to host\n" >> ${DEST};
  fi
done

# Get the least utilized machine

ip=`sort -nk2 ${DEST} |head -1 |awk '{print $1}'`
cpu=sort -nk2 ${DEST} |head -1 |awk '{print $2}'`

echo "Least utilized machine with IP" $ip " having CPU utiliztion" $cpu "%"

# All line items have been gone through,
# show done, and exit out
echo ""
echo "Done!"
echo "Check the list 'checkssh_failure' for errors."

# SSHing to the host
echo "SSHing to the host..."

ssh username@$ip
