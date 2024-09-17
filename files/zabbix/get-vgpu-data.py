#!/usr/bin/env python3

import json
from zabbix_vgpu import getGPUData

data = getGPUData()

print(json.dumps(data))
