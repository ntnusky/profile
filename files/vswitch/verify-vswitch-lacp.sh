#!/bin/bash

if [[ $# -le 2 ]]; then
  echo "Usage: $0 <bond-name> <bond-if1> ... <bond-ifN>"
  exit 1
fi

bond=$1
shift

for interface in $@; do
  if ! ip link show $interface &> /dev/null; then
    echo "The interface $interface is not found"
    exit 2
  fi
  if ! ovs-appctl lacp/show | grep $interface &> /dev/null; then
    echo "The interface $interface is not in the bond"
    exit 3
  fi
done

exit 0
