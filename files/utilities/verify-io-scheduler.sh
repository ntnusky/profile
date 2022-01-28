#!/bin/bash

[[ $(cat /sys/block/${1}/queue/scheduler | grep -Eo '\[(.*)\]' | grep -E '[a-z\-]+' -o) == $2 ]]
exit $?
