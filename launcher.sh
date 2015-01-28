#!/bin/sh

SCRIPT_PATH=/home/
GIT_REPO=https://github.com/hakansel05/MuFirewall

HAS_LFTP=`/usr/sbin/pkg_info | /usr/bin/grep lftp | /usr/bin/wc -l`
HAS_REPO=`/bin/ls /home | /usr/bin/grep fwscript | /usr/bin/wc -l`

function Creater() {
	/bin/mkdir /home/accessed
	/bin/mkdir /home/blocked
	/bin/mkdir /home/trafficlog
	/bin/mkdir /home/monitoring

	/bin/cp /home/fwscript/Accessed/accessed_func.sh /home/accessed/
	/bin/chmod +x /home/accessed/accessed_func.sh
	/bin/cp /home/fwscript/Accessed/accessed.sh /sbin/
	/bin/chmod +x /sbin/accessed.sh
	/bin/cp /home/fwscript/Blacklist/blacklist_update.sh /sbin/
	/bin/chmod +x /sbin/blacklist_update.sh
	/bin/cp /home/fwscript/Blocked/blocked_func.sh /home/blocked/
	/bin/chmod +x /home/fwscript/blocked/blocked_func.sh  
	/bin/cp /home/fwscript/Blocked/blocked.sh /sbin/
	/bin/chmod +x /sbin/blocked.sh 
	/bin/cp /home/fwscript/Captiveportal/cp_status.sh /sbin/
	/bin/chmod +x /sbin/cp_status.sh 
	/bin/cp /home/fwscript/Cleaner/log_cleaner.sh /sbin/
	/bin/chmod +x /sbin/log_cleaner.sh 
	/bin/cp Cleaner/config_cleaner.sh /sbin/
	/bin/chmod +x /sbin/config_cleaner.sh
	/bin/cp Logger/dhcplistcronsmb.sh /sbin/
	/bin/chmod +x /sbin/dhcplistcronsmb.sh 
	/bin/cp /home/fwscript/Logger/dhcptib.sh /home/trafficlog/
	/bin/chmod +x /home/fwscript/trafficlog/dhcptib.sh 
	/bin/cp /home/fwscript/Logger/killactivetcpdump.sh /home/trafficlog/
	/bin/chmod +x /home/fwscript/trafficlog/killactivetcpdump.sh
	/bin/cp /home/fwscript/Monitoring/monitorservice.sh /sbin/
	/bin/chmod +x /sbin/monitorservice.sh 
	/bin/cp /home/fwscript/Monitoring/stats_func.sh /home/monitoring/
	/bin/chmod +x /home/monitoring/stats_func.sh
	/bin/cp /home/fwscript/git_checker.sh /sbin
	/bin/chmod +x /sbin/git_checker.sh
}

if [ $HAS_LFTP -eq "1" ];
	then
		if [ $HAS_REPO -eq "1"];
			then
				Creater
		else
			echo "You have not scripts from git repository."
			echo "Script will be downloaded... to "$SCRIPT_PATH
			setenv GIT_SSL_NO_VERIFY true
			/usr/local/bin/git clone $GIT_REPO
			if [ $? -eq "0"];
				then
					Creater
					echo "All configuration are made successfully.."
					echo "To test scripts please run rehash command on terminal."
			fi

else
	echo "lftp package is not installed in system."
	echo "You can install with:"
	echo "		pkg_add –r ftp://ftp.freebsd.org/pub/FreeBSD/ports/i386/packages-8-stable/All/lftp-4.4.15.tbz"
	echo "After instal run "rehash" command on terminal."
fi