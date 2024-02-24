# Spine-Leaf Data Centre Topology using Cumulus routers

This lab consists of five [Cumulus](https://www.nvidia.com/en-us/networking/ethernet-switching/cumulus-linux/) [VX routers](https://docs.nvidia.com/networking-ethernet-software/cumulus-vx/) connected in a spine-leaf topology (two spine and three leaf). Each leaf router is connected to one Linux host.

Cumulus Linux is a fork of FRRouting so it uses similar set of instructions, but it adds more functionalities, including unnumbered interfaces, which are useful in configuring BGP or OSFP in data centres.

All routers in this lab run both BGP and OSPF using numbered interfaces. I will updated the lab to include unnumbered configuration as well.

The lab also includes the ability to run [Observium](https://www.observium.org/), which is a network monitoring and management platform, and [SuzieQ](https://www.stardustsystems.net/suzieq/), an open source software for network observability.

![Lab Topology](img/dc_topo.png)

## Requirements

To use this lab, you need to install [containerlab](https://containerlab.srlinux.dev/) (I used the [script method](https://containerlab.srlinux.dev/install/#install-script) Ubuntu 20.04 VM). You also need to have basic familiarity with [Docker](https://www.docker.com/).

Environment:

- Ubuntu 20.04
- Containerlab v0.51.3
- Docker v25.03

This lab uses the following Docker images form [networkop](https://hub.docker.com/u/networkop):

- networkop/cx:5.3.0
- networkop/host:ifreload

## Cloning the repository

Clone this repository into a folder of your choice:

```
git clone https://github.com/martimy/clab_cvx_dcn dcn
cd dcn
```

## Starting and ending the lab

Use the following command to start the lab:

```
sudo clab deploy -t cvx-dcn.clab.yml
```

To end the lab:

```
sudo clab destroy -t cvx-dcn.clab.yml --cleanup
```

## Basic Usage

1. inspect the status of all nodes in the network

    ```
    sudo clab inspect
    ```
    The output should confirm all nodes are running.

    ```
    +---+-------------------+--------------+-------------------------+-------+---------+-----------------+----------------------+
    | # |       Name        | Container ID |          Image          | Kind  |  State  |  IPv4 Address   |     IPv6 Address     |
    +---+-------------------+--------------+-------------------------+-------+---------+-----------------+----------------------+
    | 1 | clab-cdc-leaf01   | ffe6d19c69c5 | networkop/cx:5.3.0      | cvx   | running | 172.20.20.21/24 | 2001:172:20:20::6/64 |
    | 2 | clab-cdc-leaf02   | c74c4810ffd6 | networkop/cx:5.3.0      | cvx   | running | 172.20.20.22/24 | 2001:172:20:20::9/64 |
    | 3 | clab-cdc-leaf03   | c419656cba38 | networkop/cx:5.3.0      | cvx   | running | 172.20.20.23/24 | 2001:172:20:20::8/64 |
    | 4 | clab-cdc-server01 | b2834936ce57 | networkop/host:ifreload | linux | running | 172.20.20.31/24 | 2001:172:20:20::3/64 |
    | 5 | clab-cdc-server02 | 1ccfab86334a | networkop/host:ifreload | linux | running | 172.20.20.32/24 | 2001:172:20:20::2/64 |
    | 6 | clab-cdc-server03 | bd32bbb98b98 | networkop/host:ifreload | linux | running | 172.20.20.33/24 | 2001:172:20:20::5/64 |
    | 7 | clab-cdc-spine01  | d680bac1c120 | networkop/cx:5.3.0      | cvx   | running | 172.20.20.11/24 | 2001:172:20:20::4/64 |
    | 8 | clab-cdc-spine02  | dc897b260ee0 | networkop/cx:5.3.0      | cvx   | running | 172.20.20.12/24 | 2001:172:20:20::7/64 |
    +---+-------------------+--------------+-------------------------+-------+---------+-----------------+----------------------+
    ```


2. Confirm that BGP sessions are established among all peers.

   ```
   docker exec clab-cdc-spine01 vtysh -c "show bgp summary"
   ```

   or using Cumulus commands:

   ```
   docker exec clab-cdc-spine01 net show bgp summary
   ```

   Note: if you encounter the error "Exiting: failed to connect to any daemons.", wait a couple of minutes.

3. Show the routes learned from BGP in the routing table. Notices there are two paths to each host.

   ```
   docker exec clab-cdc-leaf01 vtysh -c "show ip route bgp"
   ```

   or using Cumulus commands:

   ```
   docker exec clab-cdc-spine01 net show bgp
   ```

4. Show all routes

   ```
   docker exec clab-cdc-spine01 net show route
   ```

5. Ping from any one host to another to verify connectivity.

    ```
    docker exec clab-cdc-server01 ping 10.0.30.101
    ```

6. Show the topology

   ```
   clab graph -s "0.0.0.0:8080" -t cvx-dcn.clab.yml
   ```

   Enter the url 'localhost:8080' in your browser to view the topology. You should see a graph similar to the figure above.


7. Packet sniffing with Wireshark/Tshark

   Bind one container interface to another's so you can run tshark:

   ```
   docker run -it --rm --net container:clab-cdc-spine01 nicolaka/netshoot tshark -i swp1
   ```

   You may also need to generate traffic in the network to observe the packets.


## Using Observium

Observium provides real-time information about network health and performance. It uses ICMP, SNMP, and Syslog protocols to automatically discover network devices and services, collect performance metrics, and generate alerts when problems are detected. It supports a wide range of device types, platforms and operating systems, and offers features such as traffic accounting, threshold alerting, and integration with third party applications. Observium has three editions: Community, Professional, and Enterprise. The Community Edition is free and open source,

To able to use Observium, you must enable SNMP on all routers while they are running:

```
~/dcn$  ./enable_snmp.sh
```

The script will start the SNMP daemon in each router and update the configuration file snmpd.conf. The SNMP community string is `snmpcumulus` for SNMP version 1 and 2c. You may also configure SNMPv3 for more security.

```
Configuring SNMP for clab-cdc-spine01...
SNMP configuration completed for clab-cdc-spine01.
...
```


Confirm the ability to connect to a router using SNMP:

```
docker run -it --rm --net clab nicolaka/netshoot snmpwalk -v 2c -c snmpcumulus 172.20.20.11 system
```

This is the partial output:

```
SNMPv2-MIB::sysDescr.0 = STRING: Cumulus-Linux 5.3.0 (Linux Kernel UTC)
SNMPv2-MIB::sysObjectID.0 = OID: SNMPv2-SMI::enterprises.40310
DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (13854) 0:02:18.54
SNMPv2-MIB::sysContact.0 = STRING: root
SNMPv2-MIB::sysName.0 = STRING: spine01
SNMPv2-MIB::sysLocation.0 = STRING: Unknown
SNMPv2-MIB::sysServices.0 = INTEGER: 72
...
```

Change to the Observium directory and create three sub directories (you need to do this only once):

```
~/dcn$ cd observium
~/dcn/observium$ mkdir {data,logs,rrd}
```

Start Observium:

```
~/dcn/observium$ docker compose up -d
```

Open a browser and access Observium via (http://localhost:8888/). Use the username and password found in the `docker-compose.yaml` file. You may change them later.

To add devices to Observium, used the following example:

```
docker compose exec app /opt/observium/add_device.php 172.20.20.11 snmpcumulus v2c
```

Run the discovery and polling scripts for the first time:

```
docker compose exec app /opt/observium/discovery.php -h all
docker compose exec app /opt/observium/poller.php -h all
```

Note: discovery and polling will occur periodically.  

![Observium](img/observium.png)

To stop Observium:

```
docker compose down
```

Note: all configuration changes as well as data collected from devices will be persistent even after stopping and removing the containers. The data is saved in the directories you created above.

## Using SuzieQ

SuzieQ is an agentless open-source application that collects, normalizes, and stores timestamped network information from multiple vendors. A network engineer can then use the information to verify the health of the network or identify issues quickly.

SuzieQ is a Python module/application that consists of three parts, a poller, a CLI interface, and a GUI interface. To learn more about SuzieQ,
you can refer to these links:

- [Introduction to SuzieQ](https://www.packetcoders.io/introduction-to-suzieq/)
- [SuzieQ Docs](https://suzieq.readthedocs.io/en/latest/)
- [Github repo](https://github.com/netenglabs/suzieq)
- [Whoop Dee Doo for my SuzieQ!](https://gratuitous-arp.net/fabric-like-visibility-to-your-network-with-suzieq/) by Claudia de Luna
-

SuzieQ is also packaged as a Docker container, which we will use in this lab to get a quick look into the capabilities.

To use SuzieQ, make sure that the clab is running as above, then use the following commands to start SuzieQ.
Make sure you cnage the SQPATH to reflect the correct path to SuzieQ.
The command attaches the container to the clab network and exposes the 8501 port for the GUI.

```
SQPATH=/path/to/suzieq
docker run --rm -it -p 8501:8501 \
  -v $SQPATH/dbdir:/home/suzieq/parquet \
  -v $SQPATH/inventory.yml:/home/suzieq/inventory.yml \
  -v $SQPATH/my-config.yml:/home/suzieq/my-config.yml \
  --name sq-poller --network=clab \
  netenglabs/suzieq:latest
```


Start the Poller to collect information about the devices in the network:

```
suzieq@b7c0b9263b48:~$ sq-poller -I inventory.yml -c my-config.yml
```

After few minutes, stop the Poller (CTRL-C) and start the GUI:

```
suzieq@b7c0b9263b48:~$ suzieq-gui
```

Direct you browser to "localhost:8501". The [Streamlit](https://streamlit.io/) app gives access to various information that the Poller collected earlier.

![Status](img/suzieq_status.png)

![Path](img/suzieq_path.png)

More detailed information is available via the CLI. Stop the GUI (CTRL-C) and start the CLI:

```
suzieq@b7c0b9263b48:~$ suzieq-cli
suzieq> device show
  namespace  hostname model version   vendor architecture     status       address           bootupTimestamp
0   routers    leaf01    VX   4.3.0  Cumulus       x86_64      alive  172.20.20.21 2022-11-02 12:04:47+00:00
1   routers    leaf02    VX   4.3.0  Cumulus       x86_64      alive  172.20.20.22 2022-11-02 12:04:47+00:00
2   routers    leaf03    VX   4.3.0  Cumulus       x86_64      alive  172.20.20.23 2022-11-02 12:04:47+00:00
3   routers   spine01    VX   4.3.0  Cumulus       x86_64      alive  172.20.20.11 2022-11-02 12:04:47+00:00
4   routers   spine02    VX   4.3.0  Cumulus       x86_64      alive  172.20.20.12 2022-11-02 12:04:47+00:00
5   servers  server01   N/A     N/A      N/A          N/A  neverpoll      server01 1970-01-01 00:00:00+00:00
6   servers  server02   N/A     N/A      N/A          N/A  neverpoll      server02 1970-01-01 00:00:00+00:00
7   servers  server03   N/A     N/A      N/A          N/A  neverpoll      server03 1970-01-01 00:00:00+00:00
suzieq> exit
```

Once you finished exploring, you can exit the SuzieQ container. You can also end the clab as above.

## Containerlab Commands Summary

Here is a summary of common containerlab commands:

| Command | Description |
| --- | --- |
| `containerlab deploy -t <file>` | Deploy a lab from a topology file |
| `containerlab destroy -t <file>` | Destroy a lab from a topology file |
| `containerlab inspect -t <file>` | Inspect the lab status and configuration |
| `containerlab graph -t <file>` | Generate a graphical representation of the lab topology |
| `containerlab generate -t <file>` | Generate a CLOS-based lab topology file |
| `containerlab version` | Show the containerlab version and build information |

For more details and examples, you can check out the [containerlab documentation](https://containerlab.dev/cmd/deploy/).

## Acknowledgement

- This lab was originally inspired by the [Cumulus Test Drive lab](https://clabs.netdevops.me/rs/cvx03/) created by Michael Kashin.
- Sources of some Docker images:
   - https://github.com/networkop/cx
   - https://github.com/somsakc/docker-observium
   - https://github.com/nicolaka/netshoot
