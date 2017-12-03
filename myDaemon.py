#!/usr/bin/env python3
import sys
import os
import time
import argparse
import logging
import daemon
import socket
from daemon import pidfile

debug_p = False

def do_something(logf):
    ### This does the "work" of the daemon

    logger = logging.getLogger('myDaemon')
    logger.setLevel(logging.INFO)

    fh = logging.FileHandler(logf)
    fh.setLevel(logging.INFO)

    formatstr = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    formatter = logging.Formatter(formatstr)

    fh.setFormatter(formatter)

    logger.addHandler(fh)

    while True:
       # Create a TCP/IP socket
       sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

       # Bind the socket to the address given on the command line
       server_name = '192.168.0.34' # sys.argv[1]
       server_address = (server_name, 10000)
       #print('starting up on %s port %s' % server_address)
       logger.info("starting up on %s", server_address)
       sock.bind(server_address)
       sock.listen(1)

       while True:
          #print('waiting for a connection')
          logger.info("waiting for a connection")
          connection, client_address = sock.accept()
          try:
             #print('client connected:', client_address)
             logger.info("Client connected %s", client_address)
             while True:
                data = connection.recv(16)
                print('received "%s"' % data)
                if data:
                   connection.sendall(data)
                else:
                   break
          finally:
             connection.close()
             logger.info("client %s closed the connection!", client_address)
        #logger.debug("this is a DEBUG message")
        #logger.info("this is an INFO message")
        #logger.error("this is an ERROR message")
        #time.sleep(5)


def start_daemon(pidf, logf):
    ### This launches the daemon in its context

    ### XXX pidfile is a context
    with daemon.DaemonContext(
        working_directory='/home/pi/git/myDaemon',
        umask=0o002,
        pidfile=pidfile.TimeoutPIDLockFile(pidf),
        ) as context:
        do_something(logf)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Example daemon in Python")
    parser.add_argument('-p', '--pid-file', default='/var/run/myDaemon.pid')
    parser.add_argument('-l', '--log-file', default='/var/log/myDaemon.log')

    args = parser.parse_args()

    start_daemon(pidf=args.pid_file, logf=args.log_file)
