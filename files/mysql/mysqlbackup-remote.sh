#!/bin/bash
location="/var/backups"
share='/mnt/backup'
filename="${location}/MysqlDump.$(date +%y%m%d%H%M%S).sql.gz"

logger "Staring mysql backup"
mysqldump --all-databases --single-transaction=TRUE | gzip > $filename
chmod 600 $filename
logger "Finished mysql backup"

logger "Starting to move backups to external storage"

if grep -q "$share" /etc/fstab ; then
  mount $share
  sharesize=$(df  /mnt/backup/ | tail -n 1 | awk '{ print $2 }')
  usedbefore=$(df  /mnt/backup/ | tail -n 1 | awk '{ print $3 }')
  rsync -rv --include="*/" --include="*sql.gz" \
    --exclude="*" "${location}/" "${share}/$(hostname)"
  status=$?
  usedafter=$(df  /mnt/backup/ | tail -n 1 | awk '{ print $3 }')
  umount $share

  if [[ $status -ne 0 ]]; then
    logger "Failed to move backups to external storage"
    jq -n '{status: 0}' > /var/cache/mysqlbackupstatus.json
  else
    jq -n --arg size ${sharesize} --arg before ${usedbefore} --arg after ${usedafter} \
      '{size: $size, before: $before, after: $after, status: 1}' > /var/cache/mysqlbackupstatus.json
  fi
else
  logger "Skipped moving and cleaning due to missing mount-declaration"
  exit 1
fi

logger "Finished moving backups to external storage"

logger "Deleting local copy of backups"
rm ${location}/MysqlDump*
logger "MYSQL-Backup-script is finished"
