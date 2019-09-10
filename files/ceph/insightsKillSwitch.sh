#!/bin/bash

# This is a 'strikk & binders' script to disable ceph insights if the /var disk
# gets too full. Basicly a kill-switch to avoid the ceph-mon's being stopped by
# a full drive.

# When /var is more full than this; disable insights
threshold=75

# Determine how full /var is.
current=$(/bin/df -h /var/ | /usr/bin/tail -n +2 | \
	    /usr/bin/awk '{ print $5 }' | /usr/bin/tr -d '%')

# If var is too full:
if [[ $threshold -le $current ]]; then
  # If the insights module is enabled
  if /usr/bin/ceph mgr module ls | /usr/bin/jq -C '.["enabled_modules"]' | \
        /bin/grep -q 'insights'; then
    # Disable the insights module
    /usr/bin/ceph mgr module disable insights
  fi
fi
