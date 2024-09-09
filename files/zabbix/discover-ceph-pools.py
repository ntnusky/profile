#!/usr/bin/python3
import json
import subprocess

report = subprocess.run(["/usr/bin/ceph", "report"], capture_output=True)
data = json.loads(report.stdout)

crush_rules = {x['rule_id']: x['rule_name'] for x in data['crushmap']['rules']}
pools = [{
  '{#POOLNAME}': x['pool_name'], 
  '{#POOLID}': x['pool'], 
  '{#CRUSHRULE}': crush_rules[x['crush_rule']]
} for x in data['osdmap']['pools']]

print(json.dumps(pools))
