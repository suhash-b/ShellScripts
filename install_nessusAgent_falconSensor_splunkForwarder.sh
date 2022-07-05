#!/bin/bash

#NessusAgent
clear
echo -e "\033[0;32mINSTALLING NessusAgent\033[0m"
echo -e "\033[0;32m======================\033[0m"
echo ""

wget --no-check-certificate https://artifactory.tools.marriott.com/artifactory/appsec-generic-local/nessus/agent/current/NessusAgent-Current-amzn.x86_64.rpm

retVal=$?
if [ $retVal -ne 0 ]; then
    echo -e "\033[0;31mError fetching NessusAgent rpm file. Exiting...\033[0m"
    exit $retVal
fi


if [ ! -f NessusAgent-Current-amzn.x86_64.rpm ]
then
    echo ""
    echo -e "\033[0;31mNessusAgent-Current-amzn.x86_64.rpm File does not exist.\033[0m"
    exit
else
    echo ""
    echo -e "\033[0;32mNessusAgent-Current-amzn.x86_64.rpm file present. Proceeding...\033[0m"
fi

echo ""

echo -e "\033[0;33mPackage NessusAgent installation.\033[0m"  

sudo rpm -ivh NessusAgent-Current-amzn.x86_64.rpm

retVal=$?
if [ $retVal -ne 0 ]; then
    echo ""
    echo -e "\033[0;31mError installing NessusAgent. Please check, the agent might already be installed.\033[0m"
fi

echo ""
echo -e "\033[0;33mNessusAgent Status\033[0m"

sudo /opt/nessus_agent/sbin/nessuscli agent status

echo ""
echo -e "\033[0;33mNessusAgent linking...\033[0m" 
sudo /opt/nessus_agent/sbin/nessuscli agent link --key=9713f546c60a18a56a9c388aae545727f22810a3b994b96668544ae29e109269 --cloud

echo ""
echo -e "\033[0;33mStarting NessusAgent...\033[0m"
sudo /bin/systemctl start nessusagent

retVal=$?
if [ $retVal -ne 0 ]; then
    echo -e "\033[0;31mError starting NessusAgent. Exiting...\033[0m"
    exit $retVal
fi

echo ""
echo -e "\033[0;33mEnabling NessusAgent...\033[0m"
sudo systemctl enable nessusagent

retVal=$?
if [ $retVal -ne 0 ]; then
    echo -e "\033[0;31mError enabling NessusAgent. Exiting...\033[0m"
    exit $retVal
fi

echo ""
echo -e "\033[0;33mNessusAgent Service Status:\033[0m"
sudo systemctl status nessusagent.service

echo ""
echo -e "\033[0;33mNessusAgent Status:\033[0m"
sudo /opt/nessus_agent/sbin/nessuscli agent status

#Install Falcon-sensor
clear
echo -e "\033[0;32mINSTALLING Falcon Sensor\033[0m"
echo -e "\033[0;32m========================\033[0m"
echo ""

echo -e "\033[0;33mGetting Falcon-sensor rpm file.\033[0m"

wget https://artifactory.marriott.com/artifactory/appsec-generic-local/crowdstrike-falcon/agent/current/falcon-sensor-6.35.0-13207.amzn2.x86_64.rpm

sudo yum install libnl -y

if [ ! -f falcon-sensor-6.35.0-13207.amzn2.x86_64.rpm ]
then
    echo -e "\033[0;31mfalcon-sensor-6.35.0-13207.amzn2.x86_64.rpm File does not exist.\033[0m"
    exit
else
    echo ""
    echo -e "\033[0;32mfalcon-sensor-6.35.0-13207.amzn2.x86_64.rpm file present. Proceeding...\033[0m"
fi

echo ""
sudo rpm -ivh falcon-sensor-6.35.0-13207.amzn2.x86_64.rpm

retVal=$?
if [ $retVal -ne 0 ]; then
    echo ""
    echo -e "\033[0;31mError installing Falcon Sensor. Please check the agent might already be installed.\033[0m"
fi

sudo /opt/CrowdStrike/falconctl -sf --cid=6FC3C74E8DE14AB18A6F76145806F88D-EA

echo ""
echo -e "\033[0;33mStopping Falcon Sensor Service...\033[0m"

sudo systemctl stop falcon-sensor.service

echo ""
echo -e "\033[0;33mStarting Falcon Sensor Service...\033[0m"
 
sudo systemctl start falcon-sensor.service

echo ""
echo -e "\033[0;33mEnabling Falcon Sensor Service...\033[0m"
 
sudo systemctl enable falcon-sensor.service

echo ""
echo -e "\033[0;33mFalcon Sensor Service Status:\033[0m"
 
sudo systemctl status falcon-sensor.service

#Install SplunkForwarder:
clear
echo -e "\033[0;32mINSTALLING SplunkForwarder\033[0m"
echo -e "\033[0;32m==========================\033[0m"

echo ""
echo -e "\033[0;33mGetting Splunk-forwarder rpm file.\033[0m"

wget https://artifactory-useast.marriott.com/artifactory/appsec-generic-local/splunk-uf/agent/current/splunkforwarder-7.2.3-06d57c595b80-linux-2.6-x86_64.rpm
 
#chmod 500 ufinstallation.tar;tar -xf ufinstallation.tar -C /tmp/;cd /tmp/UFInstallationScripts
echo ""
echo -e "\033[0;33mGetting Splunk-forwarder deployment config rpm file.\033[0m"

wget https://artifactory-useast.marriott.com/artifactory/appsec-generic-local/splunk-uf/agent/current/splunkforwarder-deployment-config-7.2.3-1.0.noarch.rpm

echo ""
echo -e "\033[0;33mInstalling SplunkForwarder...\033[0m"
 
sudo rpm --nosignature -ivh splunkforwarder-7.2.3-06d57c595b80-linux-2.6-x86_64.rpm splunkforwarder-deployment-config-7.2.3-1.0.noarch.rpm

retVal=$?
if [ $retVal -ne 0 ]; then
    echo ""
    echo -e "\033[0;31mError installing SplunkForwarder. Please check Splunk Forwarder might already be installed...\033[0m"
fi

echo ""
echo -e "\033[0;33mEnabling SplunkForwarder Service...\033[0m"
 
sudo systemctl enable SplunkForwarder.service

echo ""
echo -e "\033[0;33mStarting SplunkForwarder...\033[0m"

sudo systemctl start SplunkForwarder.service

retVal=$?
if [ $retVal -ne 0 ]; then
    echo -e "\033[0;31mError starting SplunkForwarder service. Exiting...\033[0m"
    exit $retVal
fi

echo ""
echo -e "\033[0;32mdeploymentclient.conf file:\033[0m"
cat > /opt/splunkforwarder/etc/apps/all_deploymentclient/default/deploymentclient.conf << EOF
[target-broker:deploymentServer]
targetUri = deploymentserver.marriott.com:8089

[deployment-client]
phoneHomeIntervalInSecs=60
appEventsResyncIntervalInSecs=86400
EOF

cat /opt/splunkforwarder/etc/apps/all_deploymentclient/default/deploymentclient.conf

echo ""
echo -e "\033[0;33mProceeding...\033[0m" 
sudo /opt/splunkforwarder/bin/splunk cmd btool deploymentclient list --debug
 
sudo setfacl -Rdm u:splunk:rx /var/log

echo ""
echo -e "\033[0;33mRestarting SplunkForwarder...\033[0m"
sudo systemctl restart SplunkForwarder.service

echo ""
echo -e "\033[0;33mSplunkForwarder Service Status:\033[0m"
sudo systemctl status  SplunkForwarder.service


echo ""
echo ""
echo -e "\033[0;32mNessus Agent, Falcon Sensor and Splunk Forwarder succesfully installed and configured.\033[0m"
echo ""