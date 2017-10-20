#!/bin/bash
location="/var/backups"
filename="${location}/PostgresDump.$(date +%y%m%d%H%M%S).pgsql.gz"

if [[ $# -ne 1 ]]; then
  echo "Usage: $1 <pgsql_ip>"
  exit 1
fi

logger "Staring postgres backup"
pg_dumpall -U postgres -h $1 | gzip > $filename
logger "Finished postgres backup"
