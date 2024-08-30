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
    'dbsize': total,
    'dbused': used,
    'op_latency': data[key]['osd.op_latency']['value'],
    # Read
    'op_r_latency': data[key]['osd.op_r_latency']['value'],
    # Write
    'op_w_latency': data[key]['osd.op_w_latency']['value'],
    # Read-modify-write
    'op_rw_latency': data[key]['osd.op_rw_latency']['value'],
    # PG's
    'numpg': data[key]['osd.numpg']['value'],
    # Size
    'stat_bytes': data[key]['osd.stat_bytes']['value'],
    # Used size
    'stat_bytes_used': data[key]['osd.stat_bytes_used']['value'],
  }

print(json.dumps({'osds': result},separators=(',', ':')))
