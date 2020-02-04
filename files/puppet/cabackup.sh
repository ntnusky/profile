#!/bin/bash

backupsource='/etc/puppetlabs/puppet/ssl/ca'
backupdest="/var/opt/puppet/$(hostname)/"
sshprivkey='/etc/ssh/ssh_host_rsa_key'

backuparchive="puppetca-$(hostname)-$(date +%Y%m%d-%H%M%S).tgz"

if [[ ! -e /var/backups/puppetca ]]; then
  mkdir /var/backups/puppetca
  chmod 0700 /var/backups/puppetca
fi

# Create a new backup-archive
tar -czf /var/backups/puppetca/$backuparchive $backupsource &> /dev/null
chmod 0600 /var/backups/puppetca/$backuparchive

# Delete all but the 10 most recent
cd /var/backups/puppetca/
ls -1tr | head -n -10 | xargs -d '\n' rm --
cd -

# Sync changes to the other puppet-masters.
while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ $line =~ puppetmaster-(.*) ]] ; then
    hostname=${BASH_REMATCH[1]}
    ssh-agent bash -c "ssh-add $sshprivkey; rsync -arv --delete /var/backups/puppetca ${hostname}:${backupdest}"
  fi
done < "/root/.ssh/authorized_keys"
