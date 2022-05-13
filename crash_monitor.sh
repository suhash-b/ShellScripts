#!/bin/bash
#
#--------------------------------------------------------------------------------------------------------------------------
# SCRIPT NAME       : crash_monitor.sh
# USAGE             : ./crash_monitor.sh
# DESCRIPTION       : The script connects via SSH to a remote machine and checks if there are any error matches present 
#                     in the log, restart the service if discover those matches and then connect to the next machine and 
#                     check if the processes are running. If running then kill all the processes in the machine.
#
# AUTHOR            : Suhash Baidya
# CREATED           : Apr 08 2022
#--------------------------------------------------------------------------------------------------------------------------

clear
echo -e "\n System Failure Monitor"
echo " ======================"

#Extract Timestamp
timestamp=`date`
echo -e "\nDATE: " $timestamp
echo ""

#Machine Menu
echo "1. Machine 1"
echo "2. Machine 2"
echo "3. Machine 3"
echo "4. Machine 4"

#IP Table
host1=0.0.0.0
host2=0.0.0.0
host3=0.0.0.0
host4=0.0.0.0

#Function to check the machine failures and restart the process
function check_machine_failure(){
	machine1 = $1
	machine2 = $2
	machine3 = $3
	machine4 = $4

	ssh $machine1 "sudo tail -50 /etc/sv/smsc/log/main/current | grep -Fq -e 'fail' -e '[error] CRASH REPORT Process'"
	if [ "$?" -eq 0 ];
	then
		echo "Crash failure reports present in the log."
		echo "Stopping the service..."
		ssh $machine1 "cd /etc/sv/smsc/; sv stop smsc"

		echo "Checking the processes on other machines..."
		for m in $machine2 $machine3 $machine4
		do
			ssh $m "ps aux |grep tcapsrv |grep -vq grep"
			if [ "$?" -eq 0 ];
			then
				echo "Service process running on other machine."
				echo "Terminating all the processes..."
				ssh $m "killall -9 tcapsrv"	
			fi
		done

		echo "Starting the service..."
		ssh $machine1 "cd /etc/sv/smsc/; sv start smsc"
	else
		echo "No failures or errors detected. Exiting..."
	fi
}

#Read input of the machine to be SSHed
read -ep "Please enter the machine number to check (1-4) : " machine_no
case $machine_no in
	1) check_machine_failure $host1 $host2 $host3 $host4 ;;
	2) check_machine_failure $host2 $host1 $host3 $host4 ;;
	3) check_machine_failure $host3 $host1 $host2 $host4 ;;
	4) check_machine_failure $host4 $host1 $host2 $host3 ;;
        *) echo "Please enter a correct machine number. Exiting..."
           exit ;;
esac

