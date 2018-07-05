#!/bin/bash

function helptext {
    echo "To see all servers:"
    echo "  $0 serverlist"
    echo "To see all backends:"
    echo "  $0 backendlist"
    echo "To enable all servers in a backend:"
    echo "  $0 enable backend <backend-name>"
    echo "To disable all servers in a backend:"
    echo "  $0 disable backend <backend-name>"
    echo "To enable a server in all backends:"
    echo "  $0 enable server <server-name>"
    echo "To disable a server in all backends:"
    echo "  $0 disable server <server-name>"
    echo "To disable all servers except one in a backend:"
    echo "  $0 only <backend-name> <server-name>"
    exit 1
}

if [[ $# -lt 1 ]]; then
  helptext
fi

case $1 in 
  serverlist)
    echo "The following servers is available:"
    cat /etc/haproxy/toolconfig.csv | grep ';' | cut -f 1 -d ';' | sort | uniq
    ;;

  backendlist)
    echo "The following backends is available:"
    cat /etc/haproxy/toolconfig.csv | grep ';' | cut -f 2 -d ';' | sort | uniq
    ;;

  disable|enable)
    if [[ $# -lt 3  || ! $2 =~ (server|backend) ]]; then
      helptext
    fi

    if [[ $2 == 'server' ]]; then
      for backend in $(egrep "^${3};.*\$" /etc/haproxy/toolconfig.csv | \
          cut -f '2' -d ';'); do
        echo "$1 the server $3 in the $backend backend."
        echo $1 server $backend/$3 | nc -U /var/lib/haproxy/stats
      done
    fi

    if [[ $2 == 'backend' ]]; then
      for server in $(egrep "^.*;${3}\$" /etc/haproxy/toolconfig.csv | \
          cut -f '1' -d ';'); do
        echo "$1 the server $server in the $3 backend."
        echo $1 server $3/$server | nc -U /var/lib/haproxy/stats
      done
    fi
    ;;

  only)
    if [[ $# -lt 3 ]]; then
      helptext
    fi

    if ! grep -sq "$3;$2" /etc/haproxy/toolconfig.csv; then
      echo "Could not find the server $3 in $2"
      exit 2
    fi

    echo "enable the server $3 in the $2 backend."
    echo enable server $2/$3 | nc -U /var/lib/haproxy/stats

    for server in $(egrep "^.*;${2}\$" /etc/haproxy/toolconfig.csv | \
        cut -f '1' -d ';'); do
      if [[ $server != $3 ]]; then
        echo "disable the server $server in the $2 backend."
        echo disable server $2/$server | nc -U /var/lib/haproxy/stats
      fi
    done
    ;;

  *)
    helptext
    ;;
esac
