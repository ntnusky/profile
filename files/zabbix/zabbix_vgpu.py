#!/usr/bin/python3
import ast
import configparser
import os
import re
import subprocess

def parseNvidiaSMI():
  process = subprocess.Popen(['nvidia-smi', 'vgpu', '-q'],
                       stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE)
  stdout, stderr = process.communicate()

  data = {}
  current = None
  stack = []
  indent = 0

  for l in stdout.splitlines():
    line = l.decode("utf-8")

    if(len(line.lstrip().rstrip()) == 0):
      continue

    # If the line signals that we start a new GPU, reset data-structures
    gpuline = re.match(r"^GPU (.*)", line)
    if(gpuline):
      data[gpuline.group(1)] = {}
      current = data[gpuline.group(1)]
      indent = 4
      continue

    # If the current line is indented less than the last one; go up a level
    while(not line.startswith(" " * indent)):
      current = stack.pop()
      indent -= 4

    try:
      # Split key/value and remove whitespace
      key, value = line.split(':', maxsplit=1)
      key = key.rstrip().lstrip()
      value = value.rstrip().lstrip()
      if(len(value) == 0):
        raise ValueError
      if(key == "vGPU ID"):
        if("VGPUs" not in current):
          current["VGPUs"] = {}
        current["VGPUs"][value] = {}
        stack.append(current)
        current = current["VGPUs"][value]
        indent = indent + 4
      else:
        current[key] = value
    except ValueError:
      key = line.rstrip(': ').lstrip()
      current[key] = {}
      stack.append(current)
      current = current[key]
      indent += 4

  return data

def getGPUTypesMdev(nova_conf):
  enabled_types = [t.strip() for t in nova_conf['devices']['enabled_mdev_types'].split(',')]
  gpus = {}
  for t in enabled_types:
    addresses = nova_conf['mdev_%s' % t]['device_addresses'].split(',')
    for address in addresses:
      gpus[address] = t

  return gpus

def getGPUTypesSRIOV(conf):
  devices = []
  gpus = {}
  with open(conf,'r') as nova_conf:
    for line in nova_conf:
      if line.startswith('device_spec'):
        devices.append(ast.literal_eval(line.rstrip('\n').split('=')[-1]))

  for device in devices:
    address = device['address']
    with open('/sys/bus/pci/devices/%s/nvidia/current_vgpu_type' % address,'r') as current_vgpu_type:
      gpus[address] = current_vgpu_type.read().rstrip('\n')

  return gpus

def getGPUTypes():
  NOVA_CONF_FILE='/etc/nova/nova.conf'
  nova_conf = configparser.ConfigParser(strict=False)
  nova_conf.read(NOVA_CONF_FILE)

  if 'device_spec' in nova_conf['pci']:
    return getGPUTypesSRIOV(NOVA_CONF_FILE)
  elif 'enabled_mdev_types' in nova_conf['devices']:
    return getGPUTypesMdev(nova_conf)
  else:
    return {}

# Open the VGPU description-file to get VGPU parameters.
def getVGPUDescription(gpu, vgpu_type):
  path = '/sys/class/mdev_bus/%s/mdev_supported_types/%s/description' % (
    gpu, vgpu_type
  )
  desc = open(path)
  content = desc.read()
  desc.close()

  return content

# Get the VGPU RAM-amount for a certain flavor on a certain GPU. 
def getVGPURAM(gpu, vgpu_type):
  content = getVGPUDescription(gpu, vgpu_type)
  return int(re.search(r'framebuffer=([0-9]*)M', content).group(1)) * 1024 * 1024

# Get the max available VGPU's of a certain flavor on a certain GPU
def getMaxVGPUs(gpu, vgpu_type):
  content = getVGPUDescription(gpu, vgpu_type)
  return int(re.search(r'max_instance=([0-9]*)', content).group(1))

# Get the short address from a long address; or get closest match if sr-iov.
def getPGPU(data, address):
  # Iterate through addresses, and see if an exact match is found.
  for gpu in data:
    if(address in gpu.lower()):
      return gpu

  # Check for parent device in sysfs, and try to find that in the adresses
  parent_device = os.readlink(f"/sys/bus/pci/devices/{address}/physfn").split('/')[-1]
  for gpu in data:
    if(parent_device in gpu.lower()):
      return gpu

# Get data from nvidia-smi, and enrich it with parameters from sysfs.
def getGPUData():
  data = parseNvidiaSMI()
  types = getGPUTypes()

  for t in types:
    pgpu = getPGPU(data, t)

    if not 'max_vgpu_instances' in data[pgpu]:
      data[pgpu]['max_vgpu_instances'] = 0

    data[pgpu]['type'] = types[t]
    if 'nvidia' in types[t]:
      data[pgpu]['max_vgpu_instances'] = getMaxVGPUs(t, types[t])
    else:
      data[pgpu]['max_vgpu_instances'] += 1

  for gpuid in data:
    data[gpuid]['gpuID'] = gpuid
    if data[gpuid]["Active vGPUs"] != '0':
      for vgpu in data[gpuid]["VGPUs"]:
        data[gpuid]['VGPUs'][vgpu]['vgpuID'] = vgpu

  return data
