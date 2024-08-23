#! /usr/bin/python3
import json
import requests
import sys

if len(sys.argv) != 4:
  sys.exit()

CMD, CONN, USER, SECRET = sys.argv

r = requests.get('%s/perf' % CONN, auth=(USER, SECRET))
data = r.json()
result = {}

for key in data.keys():
  if 'osd' not in key:
    continue

  total = data[key]['bluefs.db_total_bytes']['value']
  used = data[key]['bluefs.db_used_bytes']['value']
  result[key.lstrip('osd.')] = {
    'dbutil': 100*used/total,
  }

print(json.dumps({'osds': result},separators=(',', ':')))
