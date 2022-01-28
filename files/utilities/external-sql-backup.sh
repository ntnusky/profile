#!/bin/bash

# This backup script works for both MySQL and PostgreSQL backups
# in the NTNU Openstack Clouds. Typically invoked via cron

# In a cluster, only one host needs to run this.

# Make sure you have an entry in fstab for the NFS share
# you intend to backup to.

# We typically do this with a mount resource in puppet

set -e

SOURCE='/var/backups/'
DEST='/mnt/backup'

if grep -q "$DEST" /etc/fstab ; then
  mount $DEST
  rsync -rv --delete --ignore-existing \
           --include="*/" \
           --include="*sql.gz" \
           --exclude="*" ${SOURCE} ${DEST}/$(hostname)
  umount $DEST
fi
