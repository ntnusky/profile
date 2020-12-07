#!/usr/bin/python3
import os
import re
import subprocess
import sys

def getParsedData():
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
      key, value = line.split(':')
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

def getRunInfo():
  data = getParsedData() 

  try:
    gpu = os.environ['GPU'].upper()
    if(gpu.startswith('0000:')):
      gpu = "0000%s" % gpu
    vgpu_type = os.environ['VGPUTYPE'] 
  except:
    sys.exit(1)
  
  if(gpu in data):
    card = data[gpu]
  elif("%s0" % gpu.rstrip('0123456789ABCDEF') in data):
    card = data["%s0" % gpu.rstrip('0123456789ABCDEF')]
  else:
    sys.exit(2)

  try:
    gpus = list(card['VGPUs'].keys())
    gpus.sort()
  except KeyError:
    gpus = []
  
  pcieaddr = re.search(r'([0-9a-f]{4}:.*)', gpu.lower()).group(1)
  path = '/sys/class/mdev_bus/%s/mdev_supported_types/%s/description' % (
    pcieaddr, vgpu_type
  )
  desc = open(path)
  content = desc.read()
  desc.close()

  vgpus = int(re.search(r'max_instance=([0-9]*)', content).group(1))
  ram = int(re.search(r'framebuffer=([0-9]*)M', content).group(1)) * 1024 * 1024

  return card, gpus, vgpus, ram
