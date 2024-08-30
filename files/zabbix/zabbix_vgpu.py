#!/usr/bin/python3
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

# Parse ENV to retrieve VGPU-types for certain PCI-devices.
def getGPUTypes():
  pattern = re.compile(r'^GPU(\d+)$')
  gpus = {}
  for key in os.environ:
    match = pattern.match(key)
    if(match):
      a, t = os.environ[key].split(' ')
      gpus[a] = t
  return gpus

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
  parent_device = os.readlink(f"/sys/class/mdev_bus/{address}/physfn").split('/')[-1]
  for gpu in data:
    if(parent_device in gpu.lower()):
      return gpu

# Get data from nvidia-smi, and enrich it with parameters from sysfs.
def getGPUData():
  data = parseNvidiaSMI()
  types = getGPUTypes()

  for t in types:
    pgpu = getPGPU(data, t)

    data[pgpu]['type'] = types[t]
    data[pgpu]['vgpu_instances'] = getMaxVGPUs(t, types[t])
    data[pgpu]['vgpu_ram'] = getVGPURAM(t, types[t])
  
  for gpuid in data:
    data[gpuid]['gpuID'] = gpuid
    for vgpu in data[gpuid]["VGPUs"]:
      data[gpuid]['VGPUs'][vgpu]['vgpuID'] = vgpu

  return data
