# SNMP Tools

This section demonstration of the use of SNMP tools to get information from the routers. The SNMP tools implement the messages: 'getRequest', 'getNextRequest', and 'getBulkRequest'.

Before you start, make sure that topology is deployed and SNMP is enabled on all routers before proceeding.

```
$ ./utils/enable_snmp.sh
...
$ ./utils/test_snmp.sh
...
```

You should not get any errors after executing the above commands.

Notes:

- You can limit the topology to the routers and the management workstation only:

   ```
   sudo clab deploy -t cvx-dcn.clab.yaml --node-filter spine01,spine02,leaf01,leaf02,leaf03,nms
   ```

- All the examples use 'spine01' as target but you can change the address to any other router.


The following commands can be executed from the host machine:

```
$ snmpwalk -v 2c -c snmpcumulus 172.20.20.11 system
```

or from the 'nms' node (if snmp tools are not installed on the host machine):

```
$ docker exec clab-cdc-nms snmpwalk -v 2c -c snmpcumulus 172.20.20.11 system
```

You can also enter the 'nms/ node:

```
docker exec -it clab-cdc-nms bash
nms:~# snmpwalk -v 2c -c snmpcumulus 172.20.20.11 system
```

## getRequest

```
snmpget -v 2c -c snmpcumulus 172.20.20.11 sysName.0
snmpget -v 2c -c snmpcumulus 172.20.20.11 sysUpTime.0
```

Add the option '-On' to print the numeric value of the OID.


## getNextRequest

```
snmpgetnext -v 2c -c snmpcumulus 172.20.20.11 system
snmpgetnext -v 2c -c snmpcumulus 172.20.20.11 sysDescr.0
```


## getBulkRequest.

The last paramter r3 represent the number of number of OIDs requested

```
snmpbulkget -v 2c -c snmpcumulus -C n0 -C r3 172.20.20.11 system
```

This example explains the use of non-repeaters and max-repititions

```
snmpbulkget -v 2c -c snmpcumulus 172.20.20.11 system tcp ifTable -C n2 -C r5
```

Notice what happens when the non-repeaters changes

```
snmpbulkget -v 2c -c snmpcumulus 172.20.20.11 system tcp ifTable -C n1 -C r5
```

## snmpwalk

snmpwalk retrieves the whole MIB tree or one MIB group using a series of 'getNextRequest' messages:

```
snmpwalk -v 2c -c snmpcumulus 172.20.20.11
```

```
snmpwalk -v 2c -c snmpcumulus 172.20.20.11 system
```

## snmptable

To display a table:

```
snmptable -v 2c -c snmpcumulus -Os -Cw 90 172.20.20.11 ifTable
```

The -Cw 90 partitions the table to a maximum width of 90 characters.
