#!/usr/bin/python3
import os
import pymysql
import re
import socket
import subprocess
import sys

def connectToDB():
  try:
    connector = pymysql.connect(
      host = os.environ['DBHOST'], 
      db = os.environ['DBNAME'],   
      user = os.environ['DBUSER'],   
      passwd = os.environ['DBPASS'],   
      port = 3306, 
      charset = 'utf8'
    )
    return connector
  except:
    return None

def createDatabase(connector):
  fields = {
    'id': 'INT AUTO_INCREMENT PRIMARY KEY',
    'host': 'VARCHAR(255) NOT NULL',
    'gpu': 'VARCHAR(255) NOT NULL',
    'vgpu': 'INT NOT NULL',
    'instance_id': 'VARCHAR(255) NULL',
    'attached': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
    'detached': 'TIMESTAMP NULL DEFAULT NULL',
  }

  fieldstrings = []
  for f in fields:
    fieldstrings.append("%s %s" % (f, fields[f]))

  with connector.cursor() as cur:
    try:
      cur.execute("SELECT * FROM instancemapping")
      return 
    except pymysql.err.ProgrammingError:
      existing = False
  
  with connector.cursor() as cur:
    cur.execute("CREATE TABLE instancemapping (" +
      ", ".join(fieldstrings) + ")")
    connector.commit()

def registerHistory(gpu, vgpu, instance):
  # Connect to database, and ensure table is present
  connector = connectToDB()
  if not connector:
    return
  createDatabase(connector)

  hostname = socket.gethostname()

  # Get latest instance-mapping for the vgpu in question
  with connector.cursor() as cur:
    cur.execute(
        'SELECT * FROM instancemapping WHERE ' +
        'host=%s AND gpu=%s AND vgpu=%s AND detached IS NULL',
        (hostname, gpu, vgpu))
    result = cur.fetchone()

    if(result):
      existing = True
      e_id, e_host, e_gpu, e_vgpu, e_instance, e_attached, e_detached = result
    else:
      existing = False

  # If the retrieve record is for another instance, mark it as detached.
  if(existing and e_instance != instance):
    with connector.cursor() as cur:
      cur.execute("UPDATE instancemapping SET detached = CURRENT_TIMESTAMP()" +
        " WHERE id = %s", e_id)
      connector.commit()
    existing = None

  # If no record exists, or if the record was for another instance, create a new
  # record.
  if not existing and instance:
    with connector.cursor() as cur:
      cur.execute("INSERT INTO instancemapping (host, gpu, vgpu, instance_id)" +
        " VALUES (%s, %s, %s, %s)",
        (hostname, gpu, vgpu, instance))
      connector.commit()

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

  # Iterate through addresses, and see if we find a similar address, where only
  # the last part differs.
  address = '.'.join(address.split('.')[:-1])
  for gpu in data:
    if(address in gpu.lower()):
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

  return data
