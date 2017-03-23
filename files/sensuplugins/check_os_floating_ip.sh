#!/bin/bash

# Arguments:
#
# -p Password for admin user in admin project
# -u URL to keystone v3 public API
# -s Name of external subnet
# -w Warning threshold - free floating IPs. Defaults to 100
# -c Critical threshold - free floating IPs. Defaults to 50

function getPoolSize {
  echo "(2^(32-$1))-3" | bc
}

while getopts "p:u:s:w:c:" opts; do
  case $opts in
    p) password=$OPTARG ;;
    u) url=$OPTARG ;;
    s) subnet=$OPTARG ;;
    w) warning=$OPTARG ;;
    c) critical=$OPTARG ;;
  esac
done

export OS_PROJECT_NAME="admin"
export OS_USERNAME="admin"
export OS_PASSWORD=$password
export OS_AUTH_URL=$url
export OS_IDENTITY_API_VERSION=3

if [ -z $warning ]; then
  warning=100
fi

if [ -z $critical ]; then
  critical=50
fi

total=$(openstack ip floating list -f value | wc -l)
netmask=$(openstack subnet show $subnet -f value -c cidr | cut -d'/' -f2)

if [ ! -z $total ] && [ ! -z $netmask ]; then
  poolsize=$(getPoolSize $netmask)
else
  msg="UNKNOWN"
  exitcode=3
  echo "$msg - No response from API"
  exit $exitcode
fi

free=$(($poolsize - $total))

if [ $free -le $critical ]; then
  msg="CRITICAL"
  exitcode=2
elif [ $free -le $warning ]; then
  msg="WARNING"
  exitcode=1
else
  msg="OK"
  exitcode=0
fi

echo "$msg - $free of $poolsize floating IPs available in pool."
exit $exitcode
