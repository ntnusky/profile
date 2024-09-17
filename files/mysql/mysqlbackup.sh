#!/bin/bash
location="/var/backups"
filename="${location}/MysqlDump.$(date +%y%m%d%H%M%S).sql.gz"

logger "Staring mysql backup"
mysqldump --all-databases --single-transaction=TRUE | gzip > $filename
chmod 600 $filename
logger "Finished mysql backup"
