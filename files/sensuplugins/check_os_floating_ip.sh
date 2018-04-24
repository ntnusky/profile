#!/bin/bash

# Arguments:
#
# -p Password for admin user in admin project
# -u URL to keystone v3 public API
# -s Name of external network
# -w Warning threshold - free floating IPs. Defaults to 100
# -c Critical threshold - free floating IPs. Defaults to 50

while getopts "p:u:s:w:c:" opts; do
  case $opts in
    p) password=$OPTARG ;;
    u) url=$OPTARG ;;
    s) subnet=$OPTARG ;;
    w) warning=$OPTARG ;;
    c) critical=$OPTARG ;;
  esac
done

export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_NAME="admin"
export OS_USERNAME="admin"
export OS_PASSWORD=$password
export OS_AUTH_URL=$url
export OS_IDENTITY_API_VERSION=3

projectid=$(openstack project show $OS_PROJECT_NAME -f value -c id)
export OS_PROJECT_ID=$projectid

if [ -z $warning ]; then
  warning=100
fi

if [ -z $critical ]; then
  critical=50
fi

stats=$(neutron net-ip-availability-list --network-name $subnet -f value -c total_ips -c used_ips)
total=$(echo $stats | cut -d' ' -f1)
used=$(echo $stats | cut -d' ' -f2)

if [ ! -z "${stats}" ]; then
  free=$(($total - $used))
else
  msg="UNKNOWN"
  exitcode=3
  echo "$msg - No response from API"
  exit $exitcode
fi

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

echo "$msg - $free of $total floating IPs available in pool."
exit $exitcode
