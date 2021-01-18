#!/bin/bash

LOCK_FILE='/root/mysql-backup.lock'

if [[ -f "$LOCK_FILE" ]]; then
    echo "MySQL Backup in progress";
    exit;
fi

### VARIABLES ###
SERVER=$(hostname)
MYSQL_CHECK=$(/usr/bin/mysql --defaults-extra-file=/root/.my.cnf -e "SHOW VARIABLES LIKE '%version%';" || echo 1)
LAST_ERRNO=$(/usr/bin/mysql --defaults-extra-file=/root/.my.cnf -e "SHOW SLAVE STATUS\G" | grep "Last_Errno" | awk '{ print $2 }')
SECONDS_BEHIND_MASTER=$(/usr/bin/mysql --defaults-extra-file=/root/.my.cnf -e "SHOW SLAVE STATUS\G"| grep "Seconds_Behind_Master" | awk '{ print $2 }')
IO_IS_RUNNING=$(/usr/bin/mysql --defaults-extra-file=/root/.my.cnf -e "SHOW SLAVE STATUS\G" | grep "Slave_IO_Running" | awk '{ print $2 }')
EXITCODE=0

### Run Some Checks ###

## Check if I can connect to Mysql ##
if [ "$MYSQL_CHECK" == 1 ]
then
    echo "CAN'T CONNECT TO MYSQL\n";
    exit 1002;
fi

## Check For Last Error ##
if [ "$LAST_ERRNO" != 0 ]
then
    echo "Error when processing relay log (Last_Errno)\n"
    echo $LAST_ERRNO;
    EXITCODE=1002;
fi

## Check if IO thread is running ##
if [ "$IO_IS_RUNNING" != "Yes" ]
then
    echo "I/O thread for reading the master's binary log is not running (Slave_IO_Running)";
    EXITCODE=1002;
fi

## Check how slow the slave is ##
if [ "$SECONDS_BEHIND_MASTER" == "NULL" ]
then
    echo "The Slave is reporting 'NULL' (Seconds_Behind_Master)";
    EXITCODE=1002;

elif [ "$SECONDS_BEHIND_MASTER" -gt "60" ]
then
    echo "The Slave is at least $SECONDS_BEHIND_MASTER seconds behind the master (Seconds_Behind_Master)";
    EXITCODE=1002;
fi

echo $SECONDS_BEHIND_MASTER "seconds behind master";
exit $EXITCODE;
