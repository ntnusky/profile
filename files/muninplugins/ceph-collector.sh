#!/bin/bash

if [[ ! $1 ]]; then
  echo "Usage: $0 <pool_name>"
  exit 1
else
  pool=$1
fi

values=("" "read" "write" "iops")
path="/run/shm/cephmon"

if [[ ! -d $path ]]; then
  mkdir $path
fi

j=598
while [[ 1 -eq 1 ]]; do
  i=1
  data=$(ceph-collect.sh $pool)
  for value in $data; do
    #echo ${values[$i]} $value
    echo $value >> $path/ceph-$pool-${values[$i]}
    ((i++))
  done
  ((j++))
  sleep 1
  if [[ $j -gt 600 ]]; then
    for i in $(seq 1 3); do
      value=${values[$i]}
      tail -n 400 $path/ceph-$pool-$value > $path/tmp-ceph-$pool-$value
      rm $path/ceph-$pool-$value
      mv $path/tmp-ceph-$pool-$value $path/ceph-$pool-$value
    done
    j=0
  fi
done
