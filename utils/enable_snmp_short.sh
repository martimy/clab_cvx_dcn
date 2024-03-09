#!/bin/bash

# Define the list of devices
devices=("clab-cdc-spine01" "clab-cdc-spine02" "clab-cdc-leaf01" "clab-cdc-leaf02" "clab-cdc-leaf03")

# Loop through each device
for i in "${!devices[@]}"; do
    device="${devices[$i]}"

    echo "Configuring SNMP for $device..."

    # Start SNMP service
    docker exec -it "$device" systemctl start snmpd.service
done

