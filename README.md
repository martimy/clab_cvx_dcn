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


# Additional Tips

Bind one container interface to another's so you can run tshark:

```
$ docker run -it --rm --net container:clab-cdc-spine01 nicolaka/netshoot tshark -i swp1
```

# Using SuzieQ

SuzieQ is an agentless open-source application that collects, normalizes, and stores timestamped network information from multiple vendors. 
A network engineer can then use the information to verify the health of the network or identify issues quickly. 

SuzieQ is a Python module/application that consists of three parts, a poller, a CLI interface, and a GUI interface. To learn more about SuzieQ,
you can refer to these links:


SuzieQ is also packged as a Docker container, which we will use in this lab to get a quick look into the capabilities.
 
To use SuzieQ, make sure that the clab is running as above, then use the following commands to start SuzieQ. 
The Docker command attaches the container to the clab network and exposes port 8501 for the GUI. 

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

![Status](images\suzieq_status.png)

![Status](images\suzieq_path.png)

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



