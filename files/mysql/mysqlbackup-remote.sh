#!/bin/bash
location="/var/backups"
share='/mnt/backup'
filename="${location}/MysqlDump.$(date +%y%m%d%H%M%S).sql.gz"

logger "Staring mysql backup"
mysqldump --all-databases | gzip > $filename
chmod 600 $filename
logger "Finished mysql backup"

logger "Starting to move backups to external storage"

if grep -q "$share" /etc/fstab ; then
  mount $share
  rsync -rv --include="*/" --include="*sql.gz" \
    --exclude="*" "${location}/" "${share}/$(hostname)"
  status=$?
  umount $share

  if [[ $status -ne 0 ]]; then
    logger "Failed to move backups to external storage"
  fi
else
  logger "Skipped moving and cleaning due to missing mound-declaration"
  exit 1
fi

logger "Finished moving backups to external storage"

logger "Deleting local copy of backups"
rm "${location}/MysqlDump*"
logger "MYSQL-Backup-script is finished"
