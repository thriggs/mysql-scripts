#!/bin/bash
LOCK_FILE='/root/mysql-backup.lock'

if [[ -f "$LOCK_FILE" ]]; then
    echo "Backup already in progress\n"
    exit 1;
fi

touch $LOCK_FILE;

mysql --defaults-extra-file=/root/.my.cnf -e 'STOP SLAVE';

for DB in $(mysql --defaults-extra-file=/root/.my.cnf -e 'show databases' -s --skip-column-names); do
    /usr/bin/mysqldump --defaults-extra-file=/root/.my.cnf $DB | gzip > ~/backups/$DB.$(date +%F.%H%M%S).sql.gz
done

mysql --defaults-extra-file=/root/.my.cnf -e 'START SLAVE';

rm $LOCK_FILE;
echo `date +%s` >> /root/.mysql-backup.log;
