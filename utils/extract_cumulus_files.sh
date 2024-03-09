#!/bin/bash

# extract file from docker image

VER=5.3.0

id=$(docker create networkop/cx:$VER foo)
#docker cp $id:/etc/hsflowd.conf  .
docker cp $id:/etc/snmp/snmpd.conf.cumulus .
docker rm $id
