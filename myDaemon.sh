#!/bin/bash
#
# myDaemon      Startup script for myDaemon
#
# chkconfig: - 87 12
# description: myDaemon is a dummy Python-based daemon
# config: /etc/myDaemon/myDaemon.conf
# config: /etc/sysconfig/myDaemon
# pidfile: /var/run/myDaemon.pid
#
### BEGIN INIT INFO
# Provides: myDaemon
# Required-Start: $local_fs
# Required-Stop: $local_fs
# Short-Description: start and stop myDaemon server
# Description: myDaemon is a dummy Python-based daemon
### END INIT INFO

# Source function library.
. /lib/lsb/init-functions

if [ -f /etc/sysconfig/myDaemon ]; then
        . /etc/sysconfig/myDaemon
fi

myDaemon=/home/pi/git/myDaemon/myDaemon.py
prog=myDaemon
pidfile=${PIDFILE-/var/run/myDaemon.pid}
logfile=${LOGFILE-/var/log/myDaemon.log}
RETVAL=0

OPTIONS=""

start() {
        echo -n $"       Starting $prog:      "

        if [[ -f ${pidfile} ]] ; then
            pid=$( cat $pidfile  )
            isrunning=$( ps -elf | grep  $pid | grep $prog | grep -v grep )

            if [[ -n ${isrunning} ]] ; then
                echo $"$prog already running"
                return 0
            fi
        fi
        $myDaemon -p $pidfile -l $logfile $OPTIONS
        RETVAL=$?
        [ $RETVAL = 0 ] && log_success_msg || log_failure_msg
        echo
        return $RETVAL
}

stop() {
    if [[ -f ${pidfile} ]] ; then
        pid=$( cat $pidfile )
        isrunning=$( ps -elf | grep $pid | grep $prog | grep -v grep | awk '{print $4}' )

        if [[ ${isrunning} -eq ${pid} ]] ; then
            echo -n $"Stopping $prog: "
            kill $pid
        else
            echo -n $"Stopping $prog: "
            success
        fi
        RETVAL=$?
    fi
    echo
    return $RETVAL
}

reload() {
    echo -n $"Reloading $prog: "
    echo
}

# See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status -p $pidfile $eg_daemon
    RETVAL=$?
    ;;
  restart)
    stop
    start
    ;;
  force-reload|reload)
    reload
    ;;
  *)
    echo $"Usage: $prog {start|stop|restart|force-reload|reload|status}"
    RETVAL=2
esac

exit $RETVAL
