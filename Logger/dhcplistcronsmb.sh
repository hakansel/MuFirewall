#!/bin/sh
tarih=`date "+%Y%m%d-%H%M%S"`

ACTIVE_PID_FILE="activetcpdump.pid"

KILL_ACTIVE_PID="killactivetcpdump.sh"

AUTH_DATE=`date | awk '{ print $2 " " $3 }'`
AUTH_LOG_FILE="authanticationlog"

N_T_LOG_FILE="wholetrafficlog.pcap"
P_T_LOG_FOLDER="/home/trafficlog"

HAS_T_LOG_FOLDER=`find /home -type d | grep trafficlog`
HAS_T_LOG_FILE=`ls $P_T_LOG_FOLDER/$N_T_LOG_FILE`


if [ -z "$HAS_T_LOG_FOLDER" ]
	then
		mkdir /home/trafficlog
fi

mkdir /var/mountsamba

PID_TCPDUMP=`/bin/ps -ax | /usr/bin/grep tcpdump | /usr/bin/grep $N_T_LOG_FILE | /usr/bin/awk '{ print $1 }'`
echo $PID_TCPDUMP
echo $PID_TCPDUMP > $ACTIVE_PID_FILE
 
cd /var/mountsamba

cat /var/log/portalauth.log | grep "$AUTH_DATE" | awk '{ $4=$5=""; print $0 }' >  $AUTH_LOG_FILE-$tarih.txt

awk -f /sbin/dhcptibduzenle.sh < /var/dhcpd/var/db/dhcpd.leases > ./dhcplog-$tarih.txt

/usr/local/bin/smbclient \\\\20.0.0.15\\MerkezLogFile -U hakan%"Passw0rd" -W  -N -c "prompt; put dhcplog-$tarih.txt"

/usr/local/bin/smbclient \\\\20.0.0.15\\MerkezLogFile -U hakan%"Passw0rd" -W  -N -c "prompt; put $AUTH_LOG_FILE-$tarih.txt"

if [ -n "$HAS_T_LOG_FILE" ];
	then
		/usr/sbin/tcpdump -ttttqenr $P_T_LOG_FOLDER/$N_T_LOG_FILE | cat > $P_T_LOG_FOLDER/$N_T_LOG_FILE-$tarih.txt
		cd $P_T_LOG_FOLDER
		/usr/local/bin/smbclient \\\\20.0.0.15\\MerkezLogFile -U hakan%"Passw0rd" -W -N -c "prompt; put $N_T_LOG_FILE-$tarih.txt"
		/usr/bin/gzip -c $P_T_LOG_FOLDER/$N_T_LOG_FILE > $P_T_LOG_FOLDER/$N_T_LOG_FILE-$tarih.gz
		/bin/rm $P_T_LOG_FOLDER/$N_T_LOG_FILE-$tarih.txt
fi

/usr/sbin/tcpdump -tttt -e -n -i re1 -w $P_T_LOG_FOLDER/$N_T_LOG_FILE	& 
PID_TCPDUMP=`echo $!`  
sh $P_T_LOG_FOLDER/$KILL_ACTIVE_PID
echo $PID_TCPDUMP > $P_T_LOG_FOLDER/$ACTIVE_PID_FILE
cd ..
rm -rf /var/mountsamba
