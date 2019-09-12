#!/usr/bin/env python3
import pymysql.cursors
import socket
import json
import argparse
import os
import sys

parser = argparse.ArgumentParser(description='Check amount of failed builds for nova-compute.')
parser.add_argument('--host', help="MySQL host address")
parser.add_argument('--user', help="Database user name", default='nova')
parser.add_argument('--password', help="Database password")
args = parser.parse_args()

dbhost = args.host
dbuser = args.user
dbpass = args.password
hostname = socket.gethostname()

tmpfilepath = '/tmp/nova_failed_builds_count'

try:
    with open(tmpfilepath, 'r') as tmpfile:
        previous_failed_builds = int(tmpfile.readline())
except FileNotFoundError:
    previous_failed_builds = 0

try:
    connection = pymysql.connect(host=dbhost,
                                 user=dbuser,
                                 db='nova',
                                 password=dbpass,
                                 cursorclass=pymysql.cursors.DictCursor)
    with connection.cursor() as cursor:
        sql = "SELECT stats FROM compute_nodes WHERE host=%s"
        cursor.execute(sql, hostname)
        result = cursor.fetchone()
        current_failed_builds = int(json.loads(result['stats'])['failed_builds'])
        if current_failed_builds > previous_failed_builds:
            print("CRITICAL - Nova failed build count has increased from {} to {}".format(previous_failed_builds, current_failed_builds))
            exitcode=2
        else:
            print("OK - Nova failed build count is not increasing")
            exitcode=0
        with open(tmpfilepath, 'w') as tmpfile:
            tmpfile.write(str(current_failed_builds))

    connection.close()

except:
    print("UNKNOWN - Something wrong happened with the database connection")
    exitcode=3

sys.exit(exitcode)
