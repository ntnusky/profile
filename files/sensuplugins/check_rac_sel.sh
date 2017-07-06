#!/bin/bash

RACADM=$(which racadm)

if [ -z $RACADM ]; then
  severity="UNKNOWN"
  msg="racadm util missing. Please install it"
  exitcode=3
else
  while getopts "h:p:" opts; do
    case $opts in
      h) host=$OPTARG ;;
      p) password=$OPTARG ;;
    esac
  done

  RACCMD="$RACADM -r $host -u root -p $password"
  totalentries=$($RACCMD getsel -i | egrep -o '[[:digit:]]+')
  lastentry=$($RACCMD getsel -s $totalentries -o | tail -n1 | sed 's/\r//g' | sed 's/^ *//g')
  level=$(echo $lastentry | cut -d' ' -f4)
  if [ $level == "Ok" ]; then
    severity="OK"
    msg="No errors in last System Event Log entry"
    exitcode=0
  elif [ $level == "Warning" ]; then
    severity="WARNING"
    msg=$lastentry
    exitcode=1
  elif [ $level == "Critical" ]; then
    severity="CRITICAL"
    msg=$lastentry
    exitcode=3
  elif [ $level == "Non-Critical" ]; then
    severity="WARNING"
    msg=$lastentry
    exitcode=2
  else
    severity="UNKNOWN"
    msg=$lastentry
    exitcode=3
  fi
fi

echo "$severity - $msg"
exit $exitcode
