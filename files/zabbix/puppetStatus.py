#!/usr/bin/python3

import json
import re
import yaml

# Collect the regular run-statistics
with open('/opt/puppetlabs/puppet/public/last_run_summary.yaml', 'r') as f:
  try:
    data = yaml.safe_load(f)
  except:
    data = {}

# Collect log-lines from the last_run_report. Use a rudimentary search to only
# grab the 'logs' portion of the file to keep the runtime low.
with open('/opt/puppetlabs/puppet/cache/state/last_run_report.yaml', 'r') as f:
  loglines = []
  started = False
  startpattern = re.compile(r'^logs:')
  endpattern = re.compile(r'^[a-zA-Z]')

  for line in f.readlines():
    if startpattern.match(line) or started:
      started = True
      if endpattern.match(line) and not startpattern.match(line):
        break
      loglines.append(line)
  
# Interpret the collected information form last_run_report as yaml:
try:
  logdata = yaml.safe_load('\n'.join(loglines))
except:
  logdata = {}

# Create a summary counting amount of lines of a certain status
data['logdata'] = {'levels':{}}
for log in logdata['logs']:
  try:
    data['logdata']['levels'][log['level']] += 1
  except KeyError:
    data['logdata']['levels'][log['level']] = 1

# Return the collected data.
print(json.dumps(data))
