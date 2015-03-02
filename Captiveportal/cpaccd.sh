#!/bin/sh
# This file was automatically generated
# by the pfSense service handler.

rc_start() {
        if [ -z "`ps auxw | grep "cp_access.sh`" ];then
                sh /root/cpacc_launcher.sh
        fi

}

rc_stop() {
        cpacc_pid=`cat /root/cpacc.pid`
        kill -9 $cpacc_pid 2> /dev/null
        rm /root/cpacc.pid 2> /dev/null
}

case $1 in
        start)
                rc_start
                ;;
        stop)
                rc_stop
                ;;
        restart)
                rc_stop
                rc_start
                ;;
esac
