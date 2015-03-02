#!/bin/sh
# This file was automatically generated
# by the pfSense service handler.

service=cpaccd.sh
launcher=/root/cpacc_launcher.sh
pid_file=/root/cpacc.pid

rc_start() {
        if [ -z "`ps auxw | grep "cp_access.sh`" ]; then
                sh $launcher
        fi
}

rc_stop() {
        cpacc_pid=`cat $pid_file`
        kill -9 $cpacc_pid 2> /dev/null
        rm $pid_file 2> /dev/null
}

case $1 in
        start)
                if [ -z "`cat $pid_file`" ]; then
                        logger -s Starting $service
                        sleep 1
                        rc_start
                else
                        psr=`cat $pid_file`
                        logger -s $service is already running with pid = $psr
                fi
                ;;
        stop)
                if [ -n "`cat $pid_file`" ]; then
                        logger -s Stopping $service
                        sleep 1
                        rc_stop
                else
                        logger -s There are no running $service service to stop!!
                fi
                ;;
        restart)
                if [ -f $pid_file ]; then
                        logger -s Stopping $service
                        sleep 1
                        rc_stop
                else
                        logger -s There are no running $service service to stop!!
                fi
                logger -s Starting $service
                sleep 1
                rc_start        
                ;;
        status)
                if ! [ -f $pid_file ]; then
                        logger -s $service service is not running!!
                else
                        if [ -n "`cat $pid_file`"  ]; then
                                pid=`cat $pid_file`
                                logger -s $service service is running with pid = $pid
                        fi
                fi
esac