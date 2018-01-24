#!/bin/bash

repolocation='/var/lib/tftpboot/acl/'
sshprivkey='/etc/ssh/ssh_host_rsa_key'

while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ $line =~ routeracl-(.*) ]] ; then
    hostname=${BASH_REMATCH[1]}
    if [[ ! -d $repolocation ]]; then
      cd $(dirname $repolocation)
      ssh-agent bash -c "ssh-add $sshprivkey; git clone ${hostname}:${repolocation}"
    else
      cd $repolocation
      ssh-agent bash -c "ssh-add $sshprivkey; git pull ${hostname}:${repolocation} --no-edit"
    fi
  fi
done < "/root/.ssh/authorized_keys"
