#!/bin/bash

# This is a script which lists out all r10k processes, and sends a signal 9
# (SIGKILL) to processes which have run more than the configured number of
# minutes. This is needed because r10k from time to time just hangs with 100%
# cpu for eternity.

maxminutes=30

while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ $line =~ \
      ^(([0-9]{0,2})\-?([0-9]{2}):([0-9]{2}):[0-9]{2})\ ([0-9]+)\ (.*)$ ]]
  then
    pid=${BASH_REMATCH[5]}

    # Processes existing for a really long time might have a number indicating
    # days first. In that case, read it. Otherwise, days = 0.
    if [[ -z ${BASH_REMATCH[2]} ]]; then
      days=0
    else
      days=10#${BASH_REMATCH[2]}
    fi

    # Make sure variables are interpreted in base-10
    h=10#${BASH_REMATCH[3]}
    m=10#${BASH_REMATCH[4]}

    # Calculate number of minutes
    hours=$(($days*24+$h))
    minutes=$(($hours*60+$m))

    # If enough minutes, print a message and kill the process.
    if [[ $minutes -gt $maxminutes ]]; then
      echo R10k process $pid was killed, as it had more than $maxminutes \
          minutes CPU time.
      kill -9 $pid
    fi
  fi
done < <(ps -A -o time -o pid -o cmd | grep r10k)
