#!/bin/sh

date=`date "+%s"`

P_CPACC_ROOT=/home/captiveportal
F_CPACC_PID=cpacc.pid

P_CPACC_ROOT=/root       
F_CPACC_SCRIPT=cp_access.sh

#/home/captiveportal not exist
if ! [ -d $P_CPACC_ROOT ]; then
	/bin/mkdir -p $P_CPACC_ROOT
fi

if [ -f $P_CPACC_ROOT/$F_CPACC_PID ]; then
	rm -f $P_CPACC_ROOT/$F_CPACC_PID 
fi

cd $P_CPACC_ROOT

./$F_CPACC_SCRIPT 2&> /dev/null
echo $! > $P_CPACC_ROOT/$F_CPACC_PID