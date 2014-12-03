#!/bin/sh

GIT_ADDR=https://github.com/hakansel05/MuFirewall

TARIH=`date "+%Y%m%d-%H%M%S"`

EXC_CP=/bin/cp
EXC_MKDIR=/bin/mkdir
EXC_GIT=/usr/local/bin/git
EXC_CHMOD=/bin/chmod

# path of git project on local
P_GIT_PROJECT=/home/MuFirewall
P_GIT_BLACKLIST=/home/MuFirewall/Blacklist
P_GIT_LOGGER=/home/MuFirewall/Logger
P_GIT_MONITORING=/home/MuFirewall/Monitoring

# on server file names with extensions
F_S_BLACKLIST=blacklist_update.sh
F_S_BLACKLIST_FUNC=blocked_func.sh
F_S_LOGGER=dhcplistcronsmb.sh
F_S_LOGGER_TOOL=killactivetcpdump.sh
F_S_MONITORING=monitorservice.sh
F_S_MONITORING_FUNC=stats_func.sh
F_S_GIT_CHECKER=git_checker.sh

# path of scripts in local system that known by env
P_L_BLACKLIST=/sbin
P_L_BLACKLIST_FUNC=/home/blocked
P_L_LOGGER=/sbin
P_L_LOGGER_FUNC=/home/trafficlog
P_L_MONITORING=/sbin
P_L_MONITORING_FUNC=/home/monitoring
P_L_CHECKER=/sbin

cd $P_GIT_PROJECT

RES_PULL=`/usr/local/bin/git pull`

if [ "$RES_PULL" = "Already up-to-date." ];
	then
		logger -s $RES_PULL
else
	#replace new files with the old one until there are no running script. 
	while [ `ps aux | grep $F_S_LOGGER | grep -v grep | wc -l` -eq 0 ];
		do
			echo $F_S_LOGGER
			$EXC_CHMOD +x $P_GIT_LOGGER/$F_S_LOGGER
			$EXC_CP $P_GIT_LOGGER/$F_S_LOGGER $P_L_LOGGER
			$EXC_CHMOD +x $P_GIT_LOGGER/$F_S_LOGGER_TOOL
			$EXC_CP $P_GIT_LOGGER/$F_S_LOGGER_TOOL $P_L_LOGGER_FUNC
	done

	while [ `ps aux | grep $F_S_MONITORING | grep -v grep | wc -l` -eq 0 ];
		do
			echo $F_S_MONITORING
			$EXC_CHMOD +x $P_GIT_MONITORING/$F_S_MONITORING
			$EXC_CP $P_GIT_MONITORING/$F_S_MONITORING $P_L_MONITORING
			$EXC_CHMOD +x $P_GIT_MONITORING/$F_S_MONITORING_FUNC
			$EXC_CP $P_GIT_MONITORING/$F_S_MONITORING_FUNC $P_L_MONITORING_FUNC
	done

	while [ `ps aux | grep $F_S_BLACKLIST | grep -v grep | wc -l` -eq 0 ];
		do
			echo $F_S_BLACKLIST
			$EXC_CHMOD +x $P_GIT_BLACKLIST/$F_S_BLACKLIST
			$EXC_CP $P_GIT_BLACKLIST/$F_S_BLACKLIST $P_L_BLACKLIST
			$EXC_CHMOD +x $P_GIT_BLACKLIST/$F_S_BLACKLIST_FUNC
			$EXC_CP $P_GIT_BLACKLIST/$F_S_BLACKLIST_FUNC $P_L_BLACKLIST_FUNC		
	done

	while [ `ps aux | grep $F_S_GIT_CHECKER | grep -v grep | wc -l` -eq 0 ];
		do
			echo $F_S_GIT_CHECKER
			$EXC_CHMOD +x $P_GIT_PROJECT/$F_S_GIT_CHECKER
			$EXC_CP $P_GIT_PROJECT/$F_S_GIT_CHECKER $P_L_CHECKER			
	done

fi
