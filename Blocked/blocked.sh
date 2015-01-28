#!/bin/sh

tarih=`/bin/date "+%Y%m%d-%H%M%S"`
firewall_ip=`/sbin/ifconfig re1 | grep 'inet ' | awk '{print $2}'`

P_BLOCKED=/home/blocked
FUNC_BLOCKED=blocked_func.sh
F_BLOCKED=blocked-log-$tarih.json

cd $P_BLOCKED

./$FUNC_BLOCKED > $P_BLOCKED/$F_BLOCKED

/usr/local/bin/curl -H "Content-Type: application/json" -X POST --data @$F_BLOCKED --url http://10.10.10.10/MaviUcakFirewallService/MaviUcakFirewallService.svc/json/BlockedClientPackageUpload
#/usr/local/bin/curl -H "Content-Type: application/json" -X POST --data @$F_BLOCKED --url http://httpbin.org/post

if [ $? -ne 0 ]
then
	logger  -s "This time it is not completed to blocked site log $tarih."
fi

rm  $P_BLOCKED/$F_BLOCKED