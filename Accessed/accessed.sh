#!/bin/sh

tarih=`/bin/date "+%Y%m%d-%H%M%S"`
firewall_ip=`/sbin/ifconfig re1 | grep 'inet ' | awk '{print $2}'`

P_ACCESSED=/home/accessed
FUNC_ACCESSED=accessed_func.sh
F_ACCESSED=accessed-log-$tarih.json

cd $P_ACCESSED

./$FUNC_ACCESSED > $P_ACCESSED/$F_ACCESSED

/usr/local/bin/curl -H "Content-Type: application/json" -X POST --data @$F_ACCESSED --url http://10.10.10.10/MaviUcakFirewallService/MaviUcakFirewallService.svc/json/AccessedClientPackageUpload
#/usr/local/bin/curl -H "Content-Type: application/json" -X POST --data @$F_ACCESSED --url http://httpbin.org/post

if [ $? -ne 0 ]
then
	logger  -s "This time it is not completed to accessed site log $tarih."
fi

rm  $P_ACCESSED/$F_ACCESSED