#!/bin/sh
ACTIVE_PID_FILE="activetcpdump.pid"
ACTIVE_PID_NO=`cat $ACTIVE_PID_FILE`
echo $ACTIVE_PID_NO
/bin/kill -9 $ACTIVE_PID_NO 
