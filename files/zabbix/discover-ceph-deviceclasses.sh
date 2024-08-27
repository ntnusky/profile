#!/bin/bash

first=1

echo -n '['
for class in $(ceph df -f json | jq '.["stats_by_class"] | keys | .[]' -r); do
  if [[ $first -eq 1 ]]; then 
    echo 
    first=0
  else
    echo ','
  fi

  echo -n "  {\"{#OSDCLASS}\":\"$class\"}"
done

echo
echo ']'
