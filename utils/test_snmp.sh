#!/bin/bash

# Define the list of devices
devices=("clab-cdc-spine01" "clab-cdc-spine02" "clab-cdc-leaf01" "clab-cdc-leaf02" "clab-cdc-leaf03")

# Define variables for IP addresses and community string
ip_addresses=("172.20.20.11" "172.20.20.12" "172.20.20.21" "172.20.20.22" "172.20.20.23")
community="snmpcumulus"

# Loop through each device
for i in "${!devices[@]}"; do
    device="${devices[$i]}"
    ip_address="${ip_addresses[$i]}"

    echo "Testing SNMP for $device ..."
    docker exec -it clab-cdc-nms snmpget -v 2c -c $community $ip_address sysDescr.0
done

