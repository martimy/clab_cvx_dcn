#!/bin/bash

iterations=10

# Parse user-defined argument for number of iterations
if [ $# -gt 0 ]; then
    iterations=$1
fi

delay=5

# List of server addresses
servers=("10.0.10.101" "10.0.10.102" "10.0.20.101" "10.0.20.102" "10.0.30.101" "10.0.30.102")
servnames=("clab-cdc-server01" "clab-cdc-server02" "clab-cdc-server03" "clab-cdc-server04" "clab-cdc-server05" "clab-cdc-server06")

for ((i=0; i<$iterations; i++)); do

    # Select two random servers ensuring they are not equal
    while true; do
        index1=$((RANDOM % ${#servers[@]}))
        index2=$((RANDOM % ${#servnames[@]}))
        if [ $index1 -ne $index2 ]; then
            break
        fi
    done

    # Extract the selected server address

    server_address=${servers[$index1]}
    server_name=${servnames[$index2]}

    # Execute the iperf command
    echo "from $server_name to $server_address"
    #docker exec "$server_name" ping -c 1 "$server_address"
    docker exec "$server_name" iperf -c "$server_address" -u

#    sleep $delay
done
