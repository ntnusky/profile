#!/usr/bin/python3

import json
import yaml

with open('/opt/puppetlabs/puppet/public/last_run_summary.yaml', 'r') as f:
  try:
    data = yaml.safe_load(f)
  except:
    data = {}

print(json.dumps(data))
