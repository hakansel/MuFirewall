#!/bin/sh

##
##	manage of service status
##	manage the checking remote syslog or not
##
##
##


#
#	checking services start
#
N_ACCESS=access
N_RADIUS=radius
N_CRON=cron
N_SQUID=squid
N_SQUIDGUARD=

P_ACCESS=/usr/local/sbin/access
P_RADIUS=/usr/local/sbin/radiusd
P_CRON=/usr/sbin/cron
P_SQUID=/usr/local/sbin/squid
P_SQUIDGUARD=

start()
{
 service start $1
}

stop()
{
 service stop $1
}

restart()
{
 service stop $1
 service strat $2
}

PID_ACCESS=`/bin/pgrep $N_ACCESS`
PID_RADIUS=`/bin/pgrep $N_RADIUS`
PID_CRON=`/bin/pgrep $N_CRON`
PID_SQUID=`/bin/pgrep $N_SQUID`
PID_SQUIDGUARD=`/bin/pgrep $N_SQUIDGUARD`


if [[ -z "$PID_ACCESS" ]]; then
	# no running service
	start "$N_ACCESS"
fi

if [[ -z "$PID_RADIUS" ]]; then
	# no running service
	start "$N_RADIUS"
fi

if [[ -z "$PID_CRON" ]]; then
	# no running service
	start "$N_CRON"
fi

if [[ -z "$PID_SQUID" ]]; then
	# no running service
	start "$N_SQUID"
fi

if [[ -z "$PID_SQUIDGUARD" ]]; then
	# no running service
	start "$N_SQUIDGUARD"
fi
#
#	end
#

#
#	checking remote syslog succeed start
#
N_SYSLOG=syslog
REMOTE_SYSLOG_ADDR=10.100.1.14:5140
P_SYSLOG_CONF=/etc/syslog.conf

is_remote_syslog_running()
{
	retval=`/usr/bin/grep $REMOTE_SYSLOG_ADDR | $P_SYSLOG_CONF`
	if [[ -z "$retval" ]]; then
		echo "false"
	else
		echo "true"
	fi
}

if[ $(is_remote_syslog_running) == "false"]; then
	echo >> $P_SYSLOG_CONF;
	restart "$N_SYSLOG"
fi
#
#	end
#

#
#	check accessibility of log server start
#
LOGFW_IP=10.100.1.12

is_remote_accessible()
{
	/sbin/ping -c5 $1
	ping_ret=echo $?
	if [[ $retval == "0" ]]; then
		echo "true"
	else
		echo "false"
	fi
}

if[ $(is_remote_accessible $LOGFW_IP) == "false" ]; then

fi

#
#	end
#