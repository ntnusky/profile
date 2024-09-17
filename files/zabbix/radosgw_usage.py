#!/usr/bin/python3
import json
import subprocess

report = subprocess.run(['sudo', '/usr/bin/radosgw-admin', 'usage', 'show'], 
  capture_output=True)
data = json.loads(report.stdout)

summary = {}
totals = {
  'bytes_sent': 0, 
  'bytes_received': 0, 
  'ops': 0,
  'successful_ops': 0, 
}

for s in data['summary']:
  for c in s['categories']:
    totals['bytes_sent'] += c['bytes_sent']
    totals['bytes_received'] += c['bytes_received']
    totals['ops'] += c['ops']
    totals['successful_ops'] += c['successful_ops']
    try:
      summary[c['category']]['bytes_sent'] += c['bytes_sent']
      summary[c['category']]['bytes_received'] += c['bytes_received']
      summary[c['category']]['ops'] += c['ops']
      summary[c['category']]['successful_ops'] += c['successful_ops']
    except KeyError:
      summary[c['category']] = {
        'category': c['category'],
        'bytes_sent': c['bytes_sent'],
        'bytes_received': c['bytes_received'],
        'ops': c['ops'],
        'successful_ops': c['successful_ops'],
      }

data = {
  'per_operation': summary,
  'totals': totals,
}

print(json.dumps(data))
