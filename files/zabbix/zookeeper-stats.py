#!/usr/bin/python3
import json
import socket
import sys
import time

data = {}

# Try to fetch monitoring-data from the zookeeper cluster. If it fails,
# return that the server is unavailable.
try:
  tmp_total_data = []
  timeout = 2
  client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  client_socket.connect(('localhost', 2181))
  client_socket.setblocking(0)
  client_socket.send(b'mntr')

  begin = time.time()
  while True:
      if tmp_total_data and time.time()-begin > timeout:
          break
      elif time.time()-begin > timeout*2:
          break

      try:
          tmp_data = client_socket.recv(1024).decode()
          if tmp_data:
              tmp_total_data.append(tmp_data)
              begin = time.time()
          else:
              time.sleep(0.1)
      except:
          pass

  statusdata = ''.join(tmp_total_data)
except:
  data['available'] = 0
  print(json.dumps(data))
  sys.exit(1)

# If data is received, the server is available :)
data['available'] = 1

# Parse the retuned data line by line, and store the result in the data-dict.
for line in statusdata.splitlines():
  if len(line) == 0:
    continue

  key, value = line.split('\t')
  data[key] = value

# Return the parsed monitoring-data
print(json.dumps(data))
