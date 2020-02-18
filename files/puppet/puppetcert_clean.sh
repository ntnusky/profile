#! /bin/bash

# If this machine isnt the puppetca; we cannot clean certs...
if [[ ! -e /etc/puppetlabs/puppet/ssl/ca/inventory.txt ]]; then
  exit 1
fi

logger "[PUPPET-CertClean] Starts to clean puppet certificates"

# Get a list over all hosts registerd in shiftleader
allslhosts=$(/opt/shiftleader/manage.py hostlist | sort)
noHosts=0
for host in $allslhosts; do
  ((noHosts++))
done
logger "[PUPPET-CertClean] Got a list of ${noHosts} hosts from shiftleader"

# If the list from shiftleader cannot be retrieved, ABORT!
if [[ $noHosts -le 1 ]]; then
  echo "Aborting, as the list from shiftleader is too short"
  logger "[PUPPET-CertClean] Aborting, as the list from shiftleader is too short"
  exit 2
fi

# Get a list over all hosts with a valid puppet client certificate
allcahosts=$(/opt/puppetlabs/bin/puppet cert list --all 2> /dev/null | \
    awk '{print $2}' | cut -d '"' -f 2)
noHosts=0
for host in $allcahosts; do
  ((noHosts++))
done
logger "[PUPPET-CertClean] Got a list of ${noHosts} hosts from puppetca"

# Loop trough all hosts which has a puppetcert, but is not listed in
# shiftleader:
toRevoke=()
for host in $(echo "${allslhosts[@]}" "${allslhosts[@]}" "${allcahosts[@]}" | \
    tr ' ' '\n' | sort | uniq -u); do
  logger "[PUPPET-CertClean] The host $host not in shiftleader anymore"
  # add the host to the list of certs to be revoked
  toRevoke=(${toRevoke[@]} $host)
done

# Retrieve a list over hosts in the "installing" state, and loop trough them
installinghosts=$(/opt/shiftleader/manage.py hostlist installing | sort)
for host in $installinghosts; do
  # If the host in installing have a puppet cert:
  if /opt/puppetlabs/bin/puppet cert print "$host"; then
    logger "[PUPPET-CertClean] The host $host is reinstalling"
    # add the host to the list of certs to be revoked
    toRevoke=(${toRevoke[@]} $host)
  fi
done

logger "[PUPPET-CertClean] There are ${#toRevoke[@]} certificates which should be revoked"

# If there are too many certs to be revoked; abort. Large changes should need manual intervention!
if [[ ${#toRevoke[@]} -gt 10 ]]; then
  logger "[PUPPET-CertClean] Aborting as there are too many certs to be revoked." 
  echo "Aborting! There are more than 10 certs shceduled for revocation:"
  for host in "${toRevoke[@]}"; do
    echo " - $host"
  done
  exit 2
fi

# Revoke the certificates identified for revokion.
for host in "${toRevoke[@]}"; do
  logger "[PUPPET-CertClean] Revoking the certificate for $host" 
  /opt/puppetlabs/bin/puppet cert clean "$host"
done

logger "[PUPPET-CertClean] Finished to clean puppet certificates"
exit 0
