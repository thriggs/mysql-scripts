#!/bin/bash

BACKUP_DIFF=$((`date +%s` - `tail -1 /root/.mysql-backup.log`))

if [[ $BACKUP_DIFF -gt 7200 ]]
then
	echo "Last mysql backup date is older than 2 hours: $BACKUP_DIFF seconds";
	exit 1002;
fi
