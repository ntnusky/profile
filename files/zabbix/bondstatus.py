#! /usr/bin/python3
import os
import json
import subprocess

def parseValue(value):
  if value in ['true', 'True', 'yes', 'Yes']:
    return True
  elif value in [ 'false', 'False', 'No', 'no' ]:
    return False

  try:
    return int(value)
  except ValueError:
    return value.rstrip()

def parse(input, section = ''):
  statuses = {
    'enabled': 'disabled', 
    'current': 'defaulted',
    'attached': 'detatched',
    'active': 'passive',
  }

  if(type(input) == str):
    input = input.split('\n')

  data = {}
  subsection = data
  parent = None
  for line in input:
    if line.startswith('----'):
      continue

    if line.startswith('member'):
      elements = line.split(' ')
      membername = elements[1].rstrip(':')
      subsection = {}

      for status in elements[2:]:
        if status in statuses:
          subsection[status] = True
        elif status in statuses.values():
          subsection[
            list(statuses.keys())[list(statuses.values()).index(status)]
          ] = False

      try:
        data['members'][membername] = subsection
      except KeyError:
        data['members'] = {membername: subsection}
    elif line.startswith('Slave Interface'):
      elements = line.split(': ')
      membername = elements[1].rstrip()
      subsection = {}
      parent = None

      try:
        data['members'][membername] = subsection
      except KeyError:
        data['members'] = {membername: subsection}
    elif(line.startswith('details')):
      if not parent:
        parent = subsection

      subsection = {}
      parent['actor' if 'actor' in line else 'partner'] = subsection
    elif(line == '  active member'):
      pass
    elif(len(line.split(', ')) == 2):
      parts = line.split(', ')
      k1, v1 = parts[0].split(': ')
      subsection[k1] = parseValue(v1)
      k2, v2 = parts[1].split(': ')
      subsection[k2] = parseValue(v2)
    else: 
      try:
        key, value = line.split(': ')
        key = key.lstrip()
      except:
        continue

      if key.startswith('status'):
        for status in value.split(' '):
          if status in statuses:
            subsection[status] = True
          elif status in statuses.values():
            subsection[
              list(statuses.keys())[list(statuses.values()).index(status)]
            ] = False
      else:
        if key == 'may_enable':
          key = 'may_enable_%s' % section
        subsection[key] = parseValue(value)
  return data

def getOVSBonds():
  bonds = {}
  try:
    p = subprocess.run(['/usr/bin/ovs-appctl','bond/list'], capture_output=True, text=True)
  except:
    return bonds

  for line in p.stdout.split('\n')[1:]:
    try:
      bond, type, recircID, members = line.split('\t')
    except:
      continue
  
    bonds[bond] = {
      'name': bond,
      'type': 'ovs',
      'speed': 0,
    }
  
  for bond in bonds:
    # Add values from the bond/show command
    p = subprocess.run(['/usr/bin/ovs-appctl','bond/show', bond], capture_output=True, text=True)
    data = parse(p.stdout, 'bond')
  
    for key in ['bond_mode', 'lacp_status', 'members']:
      bonds[bond][key] = data[key]
  
    # Add some summary variables
    bonds[bond]['interfaces'] = 0
    bonds[bond]['interfaces_enabled'] = 0
  
    # Add data from the lacp/show command
    p = subprocess.run(['/usr/bin/ovs-appctl','lacp/show', bond], capture_output=True, text=True)
    data = parse(p.stdout, 'lacp')
    for key in ['sys_id', 'sys_priority', 'lacp_time']:
      bonds[bond][key] = data[key]
    
    for member in data['members']:
      try:
        with open('/sys/class/net/%s/speed' % member, 'r') as f:
          bonds[bond]['members'][member]['speed'] = int(f.read())
      except:
        bonds[bond]['members'][member]['speed'] = -1

      for key in ['actor sys_id', 'partner sys_id', 'may_enable_lacp', 
          'actor port_id', 'partner port_id']:
        bonds[bond]['members'][member][key] = data['members'][member][key]
  
      bonds[bond]['interfaces'] += 1

      if bonds[bond]['members'][member]['speed'] > 0:
        bonds[bond]['speed'] += bonds[bond]['members'][member]['speed']

      if bonds[bond]['members'][member]['enabled']:
        bonds[bond]['interfaces_enabled'] += 1

  return bonds

def getSystemBonds():
  data = {}

  try:
    bonds = os.listdir('/proc/net/bonding')
  except:
    return data

  for bond in bonds:
    with open(os.path.join('/proc/net/bonding', bond), 'r') as f:
      bonddata = parse(f.readlines())

    data[bond] = {
      'name': bond, 
      'type': 'system',
      'bond_mode': bonddata['Transmit Hash Policy'],
      'lacp_status': 'configured' if 'Partner Mac Address' in bonddata else 'negotiated',
      'members': {},
      'interfaces': len(bonddata['members']),
      'interfaces_enabled': 0,
      'sys_id': bonddata['System MAC address'],
      'sys_priority': bonddata['System priority'],
      'lacp_time': bonddata['LACP rate'],
      'speed': 0,
    }

    for member in bonddata['members']:
      data[bond]['members'][member] = {
        'bond_name': bond,
        'interface_name': member,
        'enabled': bonddata['members'][member]["MII Status"] == "up",
        'may_enable_bond': bonddata['members'][member]["MII Status"] == "up",
        'may_enable_lacp': True,
        'actor sys_id': 
          bonddata['members'][member]['actor']['system mac address'],
        'partner sys_id': 
          bonddata['members'][member]['partner']['system mac address'],
        'actor port_id':
          bonddata['members'][member]['actor']['port number'],
        'partner port_id':
          bonddata['members'][member]['partner']['port number'],
      }

      if(data[bond]['members'][member]['enabled']):
        data[bond]['interfaces_enabled'] += 1

      try:
        data[bond]['members'][member]['speed'] = \
            int(bonddata['members'][member]['Speed'].split(' ')[0])
      except ValueError:
        data[bond]['members'][member]['speed'] = 0

      if data[bond]['members'][member]['speed'] > 0:
        data[bond]['speed'] += data[bond]['members'][member]['speed']

  return data


bonds = {}

bonds.update(getOVSBonds())
bonds.update(getSystemBonds())

print(json.dumps(bonds))
