#!/usr/bin/python3
import json
import subprocess

report = subprocess.run(['/usr/bin/ceph', 'df', '-f', 'json'], capture_output=True)
data = json.loads(report.stdout)

print(json.dumps([
  {'{#CLASS}': c } for c in data['stats_by_class'].keys()
]))
