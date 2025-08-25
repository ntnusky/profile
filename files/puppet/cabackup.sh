#!/bin/bash

backupsource='/etc/puppetlabs/puppetserver/ca'
backupdest="/var/opt/puppet/$(hostname)/"
sshprivkey='/etc/ssh/ssh_host_rsa_key'

backuparchive="puppetca-$(hostname)-$(date +%Y%m%d-%H%M%S).tgz"

logger "[Puppet-cabackup] Starting to backup puppetca certs"

if [[ ! -e /var/backups/puppetca ]]; then
  echo "[Puppet-cabackup] First time script is run. Create backup-catalog."
  logger "[Puppet-cabackup] First time script is run. Create backup-catalog."
  mkdir /var/backups/puppetca
  chmod 0700 /var/backups/puppetca
fi

if [[ ! -e /var/log/puppetcabackup ]]; then
  echo "[Puppet-cabackup] First time script is run. Create log-catalog."
  logger "[Puppet-cabackup] First time script is run. Create log-catalog."
  mkdir /var/log/puppetcabackup 
  chmod 0700 /var/log/puppetcabackup
fi

# Create a new backup-archive
logger "[Puppet-cabackup] Creating archive"
tar -czf "/var/backups/puppetca/${backuparchive}" "$backupsource" &> /dev/null
chmod 0600 "/var/backups/puppetca/${backuparchive}"

# Delete all but the 10 most recent
logger "[Puppet-cabackup] Deleting old catalogs"
cd /var/backups/puppetca/ || exit 3
ls -1tr | head -n -10 | xargs -d '\n' rm -- &> /dev/null
cd - &> /dev/null || exit 3

# Sync changes to the other puppet-masters.
while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ $line =~ puppetmaster-(.*) ]] ; then
    hostname=${BASH_REMATCH[1]}
    logger "[Puppet-cabackup] Syncing to $hostname"
    ssh-agent bash -c "ssh-add $sshprivkey; rsync -arv --delete /var/backups/puppetca ${hostname}:${backupdest}" \
        &> "/var/log/puppetcabackup/$hostname-$(date +%Y%m%d-%H%M%S).rsync.log"
  fi
done < "/root/.ssh/authorized_keys"

# Delete all but the most 1k recent logfiles
logger "[Puppet-cabackup] Deleting old logfiles"
cd /var/log/puppetcabackup/ || exit 3
ls -1tr | head -n -1000 | xargs -d '\n' rm -- &> /dev/null
cd - &> /dev/null || exit 3

logger "[Puppet-cabackup] Backup complete" 
exit 0
