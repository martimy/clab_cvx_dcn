
based on: https://clabs.netdevops.me/rs/cvx03/


- to bind one container interface to another's so you can run tshark

docker run -it --rm --net container:clab-cdc-spine01 nicolaka/netshoot tshark -i swp1

# Spine-Leaf Data Centre Topology using Cumulus routers

This lab consists of five [Cumulus](https://www.nvidia.com/en-us/networking/ethernet-switching/cumulus-linux/) [VX routers](https://docs.nvidia.com/networking-ethernet-software/cumulus-vx/) connected in a spine-leaf topology (two spine and three leaf). Each leaf router is connected to two hosts.
The lab demonstrates creating a DC network using free Cumulus Linux routers (Cumulux Linux is a fork of FRRouting). The lab also includes a demonstration of [SuzieQ](https://www.stardustsystems.net/suzieq/), an open source software for network observibility.  

<!--[Lab Topology](img/bgp_frr.png)-->

## Acknowlegement

This lab is inspired by the [Cumulus Test Drive lab](https://clabs.netdevops.me/rs/cvx03/) created by Michael Kashin.


## Requirements

To use this lab, you need to install [containerlab](https://containerlab.srlinux.dev/) (I used the [script method](https://containerlab.srlinux.dev/install/#install-script) Ubuntu 20.04 VM). You also need to have basic familiarity with [Docker](https://www.docker.com/).

This lab uses the following Docker images:




## Starting and ending the lab

Use the following command to start the lab:

```
sudo clab deploy --topo cvx-dcn.clab.yml
```

To end the lab:

```
sudo clab destroy --topo cvx-dcn.clab.yml --cleanup
```

## Try this

1. Confirm that BGP sessions are established among all peers.  

   ```
   $ docker exec clab-cdc-spine01 vtysh -c "show bgp summary"
   ```

   or using Cumulus commmands:

   ```
   $ docker exec clab-cdc-spine01 net show bgp summary
   ```

2. Show the routes learned from BGP in the routing table. Notices there are two paths to each host.

   ```
   $ docker exec clab-cdc-leaf01 vtysh -c "show ip route bgp"
   ```

3. Ping from any one host to another to verify connectivity.

    ```
    $ docker exec clab-cdc-server01 ping 10.0.30.101
    ```

