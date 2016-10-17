#!/bin/bash

if [[ ! $1 ]]; then
  echo "Usage: $0 <pool_name>"
  exit 1
else
  pool=$1
fi

declare -A units
units[k]=1024
units[M]=1048576
units[G]=1073741824

bytesRead=0
bytesWrite=0
iopsR=0
iopsW=0

clientio=$(ceph osd pool stats $pool | grep client)

if [[ $? == 0 ]]; then
  if [[ $clientio =~ ([0-9]*)\ ([kMG])?B/s\ rd ]]; then
    if [[ ${BASH_REMATCH[2]} ]]; then
      bytesRead=$(( ${BASH_REMATCH[1]} * ${units[${BASH_REMATCH[2]}]} ))
    else
      bytesRead=${BASH_REMATCH[1]}
    fi
  fi

  if [[ $clientio =~ ([0-9]*)\ ([kMG])?B/s\ wr ]]; then
    if [[ ${BASH_REMATCH[2]} ]]; then
      bytesWrite=$(( ${BASH_REMATCH[1]} * ${units[${BASH_REMATCH[2]}]} ))
    else
      bytesWrite=${BASH_REMATCH[1]}
    fi
  fi

  if [[ $clientio =~ ([0-9]*)\ op/s\ rd ]]; then
    iopsR=${BASH_REMATCH[1]}
  fi

  if [[ $clientio =~ ([0-9]*)\ op/s\ wr ]]; then
    iopsW=${BASH_REMATCH[1]}
  fi
fi

echo $bytesRead
echo $bytesWrite
echo $iopsR
echo $iopsW
