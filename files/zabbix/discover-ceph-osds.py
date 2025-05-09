#!/usr/bin/python3
import json
import subprocess

report = subprocess.run(["/usr/bin/ceph", "report"], capture_output=True)
data = json.loads(report.stdout)

osds = {}
for osd in data['crushmap']['devices']:
  # Skip osd's in crushmap thats not actually there. This happens when we remove
  # disks from ceph and the OSD-numbering is not continious.
  if('device' in osd['name']):
    continue

  osds['osd.%d' % osd['id']] = {
    '{#OSDNAME}': osd['id'],
  }
  if 'class' in osd:
    osds['osd.%d' % osd['id']]['{#CLASS}'] = osd['class']

for osd in data['osd_metadata']:
  osds['osd.%d' % osd['id']]['{#HOST}'] = osd['hostname']

print(json.dumps([osds[id] for id in osds]))

