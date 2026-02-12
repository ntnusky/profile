#!/usr/bin/python3
import json
import re
import subprocess

versions = {
    'ipv4': 'birdc',
    'ipv6': 'birdc6',
}

patterns = {
    'state': re.compile(r'^.*BGP state:\s+(.+)$'),
    'neighbor-address': re.compile(r'^.*Neighbor address:\s+(.+)$'),
    'neighbor-as': re.compile(r'^.*Neighbor AS:\s+(.+)$'),
    'neighbor-id': re.compile(r'^.*Neighbor ID:\s+(.+)$'),
    'source-ip': re.compile(r'^.*Source address:\s+(.+)$'),
    'keepalive': re.compile(r'^.*Hold timer:\s+(\d+)/(\d+)$'),
    'holdtimer': re.compile(r'^.*Keepalive timer:\s+(\d+)/(\d+)$'),
}

def getProtocolStatus(version, process):
    birdc = subprocess.run(
        [ versions[version], 'show', 'protocols', 'all', process ],
        stderr=subprocess.DEVNULL, stdout=subprocess.PIPE,
    )

    data = {}
    for line in birdc.stdout.decode().split('\n'):
        for field in patterns:
            m = patterns[field].match(line)
            if(m and len(m.groups()) == 1):
                data[field] = m.group(1)
            elif(m and len(m.groups()) == 2):
                data[f'{field}-timer'] = m.group(1)
                data[f'{field}'] = m.group(2)

    return data

def getBGPStatus():
    processes = []
    protocols = []
    for version in versions:
        discovery = subprocess.run([versions[version], 'show', 'protocols'],
                stderr=subprocess.DEVNULL, stdout=subprocess.PIPE)
        if(discovery.returncode == 0):
            active = 1
            for line in discovery.stdout.decode().split('\n'):
                # Skip all other protocols than BGP
                parts = line.split()
                if(len(parts) < 2 or parts[1] != 'BGP'):
                    continue

                protocols.append(getProtocolStatus(version, parts[0]))
        else:
            active = 0

        processes.append({
            'active': active,
            'family': version,
        })

    return {
        'processes': processes,
        'protocols': protocols,
    }

if __name__ == '__main__':
    print(json.dumps(getBGPStatus()))
