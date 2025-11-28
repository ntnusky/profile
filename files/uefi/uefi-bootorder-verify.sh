#!/bin/bash
set -e

primary="(NIC|Network)"
secondary="ubuntu"

order=$(efibootmgr | grep "BootOrder:" | cut -f 2 -d ' ')
primaryID=$(efibootmgr | grep -E $primary | grep -Po '^Boot\K[0-9]{4}' | tr '\n' ',' | sed 's/,$//g')
secondaryID=$(efibootmgr | grep $secondary | grep -Po '^Boot\K[0-9]{4}' | tr '\n' ',' | sed 's/,$//g')

if [[ -z $order || -z $primaryID || -z $secondaryID ]]; then
  echo "Failed to detect boot-order"
  exit 1
fi

if [[ $order =~ ^${primaryID},${secondaryID} ]]; then
  echo "The boot-order is correct"
  exit 0
else
  echo "The boot-order is wrong"
  exit 2
fi
