#!/bin/bash
share='/mnt/backup'

if grep -q "$share" /etc/fstab ; then
  mount $share
  /usr/local/sbin/mysqlbackupclean.py "${share}/$(hostname)"
  umount $share
else
  logger "Skipped cleaning of mysql-backups due to missing mount-declaration"
  exit 1
fi
