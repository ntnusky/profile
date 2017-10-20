#!/usr/bin/python
import os
import re

location = '/var/backups'
filenamePattern = re.compile( \
    r'^MysqlDump\.([0-9]{2})([0-9]{2})([0-9]{2})[0-9]{6}\.sql\.gz$')

lastYearly = 0
lastMonthly = 0
lastDaily = 0

daily = []
monthly = []
yearly = []
every = []

files = os.listdir(location)
files.sort()
for f in files: 
  match = filenamePattern.match(f)
  if(not match):
    continue
  every.append(f)
  
  if(lastYearly != match.group(1)):
    lastYearly = match.group(1)
    yearly.append(f)
    lastDaily = 0
    lastMonthly = 0
    
  if(lastMonthly != match.group(2)):
    lastMonthly = match.group(2)
    monthly.append(f)
    lastDaily = 0
    
  if(lastDaily != match.group(3)):
    lastDaily = match.group(3)
    daily.append(f)

keep = every[-30:]
daily = daily[-30:]
monthly = monthly[-20:]
yearly = yearly[-5:]

toDelete = [x for x in every if x not in keep and x not in daily \
    and x not in monthly and x not in yearly]
for f in toDelete:
  os.remove(os.path.join(location, f))
  print("Deleting %s" % os.path.join(location, f))
