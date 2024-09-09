#!/usr/bin/python3
import json
import subprocess
import sys

if len(sys.argv) == 1:
  sys.exit(1)

report = subprocess.run(["/usr/bin/ceph", "tell", 'osd.%s' % sys.argv[1], 'perf', 'dump'], capture_output=True)
data = json.loads(report.stdout)

print(json.dumps({
  'db_total': data['bluefs']['db_total_bytes'],
  'db_used': data['bluefs']['db_used_bytes'],
  'wal_total': data['bluefs']['wal_total_bytes'],
  'wal_used': data['bluefs']['wal_used_bytes'],
  'slow_total': data['bluefs']['slow_total_bytes'],
  'slow_used': data['bluefs']['slow_used_bytes'],
}))
