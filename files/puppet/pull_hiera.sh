#!/bin/bash

repolocation='/etc/puppetlabs/puppet/data/'
sshprivkey='/etc/ssh/ssh_host_rsa_key'
any=0

logger "[pull-hieradata] Start to sync hiera from other puppetmasters"
while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ $line =~ puppetmaster-(.*) ]] ; then
    hostname=${BASH_REMATCH[1]}
    if [[ ! -d $repolocation ]]; then
      cd "$(dirname $repolocation)" || exit 2
      if ssh-agent bash -c \
          "ssh-add $sshprivkey; git clone ${hostname}:${repolocation}" &> \
          /dev/null; then
        logger "[pull-hieradata] Successfully cloned from ${hostname}"
        any=1
      else
        logger "[pull-hieradata] Could not clone from ${hostname}"
      fi
    else
      cd $repolocation || exit 2
      if ssh-agent bash -c \
          "ssh-add $sshprivkey; git pull ${hostname}:${repolocation} --no-edit" \
          &> /dev/null; then
        logger "[pull-hieradata] Successfully pulled from ${hostname}"
        any=1
      else
        logger "[pull-hieradata] Could not pull from ${hostname}"
      fi
    fi
  fi
done < "/root/.ssh/authorized_keys"

if [[ $any -eq 0 ]]; then
  echo "Could not pull hieradata from anyone!"
  logger "[pull-hieradata] Unable to retrieve hieradata."
fi

logger "[pull-hieradata] Finished sync of hieradata."
