#!/bin/bash

if [[ $# -le 3 ]]; then
  echo "Usage: $0 <bridge-name> <bond-name> <bond-if1> ... <bond-ifN>"
  exit 1
fi

bridge=$1
bond=$2
shift;shift

if ! ovs-vsctl br-exists $bridge; then
  echo "Cannot find the bridge $bridge"
  exit 2
fi

for interface in $@; do
  if ! ip link show $interface &> /dev/null; then
    echo "The interface $interface is not found"
    exit 3
  fi
  if ovs-vsctl iface-to-br $interface &>/dev/null && [[ $(ovs-vsctl iface-to-br $interface) != $bridge ]] ; then
    echo "One of the interfaces is already assigned to another bridge!"
    exit 4
  fi
done

if ovs-vsctl list-ports $bridge | grep $bond &> /dev/null; then
  for interface in $@; do
    if ! ovs-appctl lacp/show | grep $interface &> /dev/null; then
      echo $interface
      bonderror=1
    fi
  done

  if [[ ! -z $bonderror ]]; then
    echo "At least one interface is missing in the bond. Re-creating it."
    ovs-vsctl del-port $bridge $bond -- add-bond $bridge $bond $@ lacp=active
  fi
else 
  toRemove=()
  cmd=""
  for interface in $@; do
    if ovs-vsctl iface-to-br $interface &>/dev/null; then
      toRemove+=($interface)
      cmd+="del-port $bridge $interface --"
    fi
  done
  echo "Creating $bond with the interfaces: $@"
  ovs-vsctl $cmd add-bond $bridge $bond $@ lacp=active
fi

# Set the bond to load-balance TCP streams
ovs-vsctl set port $bond bond_mode=balance-tcp

# In case the switch fails to negotiate LACP; fall back to regular active-backup
# bonding.
ovs-vsctl set port $bond other_config:lacp-fallback-ab=true

exit 0
