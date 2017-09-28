#!/bin/bash
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <hostname> <port>"
  exit 1
fi

var=$(psql -h $1 -U postgres -p $2 -c 'SELECT pg_is_in_recovery();' -qtA)

if [[ $var == 'f' ]]; then
  exit 0
else
  exit 1
fi
