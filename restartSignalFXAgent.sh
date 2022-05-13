#!/bin/bash
#
#--------------------------------------------------------------------------------------------------------------------------
# SCRIPT NAME       : restartSignalFXAgent.sh
# USAGE             : ./restartSignalFXAgent.sh
# DESCRIPTION       : The script is used to restart the SignalFX SmartAgent. The following are the modules of the script.
#                     * Extract the SignalFX agent status
#                     * Create a backup of the Token file with new file name token.mm.dd.yyyy.bak
#                     * Read new token file string from user input and update the token file.
#                     * Restart the SignalFX SmartAgent on the host.
#                     * Logs created in the path $HOME/restart-SmartAgent.log
# AUTHOR            : Suhash Baidya
# CREATED           : Mar 26 2022
#--------------------------------------------------------------------------------------------------------------------------

echo "Restarting SignalFX SmartAgent..." >> $HOME/restart-SmartAgent.log

#Extract Timestamp
timestamp=`date`
echo "DATE: " $timestamp >> $HOME/restart-SmartAgent.log

echo "SIGNALFX AGENT STATUS" >> $HOME/restart-SmartAgent.log
echo "=====================" >> $HOME/restart-SmartAgent.log

#Check the status of the agent on the host.
sudo signalfx-agent status >> $HOME/restart-SmartAgent.log
service signalfx-agent status >> $HOME/restart-SmartAgent.log
systemctl signalfx-agent status >> $HOME/restart-SmartAgent.log

echo "SIGNALFX AGENT ENDPOINTS STATUS" >> $HOME/restart-SmartAgent.log
echo "===============================" >> $HOME/restart-SmartAgent.log

#Check the endpoints set on the agent
signalfx-agent status endpoints >> $HOME/restart-SmartAgent.log

#Create backup copy of token file
dt=`date +'%m.%d.%Y'`
cp /etc/signalfx/token /etc/signalfx/token.$dt.bak

echo "Token file Backup copy created." >> $HOME/restart-SmartAgent.log

#Update token file string with new string.
read -ep "Please enter the new token file string: " new_token
echo $new_token > /etc/signalfx/token

echo "Token file updated with new string." >> $HOME/restart-SmartAgent.log

#Restart SignalFX SmartAgent
echo "Restarting SignalFX SmartAgent on the host..." >> $HOME/restart-SmartAgent.log
sudo systemctl restart signalfx-agent >> $HOME/restart-SmartAgent.log

#-----------------------------------------------------------EOF--------------------------------------------------------------
