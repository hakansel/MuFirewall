#!/bin/sh
service="cpaccd.sh cron syslogd squid.sh radisud"
# lower limit 5 min.
check_time_low="300"
# upper limig 7 min.
check_time_high="420"
#remote syslog server address
host_syslog_serv="10.100.1.14"
port_syslog_serv="5140"

for serv in $service
do
	#if it is not running it is null
	is_running=`/usr/sbin/service $serv status`
	if [ -n "$is_running" ]; then
		logger -t "INFO" -s "$serv is running.."
		if [ $serv == "syslogd" ]; then
			boot_time=`/sbin/sysctl -n kern.boottime | /usr/bin/wawk '{print $4}' | /usr/binsed 's/[^0-9]//g'`
			curr_time=`date +%s`
			up_time=$(($curr_time - $boot_time))
			if [ $up_time -gt  $check_time_low ] && [ $up_time -lt $check_time_high ]; then
				`/sbin/ping -c3 $host_syslog_serv`
				if [ $? -eq "0" ]; then
					is_restart=`/usr/sbin/service $serv restart`
					logger -t "INFO" -s "$serv is restarted."
				else
					date=`date "+%Y%m%d-%H%M%S"`
					logger -t "WARN" -s "$host_syslog_serv $port_syslog_serv is not available at $date.!!"
				fi
			fi
		fi
	else
		date=`date "+%Y%m%d-%H%M%S"`
		is_up=`/usr/sbin/service $serv start`
		if [ -z "$is_up" ]; then
			logger -t "ERROR" -s "$serv is not run at $date!!!"
		else
			logger -t "INFO" -s "$serv was run at $date."
		fi
	fi
done