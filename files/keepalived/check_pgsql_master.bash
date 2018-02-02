#!/bin/bash
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <hostname> <port>"
  exit 1
fi

var=$(psql -h $1 -U postgres -p $2 -c 'SELECT pg_is_in_recovery();' -qtA)
iscluster=$(psql -h $1 -U postgres -p $2 -c '\l' -qtA | grep -c puppetdb)

if [[ $var == 'f' ]]; then
  if [[ $iscluster -ne 0 ]]; then
    exit 0
  else
    exit 2
  fi
else
  exit 3
fi
