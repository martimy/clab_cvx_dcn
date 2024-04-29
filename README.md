# Spine-Leaf Data Centre Topology using Cumulus routers

[![Static Badge](https://img.shields.io/badge/Docs-github.io-blue)](https://martimy.github.io/clab_cvx_dcn)

This repo includes code and instructions to create a test data centre network using [Cumulus](https://www.nvidia.com/en-us/networking/ethernet-switching/cumulus-linux/) routers. The network is created using [containerlab](https://containerlab.dev/) and it consists of five [Cumulus VX routers](https://docs.nvidia.com/networking-ethernet-software/cumulus-vx/) connected in a spine-leaf topology (two spine and three leaf). Each leaf router is connected to two Linux hosts.

Cumulus Linux supports various routing protocols such as BGP, OSPF, and RIP based on the open-source software [FRRouting](https://frrouting.org/). Cumulus routers can be deployed on bare-metal switches or virtual machines, such as Cumulus VX used in this network.

![Lab Topology](img/cvx_dc.png)

## Documentation

Find more documentation [here](https://martimy.github.io/clab_cvx_dcn/).

## Applications

This lab environment can be used to learn and explore:

1. Routing Configuration: You can use this network environment to learn how to configure various network protocols in the original topology. You may also modify the topology or extend it. The initial configuration includes BGP and OSPF routing protocols using numbered interfaces. Cumulus supports unnumbered interface configuration as well.

2. Network Monitoring: You can use this network environment to learn network management and monitoring using SNMP. You can run and configure [Observium](https://www.observium.org/), which is a network monitoring platform, to receive networking performance metrics and events. Also included is [SuzieQ](https://www.stardustsystems.net/suzieq/), an open source software for network observability.

## Requirements

To use this lab, you need to have basic familiarity with Linux (Ubuntu), [Docker](https://www.docker.com/), and [containerlab](https://containerlab.srlinux.dev/). This lab was created and tested on an Ubuntu VM created using Vagrant in VirtualBox.   

Environment:

- Ubuntu 20.04
- Docker v25.03. Follow these [instructions](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script) to install.
- Containerlab v0.51.3. Follow these [instructions](https://containerlab.dev/install/) to install.

This lab uses the following Docker images:

- [networkop/cx:5.3.0](https://hub.docker.com/u/networkop)
- networkop/host:ifreload
- [nicolaka/netshoot:latest](https://github.com/nicolaka/netshoot)
- [netenglabs/suzieq:latest](https://github.com/netenglabs/suzieq) (optional)
- martimy/observium:23.9 (optional)
- mariadb:10.6.4 (needed for Observium)

These images will be downloaded automatically by containerlab when you deploy the lab topology for the first time.

## Cloning the repository

Clone this repository into a folder of your choice:

```
git clone https://github.com/martimy/clab_cvx_dcn dcn
cd dcn
```

To use BGP Unnumbered configuration, checkout the 'unnumbered' branch:

```
git checkout unnumbered
```

## Starting and ending the lab

Use the following command to start the lab:

```
sudo clab deploy -t cvx-dcn.clab.yaml
```

To end the lab:

```
sudo clab destroy -t cvx-dcn.clab.yaml --cleanup
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
   clab graph -s "0.0.0.0:8080" -t cvx-dcn.clab.yaml
   ```

   Enter the url 'localhost:8080' in your browser to view the topology. You should see a graph similar to the figure above.


7. Packet sniffing with Wireshark/Tshark

   Bind one container interface to another's so you can run tshark:

   ```
   docker run -it --rm --net container:clab-cdc-spine01 nicolaka/netshoot tshark -i swp1
   ```

   To filter specific protocol, use the -Y option, for example '-Y "snmp"'. To filter based on port, use '-f "udp port 161"'. Please consult the tshark documentaion for more details.


   You may also need to generate traffic in the network to observe the packets.

9. Router configuration

   You can configure the routers using vtysh:

    ```
   $ docker exec -it clab-cdc-spine01 vtysh

    Hello, this is FRRouting (version 7.5+cl5.3.0u0).
    Copyright 1996-2005 Kunihiro Ishiguro, et al.

    spine01# show run
    Building configuration...

    Current configuration:
    !
    frr version 7.5+cl5.3.0u0
    frr defaults traditional
    hostname spine01
    service integrated-vtysh-config
    !
    ...
    ```

## Alternative Topoloy

There is also an alternative way to include a switch (OVS) connected to each leaf router. Two servers are connected to each switch, making the total of servers in the topology six.

To deploy the clab using this topology, you must create the Open vSwithes first (as per clab rules), then deploy the topology. To end the clab, "destroy" the topology then delete the switches. The following scripts simpify the tasks:

```
$ sudo ./setup-dc.sh
$ sudo clab deploy -t spine-leaf.clab.yaml
```

```
$ sudo clab destroy -t spine-leaf.clab.yaml --cleanup
$ sudo ./reset-dc.sh
```


## Using VLANs

The topology in this lab puts all hosts in one VLAN. You can seperate the hosts into two or more VLANs by adding VLAN IDs to the bridge interface of the leaf routers and changing the host IP addresses accordingly. See [Cumulus documentation](https://docs.nvidia.com/networking-ethernet-software/cumulus-linux-37/Layer-2/Ethernet-Bridging-VLANs/) for details.



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
