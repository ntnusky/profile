#!/bin/bash

# This is a wrapper around sensu's check-http.rb. It will make an authenticated
# request to the given endpoint. And return a status

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

function prereq() {
  err=0
  if [ ! "$(which openstack)" ]; then
    echo "Openstack command missing"
    err=$STATE_UNKNOWN
  else
    OSCMD="$(which openstack)"
  fi

  CHECK_HTTP='/opt/sensu/embedded/bin/check-http.rb'
  if [ ! -e $CHECK_HTTP ]; then
    echo "check-http.rb is missing. Please install it"
    err=$STATE_UNKNOWN
  fi

  if [ $err -ne $STATE_OK ]; then
    exit $err
  fi
}

function usage() {
  echo "Usage: $0 [OPTIONS]"
  echo " -h                 Help"
  echo " -u <username>      Username to get a token"
  echo " -p <password>      Password to get a token"
  echo " -k <keystone-url>  URL to keystone for grabbing a token"
  echo " -e <endpoint-url>  URL to the endpoint you want to check"
}

prereq

while getopts 'hu:p:k:e:r:' OPTION; do
  case $OPTION in
    h)
      usage
      exit $STATE_OK
      ;;
    u)
      export OS_USERNAME="$OPTARG"
      ;;
    p)
      export OS_PASSWORD="$OPTARG"
      ;;
    k)
      export OS_AUTH_URL="$OPTARG"
      ;;
    e)
      ENDPOINT="$OPTARG"
      ;;
    r)
      RCODE="$OPTARG"
      ;;
    :)
      echo "Option -$OPTARG requires an argument"
      exit $STATE_WARNING
      ;;
    *)
      usage
      exit $STATE_WARNING
      ;;
  esac
done

if [ -z "$OS_USERNAME" ] || [ -z "$OS_PASSWORD" ] || [ -z "$ENDPOINT" ] || [ -z "$OS_AUTH_URL" ]; then
  echo "One more arguments missing"
  usage
  exit $STATE_WARNING
fi

# Puh. Time to get som actual work done:
export OS_IDENTITY_API_VERSION=3

token=$($OSCMD token issue -f value -c id)
if [ -z "$token" ]; then
  echo "CRITICAL - Could not get token from keystone. Service is either down, or you supplied invalid credentials"
  exit $STATE_CRITICAL
fi

if [ ! -z "$RCODE" ]; then
  rcode="--response-code $RCODE -r"
else
  rcode=""
fi

$CHECK_HTTP -H "X-Auth-Token: ${token}" -u "$ENDPOINT" $rcode
