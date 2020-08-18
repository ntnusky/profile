#!/bin/bash

[[ $(cat /sys/block/${1}/queue/nr_requests) -eq $2 ]]
exit $?
