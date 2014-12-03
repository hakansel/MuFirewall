#!/bin/sh

tarih=`/bin/date "+%Y%m%d-%H%M%S"`
ip=`/sbin/ifconfig re1 | grep 'inet ' | awk '{print $2}'`

MONITORING_PATH=/home/monitoring
MONITORING_SCRIPT=stats_func.sh
MONITORING_FILE=monitor-$ip-$tarih.json

cd $MONITORING_PATH

./$MONITORING_SCRIPT > $MONITORING_PATH/$MONITORING_FILE

#/usr/local/bin/curl -H "Content-Type: application/json" -X POST --data @$MONITORING_FILE --url http://20.0.0.15:139
#/usr/local/bin/curl -H "Content-Type: application/json" -X POST --data @$MONITORING_FILE --url http://20.0.0.15:91/MaviUcakFirewallService.svc/json/MonitoringPackageUpload
/usr/local/bin/curl -H "Content-Type: application/json" -X POST --data @$MONITORING_FILE --url http://httpbin.org/post 

if [ $? -ne 0 ]
then
	logger  "This time it is not completed to monitoring $tarih."
else
	rm  $MONITORING_PATH/$MONITORING_FILE
fi
