#! /bin/bash

if [[ ! -e /etc/puppetlabs/puppet/ssl/ca/inventory.txt ]]; then
  echo "Cannot run this script as this machine is not the puppetca"
  exit 1
fi

# Get a list over all hosts registerd in shiftleader
allslhosts=$(/opt/shiftleader/manage.py hostlist | sort)
# Get a list over all hosts with a valid puppet client certificate
allcahosts=$(puppet cert list --all | awk '{print $2}' | cut -d '"' -f 2)

# Loop trough all hosts which has a puppetcert, but is not listed in
# shiftleader:
for host in $(echo ${allslhosts[@]} ${allslhosts[@]} ${allcahosts[@]} | \
    tr ' ' '\n' | sort | uniq -u); do
  # Delete the cert
  puppet cert clean $host
done

# Retrieve a list over hosts in the "installing" state, and loop trough them
installinghosts=$(/opt/shiftleader/manage.py hostlist installing | sort)
for host in $installinghosts; do
  # If the host in installing have a puppet cert:
  puppet cert print $host &> /dev/null
  if [[ $? -eq 0 ]]; then
    # Delete it.
    puppet cert clean $host
  fi
done
