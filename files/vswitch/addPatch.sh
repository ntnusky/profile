#!/bin/bash

ALLOK=0
MISSING=1
ERROR=2

STATUS=$ALLOK

if [[ $# -le 1 ]]; then
  echo "Missing arguments."
  echo "Usage: $0 <source-bridge> <destination-bridge> [source-VLAN] [--verify]"
  exit $MISSING
fi

# Parse arguments.
#  - First two are source/destination
src=$1
dst=$2
shift;shift

# Next might be a VLAN ID for the source bridge
vlan=0
if [[ $1 =~ ^[0-9]+$ ]]; then
  vlan=$1
  shift
fi

# And the last might be a flag signaling that the script should just 
# verify the configuration; not apply new config.
verify=0
if [[ $1 == '--verify' ]]; then
  verify=1
  shift
fi

# Verify that the brdges exists
ovs-vsctl br-exists $src
if [[ $? -eq 2 ]]; then
  echo "The bridge $src does not exist"
  exit $ERROR
fi
ovs-vsctl br-exists $dst
if [[ $? -eq 2 ]]; then
  echo "The bridge $dst does not exist"
  exit $ERROR
fi

srcPort="patch-${src}-TO-${dst}"
dstPort="patch-${dst}-TO-${src}"

# Verify that the ports exist 
exists=$(ovs-vsctl list-ports $src | grep -c $srcPort)
if [[ $exists -eq 0 ]]; then
  echo "The port $srcPort does not exist on the bridge $src"
  STATUS=$MISSING
  if [[ $verify -eq 0 ]]; then
    ovs-vsctl add-port $src $srcPort
    exists=1
  fi
fi
# Verify that the port is of the correct type
if [[ $exists -eq 1 && $(ovs-vsctl get interface $srcPort type) != "patch" ]]; then
  echo "The port $srcPort is not of the type \"patch\""
  STATUS=$MISSING
  if [[ $verify -eq 0 ]]; then
    ovs-vsctl set interface $srcPort type=patch
  fi
fi
# Verify that the port is connected to the correct peer
if [[ $exists -eq 1 && \
    $(ovs-vsctl get interface $srcPort options:peer) != "\"$dstPort\"" ]]; then
  echo "The port $srcPort is does not have the peer $dstPort configured"
  STATUS=$MISSING
  if [[ $verify -eq 0 ]]; then
    ovs-vsctl set interface $srcPort options:peer=$dstPort
  fi
fi
# Verify that the port is attached to the correct VLAN (if applicable)
if [[ $exists -eq 1 && $vlan -ne 0 && \
    $(ovs-vsctl get port $srcPort tag) != $vlan ]]; then
  echo "The port $srcPort does not have the VLAN tag $vlan"
  STATUS=$MISSING
  if [[ $verify -eq 0 ]]; then
    ovs-vsctl set port $srcPort tag=$vlan
  fi
fi

# Verify that the ports exist 
exists=$(ovs-vsctl list-ports $dst | grep -c $dstPort)
if [[ $exists -eq 0 ]]; then
  echo "The port $dstPort does not exist on the bridge $dst"
  STATUS=$MISSING
  if [[ $verify -eq 0 ]]; then
    ovs-vsctl add-port $dst $dstPort
    exists=1
  fi
fi
# Verify that the port is of the correct type
if [[ $exists -eq 1 && $(ovs-vsctl get interface $dstPort type) != "patch" ]]; then
  echo "The port $dstPort is not of the type \"patch\""
  STATUS=$MISSING
  if [[ $verify -eq 0 ]]; then
    ovs-vsctl set interface $dstPort type=patch
  fi
fi
# Verify that the port is connected to the correct peer
if [[ $exists -eq 1 && \
    $(ovs-vsctl get interface $dstPort options:peer) != "\"$srcPort\"" ]]; then
  echo "The port $dstPort is does not have the peer $srcPort configured"
  STATUS=$MISSING
  if [[ $verify -eq 0 ]]; then
    ovs-vsctl set interface $dstPort options:peer=$srcPort
  fi
fi

exit $STATUS
