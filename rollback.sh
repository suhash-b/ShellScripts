#!/bin/bash
#
#--------------------------------------------------------------------------------------------------------------------------
# SCRIPT NAME       : rollback.sh
# USAGE             : ./rollback.sh
# DESCRIPTION       : The script is used to rollback to previous token file and restart the SignalFX SmartAgent. The following are the modules of the script.
#                     * Rollback to previous backup copy of token file token.mm.dd.yyyy.bak
#                     * Restart the SignalFX SmartAgent on the host.
#                     * Logs created in the path $HOME/rollback.log
# AUTHOR            : Suhash Baidya
# CREATED           : Mar 26 2022
#--------------------------------------------------------------------------------------------------------------------------

echo "Rollback to previous token file and Restarting SignalFX SmartAgent..." >> $HOME/rollback.log

#Extract Timestamp
timestamp=`date`
echo "DATE: " $timestamp >> $HOME/rollback.log

#Rollback to previous backup copy of token file
dt=`date +'%m.%d.%Y'`
cp /etc/signalfx/token.$dt.bak /etc/signalfx/token

echo "Token file rollback complete." >> $HOME/rollback.log

#Restart SignalFX SmartAgent
echo "Restarting SignalFX SmartAgent on the host..." >> $HOME/rollback.log
sudo systemctl restart signalfx-agent >> $HOME/rollback.log

#-----------------------------------------------------------EOF--------------------------------------------------------------
