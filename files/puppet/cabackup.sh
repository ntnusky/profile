#!/bin/bash

backupsource='/etc/puppetlabs/puppet/ssl/ca'
backupdest="/var/opt/puppet/$(hostname)/"
sshprivkey='/etc/ssh/ssh_host_rsa_key'

while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ $line =~ puppetmaster-(.*) ]] ; then
    hostname=${BASH_REMATCH[1]}
    ssh-agent bash -c "ssh-add $sshprivkey; rsync -arv $backupsource ${hostname}:${backupdest}"
  fi
done < "/root/.ssh/authorized_keys"
