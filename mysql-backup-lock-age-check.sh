#!/bin/bash
LOCK_FILE='/root/mysql-backup.lock'

if test `find "$LOCK_FILE" -mmin +120`
then
    echo "$LOCK_FILE" is older than two hours. MySQL Dump may have failed.
    rm -f $LOCK_FILE;
    exit 1002;
fi
