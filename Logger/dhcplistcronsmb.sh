#!/bin/sh
#
# Abrrv.
#	N : name
#	P : path
#   
#	tarih: YYYYMMDD-HHMMSS
#	cdate: in sec precision(1424958939)

tarih=`date "+%Y%m%d-%H%M%S"`
c_date=$(date +%s)

# 5 hours
CONTROL_TIME="18000"

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
TEMP_ACCESS_LOG_FILE="temp_access.log"
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

N_IS_LOG_AUTH=is_authlog
N_IS_LOG_DHCP=is_dhcplog
N_IS_LOG_TCPDUMP=is_tcpdumplog
N_IS_LOG_ACCESS=is_accesslog

N_ACCESS_LOG_LINE_NUMBER=access_line_number

if [ ! -d "$P_T_LOG_FOLDER" ]; then
		mkdir /home/trafficlog
fi

PID_TCPDUMP=`/bin/ps -ax | /usr/bin/grep tcpdump | /usr/bin/grep $N_T_LOG_FILE | /usr/bin/awk '{ print $1 }'`
echo $PID_TCPDUMP
echo $PID_TCPDUMP > $ACTIVE_PID_FILE

cd $P_T_LOG_FOLDER

#cat /var/log/portalauth.log | grep "$AUTH_DATE" | awk '{ $4=$5=""; print $0 }' >  $AUTH_LOG_FILE-$FW_IP-$tarih.txt
/usr/local/sbin/clog /var/log/portalauth.log | grep "$AUTH_DATE" | grep logportalauth | grep -E '[0-2]?[0-9]?[0-9]\.[0-2]?[0-9]?[0-9]\.[0-2]?[0-9]?[0-9]\.[0-2]?[0-9]?[0-9]' |  awk '{ $4=$5=""; print $0}'  >  $AUTH_LOG_FILE-$FW_IP-$tarih.txt

awk -f $P_T_LOG_FOLDER/$TIB_FUNC < /var/dhcpd/var/db/dhcpd.leases > ./dhcplog-$FW_IP-$tarih.txt

pt_date=`/bin/cat $P_T_LOG_FOLDER/$N_LOG_DHCP`
tib_diff=$(($c_date - $pt_date))

if [ $tib_diff -gt $CONTROL_TIME ]; then
	pt_status=`/bin/cat $P_T_LOG_FOLDER/$N_IS_LOG_DHCP`
	if [ "$pt_status" != "1" ]; then
#/usr/local/bin/smbclient \\\\20.0.0.15\\MerkezLogFile -U hakan%"Passw0rd" -W  -N -c "prompt; put dhcplog-$tarih.txt"
/usr/local/bin/lftp -c "set ssl:verify-certificate no; open -u logpusher,logpusher11 10.100.1.12; put -O $REMOTE_TIB_LOG_FOLDER dhcplog-$FW_IP-$tarih.txt"
		if [ $? -eq 0 ]; then
				date_dhcp=`date "+%s"`
				echo $date_dhcp > $P_T_LOG_FOLDER/$N_LOG_DHCP
				echo "1" > $P_T_LOG_FOLDER/$N_IS_LOG_DHCP
		fi
	fi
fi

#pa_date: sec precision(1424958939)
pa_date=`/bin/cat $P_T_LOG_FOLDER/$N_LOG_AUTH`
auth_diff=$(($c_date - $pa_date))

if [ $auth_diff -gt $CONTROL_TIME ]; then
	pa_status=`/bin/cat $P_T_LOG_FOLDER/$N_IS_LOG_AUTH`
	if [ "$pa_status" != "1" ]; then
#/usr/local/bin/smbclient \\\\20.0.0.15\\MerkezLogFile -U hakan%"Passw0rd" -W  -N -c "prompt; put $AUTH_LOG_FILE-$tarih.txt"
/usr/bin/tar -cvzf $P_T_LOG_FOLDER/$N_COMPRESS_AUTH $AUTH_LOG_FILE-$FW_IP-$tarih.txt
/usr/local/bin/lftp -c "set ssl:verify-certificate no; open -u logpusher,logpusher11 10.100.1.12; put -O $REMOTE_LOG_FOLDER $N_COMPRESS_AUTH"
		if [ $? -eq 0 ];
			then
				date_auth=`date "+%s"`
				echo $date_auth > $P_T_LOG_FOLDER/$N_LOG_AUTH
				echo "1" > $P_T_LOG_FOLDER/$N_IS_LOG_AUTH
		fi
	fi
fi

echo $RES_AUTH > $P_T_LOG_FOLDER/ 

/usr/bin/tar -cvzf $P_T_LOG_FOLDER/$N_COMPRESS_AUTH_DHCP dhcplog-$FW_IP-$tarih.txt $AUTH_LOG_FILE-$FW_IP-$tarih.txt
rm dhcplog-$FW_IP-$tarih.txt $AUTH_LOG_FILE-$FW_IP-$tarih.txt


#
#	squid access log events.
# START

cd $P_ACCESS_LOG_FILE
HAS_T_ACCESS_LOG_FILE_NUMBER=`ls $P_T_LOG_FOLDER/$N_ACCESS_LOG_LINE_NUMBER`
if [ -n "$HAS_T_ACCESS_LOG_FILE_NUMBER" ]; then
	prev_line_number=`/bin/cat $P_T_LOG_FOLDER/$N_ACCESS_LOG_LINE_NUMBER`
	cp $P_ACCESS_LOG_FILE/$ACCESS_LOG_FILE $P_T_LOG_FOLDER/$TEMP_ACCESS_LOG_FILE-$FW_IP-$tarih.txt
	`/usr/bin/tail -n $prev_line_number $P_T_LOG_FOLDER/$TEMP_ACCESS_LOG_FILE-$FW_IP-$tarih.txt > $P_T_LOG_FOLDER/$ACCESS_LOG_FILE-$FW_IP-$tarih.txt`
else
	cp $P_ACCESS_LOG_FILE/$ACCESS_LOG_FILE $P_T_LOG_FOLDER/$ACCESS_LOG_FILE-$FW_IP-$tarih.txt
fi

cd $P_T_LOG_FOLDER
/usr/bin/tar -cvzf $P_T_LOG_FOLDER/$N_COMPRESS_ACCESSLOG $ACCESS_LOG_FILE-$FW_IP-$tarih.txt

HAS_T_ACCESS_LOG_DATE_FILE=`ls $P_T_LOG_FOLDER/$N_LOG_ACCESS`
if [ -z "$HAS_T_ACCESS_LOG_DATE_FILE" ]; then
	pac_date="0"
else
	pac_date=`/bin/cat $P_T_LOG_FOLDER/$N_LOG_ACCESS`
fi

access_diff=$(($c_date - $pac_date))

if [ $access_diff -gt $CONTROL_TIME ]; then
	HAS_T_ACCESS_LOG_FILE=`ls $P_T_LOG_FOLDER/$N_LOG_ACCESS`
	if [ -n "$HAS_T_ACESS_LOG_FILE"]; then
		pac_status=`/bin/cat $P_T_LOG_FOLDER/$N_IS_LOG_ACCESS`
		if [ "$pac_status" != "1" ]; then
	/usr/local/bin/lftp -c "set ssl:verify-certificate no; open -u logpusher,logpusher11 10.100.1.12; put -O $REMOTE_ACCESS_LOG_FOLDER $N_COMPRESS_ACCESSLOG"
			if [ $? -eq 0 ]; then
					date_acc=`date "+%s"`
					echo $date_acc > $P_T_LOG_FOLDER/$N_LOG_ACCESS
					echo "1" > $P_T_LOG_FOLDER/$N_IS_LOG_ACCESS
					`/usr/bin/wc -l $P_T_LOG_FOLDER/$ACCESS_LOG_FILE-$FW_IP-$tarih.txt | /usr/bin/awk '{ print $1 }' > $P_T_LOG_FOLDER/$N_ACCESS_LOG_LINE_NUMBER`		
			fi
		fi
	fi
fi

rm accesslog-$FW_IP-$tarih.txt $ACCESS_LOG_FILE-$FW_IP-$tarih.txt $P_T_LOG_FOLDER/$TEMP_ACCESS_LOG_FILE-$FW_IP-$tarih.txt

# END

if [ -n "$HAS_T_LOG_FILE" ]; then
		#/usr/sbin/tcpdump -ttttqenr $P_T_LOG_FOLDER/$N_T_LOG_FILE | cat > $P_T_LOG_FOLDER/$N_T_LOG_FILE-$FW_IP-$tarih.txt
		#/usr/bin/tar -cvzf $P_T_LOG_FOLDER/$N_COMPRESS_TCPDUMP $P_T_LOG_FOLDER/$N_T_LOG_FILE-$FW_IP-$tarih.txt 
		cd $P_T_LOG_FOLDER
		#/usr/local/bin/smbclient \\\\20.0.0.15\\MerkezLogFile -U hakan%"Passw0rd" -W -N -c "prompt; put $N_T_LOG_FILE-$tarih.txt"
		#/usr/local/bin/lftp -c "set ssl:verify-certificate no; open -u logpusher,logpusher11 10.100.1.12; put -O $REMOTE_LOG_FOLDER $N_COMPRESS_TCPDUMP"
		if [ $? -eq 0 ]; then
				echo $tarih > $P_T_LOG_FOLDER/$N_LOG_TCPDUMP
				echo "1" > $P_T_LOG_FOLDER/$N_IS_LOG_TCPDUMP
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
