#!/bin/bash

# Define the list of devices
devices=("clab-cdc-spine01" "clab-cdc-spine02" "clab-cdc-leaf01" "clab-cdc-leaf02" "clab-cdc-leaf03")

# Define variables for IP addresses and community string
ip_addresses=("172.20.20.11" "172.20.20.12" "172.20.20.21" "172.20.20.22" "172.20.20.23")
community_string="snmpcumulus"

# Loop through each device
for i in "${!devices[@]}"; do
    device="${devices[$i]}"
    ip_address="${ip_addresses[$i]}"

    echo "Configuring SNMP for $device..."

    # Start SNMP service
    docker exec -it "$device" systemctl start snmpd.service

    # Enable SNMP service
    docker exec -it "$device" systemctl enable snmpd@.service

    # Update SNMP configuration
    docker exec -it "$device" sed -i "2s/.*/agentaddress $ip_address@mgmt/" /etc/snmp/snmpd.conf
    docker exec -it "$device" sed -i -e $'$a\\\nrocommunity '"$community_string"' default' /etc/snmp/snmpd.conf

    # Restart SNMP service
    docker exec -it "$device" systemctl restart snmpd.service

    echo "SNMP configuration completed for $device."
done

