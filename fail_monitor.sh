#Extract Timestamp
#-----------------
DATE=$(date "+%Y-%m-%d %H:%M:")


read -p "CER or TER? (type c or t) " answer
case ${answer:0:1} in
c|C )
	echo $DATE |tee fail_monitor.out
	echo "Executing restart (if needed) of CER smsc..." |tee fail_monitor.out
	echo "Machine cer-smsc-05" |tee fail_monitor.out
	ssh cer-smsc-05 '
	if [[ $(sudo tail -50 /etc/sv/smsc/log/main/current |grep -P "fail | [error] CRASH REPORT Process") == "" ]] && [[ $(ssh root@cer-smsc-05 -p 2200 'if $(ps ax |grep tcapsrv| grep -v grep |wc -l) -eq 2 ]] ;
	then
		echo "No fail or timeout found on cer-smsc-05. Process on aculab are two. Nothing to do. Exiting" |tee fail_monitor.out
		exit 1
	else
		echo "Found timeout or fail. Stopping cer-sms-05" |tee fail_monitor.out
		echo cd /etc/sv/smsc/ ; echo sv stop smsc
		echo "Connecting to cer-aculab-01 and killing tcapserv" |tee fail_monitor.out
		ssh 192.168.28.16 "ssh root@172.16.1.2 'killall -9 tcapserv ; ps aux |grep tcapsrv |grep -vq grep | if [ "$?" -eq 0 ]; then killall -9 tcapserv; fi'"
		echo "Checked processes on the dependent machine" |tee fail_monitor.out
		echo "Starting smsc services.." |tee fail_monitor.out
		echo cd /etc/sv/smsc/ ; echo sv start smsc
		echo "Restart completed on cer-smsc-05" |tee fail_monitor.out
	fi'

	echo "Machine cer-smsc-06" |tee fail_monitor.out
	ssh cer-smsc-06 '
	if [[ $(sudo tail -50 /etc/sv/smsc/log/main/current |grep -P "fail | [error] CRASH REPORT Process") == "" ]] && [[ $(ssh root@cer-smsc-06 -p 2200 'if $(ps ax |grep tcapsrv| grep -v grep |wc -l) -eq 2 ]] ;
	then
		echo "No fail or timeout found on cer-smsc-06. Process on aculab are two. Nothing to do. Exiting" |tee fail_monitor.out
		exit 1
	else
		echo "Found timeout or fail. Stopping cer-smsc-06" |tee fail_monitor.out
		echo cd /etc/sv/smsc/ ; echo sv stop smsc
		echo "Connecting to cer-aculab-02 and killing tcapserv" |tee fail_monitor.out
		ssh 192.168.28.17 "ssh root@172.16.1.2 'killall -9 tcapserv ; ps aux |grep tcapsrv |grep -vq grep | if [ "$?" -eq 0 ]; then killall -9 tcapserv; fi'"
		echo "Connecting to cer-aculab-01 and killing tcapserv" |tee fail_monitor.out
		echo "Start smsc services.." |tee fail_monitor.out
		echo cd /etc/sv/smsc/ ; echo sv start smsc
		echo "Restart completed on cer-smsc-06" |tee fail_monitor.out
	fi'
	;;
t|T )
	echo $DATE |tee fail_monitor.out
	echo "Executing restart (if needed) of TER smsc..." |tee fail_monitor.out
	echo "Machine ter-smsc-03" |tee fail_monitor.out
	ssh ter-smsc-03 '
	if [[ $(sudo tail -50 /etc/sv/smsc/log/main/current |grep -P "fail | [error] CRASH REPORT Process") == "" ]] && [[ $(ssh root@ter-smsc-03 -p 2200 'if $(ps ax |grep tcapsrv| grep -v grep |wc -l) -eq 2 ]] ;
	then
		echo "No fail or timeout found on ter-smsc-03. Not restarted. Exiting" |tee fail_monitor.out
		exit 1
	else
		echo "Found timeout or fail. Stopping ter-smsc-03" |tee fail_monitor.out
		echo cd /etc/sv/smsc/ ; echo sv stop smsc
		echo "Connecting to ter-aculab-01 and killing tcapserv" |tee fail_monitor.out
		ssh 192.168.x.x "ssh root@172.16.x.x 'killall -9 tcapserv ; ps aux |grep tcapsrv |grep -vq grep | if [ "$?" -eq 0 ]; then killall -9 tcapserv; fi'"
		echo "Checked processes on the dependent machine" |tee fail_monitor.out
		echo "Start smsc services.." |tee fail_monitor.out
		echo cd /etc/sv/smsc/ ; echo sv start smsc
		echo "Restart completed on ter-smsc-03" |tee fail_monitor.out
	fi'

	echo "Machine ter-smsc-04" |tee fail_monitor.out
	ssh ter-smsc-04 '
	if [[ $(sudo tail -50 /etc/sv/smsc/log/main/current |grep -P "fail | [error] CRASH REPORT Process") == "" ]] && [[ $(ssh root@ter-smsc-04 -p 2200 'if $(ps ax |grep tcapsrv| grep -v grep |wc -l) -eq 2 ]] ;
	then
		echo "No fail or timeout found on ter-smsc-04. Not restarted. Exiting" |tee fail_monitor.out
		exit 1
	else
		echo "Found timeout or fail. Stopping ter-smsc-04" |tee fail_monitor.out
		echo cd /etc/sv/smsc/ ; echo sv stop smsc
		echo "Connecting to ter-aculab-02 and killing tcapserv" |tee fail_monitor.out
		ssh 192.168.x.x "ssh root@172.16.x.x 'killall -9 tcapserv ; ps aux |grep tcapsrv |grep -vq grep | if [ "$?" -eq 0 ]; then killall -9 tcapserv; fi'"
		echo "Checked processes on the dependent machine" |tee fail_monitor.out
		echo "Start smsc services.." |tee fail_monitor.out
		echo cd /etc/sv/smsc/ ; echo sv start smsc
		echo "Restart completed on ter-smsc-04" |tee fail_monitor.out
	fi'
	;;
* )
	echo $DATE |tee fail_monitor.out
	echo "No valid answer, exiting.." |tee fail_monitor.out
	exit 2
	;;
esac
