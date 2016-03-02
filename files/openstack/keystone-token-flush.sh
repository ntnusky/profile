#!/bin/bash
logger "Keystone Token-flush started."
/usr/bin/keystone-manage token_flush
logger "Keystone Token-flush finished"
