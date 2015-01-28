#!/bin/sh
tarih=`date "+%Y%m%d-%H%M%S"`

REMOTE_LOG_FOLDER=firewalllog
REMOTE_TIB_LOG_FOLDER=tiblog
REMOTE_ACCESS_LOG_FOLDER=accesslog
FW_IP=`/sbin/ifconfig re1 | grep 'inet ' | awk '{print $2}'`

TIB_FUNC=dhcptib.sh

ACTIVE_PID_FILE="activetcpdump.pid"

KILL_ACTIVE_PID="killactivetcpdump.sh"

AUTH_DATE=`date | awk '{ print $2 " " $3 }'`
AUTH_LOG_FILE="authanticationlog"

ACCESS_LOG_FILE="access.log"
P_ACCESS_LOG_FILE="/var/squid/logs"

N_T_LOG_FILE="wholetrafficlog.pcap"
P_T_LOG_FOLDER="/home/trafficlog"

HAS_T_LOG_FOLDER=`find /home -type d | grep trafficlog`
HAS_T_LOG_FILE=`ls $P_T_LOG_FOLDER/$N_T_LOG_FILE`

N_COMPRESS_AUTH_DHCP=auth_dhcp_log-$tarih-$FW_IP.tar.gz
N_COMPRESS_TCPDUMP=wholetraffic-$tarih-$FW_IP.tar.gz
N_COMPRESS_AUTH=auth-$tarih-$FW_IP.tar.gz
N_COMPRESS_ACCESSLOG=accesslog-$FW_IP-$tarih.tar.gz

N_LOG_AUTH=authlog_date 
N_LOG_DHCP=dhcplog_date 
N_LOG_TCPDUMP=tcpdumplog_date 
N_LOG_ACCESS=accesslog_date

if [ ! -d "$P_T_LOG_FOLDER" ]
	then
		mkdir /home/trafficlog
fi

PID_TCPDUMP=`/bin/ps -ax | /usr/bin/grep tcpdump | /usr/bin/grep $N_T_LOG_FILE | /usr/bin/awk '{ print $1 }'`
echo $PID_TCPDUMP
echo $PID_TCPDUMP > $ACTIVE_PID_FILE

cd $P_T_LOG_FOLDER

#cat /var/log/portalauth.log | grep "$AUTH_DATE" | awk '{ $4=$5=""; print $0 }' >  $AUTH_LOG_FILE-$FW_IP-$tarih.txt
/usr/local/sbin/clog /var/log/portalauth.log | grep "$AUTH_DATE" | grep logportalauth | grep -E '[0-2]?[0-9]?[0-9]\.[0-2]?[0-9]?[0-9]\.[0-2]?[0-9]?[0-9]\.[0-2]?[0-9]?[0-9]' |  awk '{ $4=$5=""; print $0}'  >  $AUTH_LOG_FILE-$FW_IP-$tarih.txt

awk -f $P_T_LOG_FOLDER/$TIB_FUNC < /var/dhcpd/var/db/dhcpd.leases > ./dhcplog-$FW_IP-$tarih.txt

#/usr/local/bin/smbclient \\\\20.0.0.15\\MerkezLogFile -U hakan%"Passw0rd" -W  -N -c "prompt; put dhcplog-$tarih.txt"
/usr/local/bin/lftp -c "set ssl:verify-certificate no; open -u logpusher,logpusher11 10.100.1.12; put -O $REMOTE_TIB_LOG_FOLDER dhcplog-$FW_IP-$tarih.txt"
if [ $? -eq 0 ];
	then
		echo $tarih > $P_T_LOG_FOLDER/$N_LOG_DHCP
fi
#/usr/local/bin/smbclient \\\\20.0.0.15\\MerkezLogFile -U hakan%"Passw0rd" -W  -N -c "prompt; put $AUTH_LOG_FILE-$tarih.txt"
/usr/bin/tar -cvzf $P_T_LOG_FOLDER/$N_COMPRESS_AUTH $AUTH_LOG_FILE-$FW_IP-$tarih.txt
/usr/local/bin/lftp -c "set ssl:verify-certificate no; open -u logpusher,logpusher11 10.10.10.10; put -O $REMOTE_LOG_FOLDER $N_COMPRESS_AUTH"
if [ $? -eq 0 ];
	then
		echo $tarih > $P_T_LOG_FOLDER/$N_LOG_AUTH
fi
echo $RES_AUTH > $P_T_LOG_FOLDER/ 
/usr/bin/tar -cvzf $P_T_LOG_FOLDER/$N_COMPRESS_AUTH_DHCP dhcplog-$FW_IP-$tarih.txt $AUTH_LOG_FILE-$FW_IP-$tarih.txt
rm dhcplog-$FW_IP-$tarih.txt $AUTH_LOG_FILE-$FW_IP-$tarih.txt

cd $P_ACCESS_LOG_FILE

cp $P_ACCESS_LOG_FILE/$ACCESS_LOG_FILE $P_T_LOG_FOLDER/$ACCESS_LOG_FILE-$FW_IP-$tarih.txt

cd $P_T_LOG_FOLDER
/usr/bin/tar -cvzf $P_T_LOG_FOLDER/$N_COMPRESS_ACCESSLOG $ACCESS_LOG_FILE-$FW_IP-$tarih.txt

/usr/local/bin/lftp -c "set ssl:verify-certificate no; open -u logpusher,logpusher11 10.10.10.10; put -O $REMOTE_ACCESS_LOG_FOLDER $N_COMPRESS_ACCESSLOG"
if [ $? -eq 0 ];
	then
		echo $tarih > $P_T_LOG_FOLDER/$N_LOG_ACCESS
fi

rm accesslog-$FW_IP-$tarih.txt $ACCESS_LOG_FILE-$FW_IP-$tarih.txt

if [ -n "$HAS_T_LOG_FILE" ];
	then
		#/usr/sbin/tcpdump -ttttqenr $P_T_LOG_FOLDER/$N_T_LOG_FILE | cat > $P_T_LOG_FOLDER/$N_T_LOG_FILE-$FW_IP-$tarih.txt
		#/usr/bin/tar -cvzf $P_T_LOG_FOLDER/$N_COMPRESS_TCPDUMP $P_T_LOG_FOLDER/$N_T_LOG_FILE-$FW_IP-$tarih.txt 
		cd $P_T_LOG_FOLDER
		#/usr/local/bin/smbclient \\\\10.10.10.10\\MerkezLogFile -U hakan%"Passw0rd" -W -N -c "prompt; put $N_T_LOG_FILE-$tarih.txt"
		#/usr/local/bin/lftp -c "set ssl:verify-certificate no; open -u logpusher,logpusher11 10.10.10.10; put -O $REMOTE_LOG_FOLDER $N_COMPRESS_TCPDUMP"
		if [ $? -eq 0 ];
			then
				echo $tarih > $P_T_LOG_FOLDER/$N_LOG_TCPDUMP
		fi
		#/usr/bin/gzip -c $P_T_LOG_FOLDER/$N_T_LOG_FILE > $P_T_LOG_FOLDER/$N_T_LOG_FILE-$FW_IP-$tarih.gz
		#/bin/rm $P_T_LOG_FOLDER/$N_T_LOG_FILE-$FW_IP-$tarih.gz
		#/bin/rm $P_T_LOG_FOLDER/$N_T_LOG_FILE-$FW_IP-$tarih.txt
fi

#/usr/sbin/tcpdump -tttt -e -n -i re1 -w $P_T_LOG_FOLDER/$N_T_LOG_FILE	& 
PID_TCPDUMP=`echo $!`  
sh $P_T_LOG_FOLDER/$KILL_ACTIVE_PID
echo $PID_TCPDUMP > $P_T_LOG_FOLDER/$ACTIVE_PID_FILE
cd ..
