#! /bin/bash

if [[ ! -e /etc/puppetlabs/puppet/ssl/ca/inventory.txt ]]; then
  echo "Cannot run this script as this machine is not the puppetca"
  exit 1
fi

logger "Starts to clean puppet certificates"

# Get a list over all hosts registerd in shiftleader
allslhosts=$(/opt/shiftleader/manage.py hostlist | sort)
noHosts=$(echo $allslhosts | wc -l)
logger "Got a list of ${noHosts} hosts from shiftleader"

if [[ $noHosts -le 1 ]]; then
  echo "Aborting, as the list from shiftleader is too short"
  logger "Aborting, as the list from shiftleader is too short"
  exit 2
fi

# Get a list over all hosts with a valid puppet client certificate
allcahosts=$(/opt/puppetlabs/bin/puppet cert list --all | awk '{print $2}' | \
    cut -d '"' -f 2)
noHosts=$(echo $allcahosts | wc -l)
logger "Got a list of ${noHosts} hosts from puppetca"

# Loop trough all hosts which has a puppetcert, but is not listed in
# shiftleader:
for host in $(echo ${allslhosts[@]} ${allslhosts[@]} ${allcahosts[@]} | \
    tr ' ' '\n' | sort | uniq -u); do
  logger "Deleting the cert for $host as it is not in shiftleader anymore"
  # Delete the cert
  /opt/puppetlabs/bin/puppet cert clean $host
done

# Retrieve a list over hosts in the "installing" state, and loop trough them
installinghosts=$(/opt/shiftleader/manage.py hostlist installing | sort)
for host in $installinghosts; do
  # If the host in installing have a puppet cert:
  /opt/puppetlabs/bin/puppet cert print $host &> /dev/null
  if [[ $? -eq 0 ]]; then
    logger "Deleting the cert for $host as the host is reinstalling"
    # Delete it.
    /opt/puppetlabs/bin/puppet cert clean $host
  fi
done
