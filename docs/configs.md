
Cumulus VX uses two configuration file:

- Interface configuration file
- integrated configuration file

For more information consult Cumulus documentation and also FRRouting documentaion as Cumulus is a fork of the latter and both share similar roots.

## interfaces file (interfaces)

The following explains the interfaces file for a leaf switch:

- `auto lo`: This line specifies that the loopback interface (`lo`) should be automatically brought up during system startup. The loopback interface is used for local communication within the system itself.

- `iface lo inet loopback`: This section defines the configuration for the loopback interface (`lo`). It specifies that the interface uses the IPv4 (`inet`) loopback address.

- `address 10.255.255.3/32`: The loopback interface is assigned the IPv4 address `10.255.255.3/32` (host address).

- `auto eth0`: This line indicates that the eth0 interface should be automatically brought up during system startup.

- `iface eth0 inet dhcp`: The configuration for the eth0 interface specifies that it uses DHCP (Dynamic Host Configuration Protocol) to obtain its IP address dynamically from a DHCP server.

- `vrf mgmt`: The Virtual Routing and Forwarding (VRF) named `mgmt` is associated with the eth0 interface. VRFs allow you to create separate routing tables for different purposes.

- `auto mgmt`: The `mgmt` VRF is set to be automatically brought up during system startup.

- `iface mgmt`: This section defines the configuration for the `mgmt` VRF. It specifies the following IP addresses:
    - IPv4 address `127.0.0.1/8`: This is the loopback address for local communication within the system.
    - IPv6 address `::1/128`: The IPv6 equivalent of the loopback address.

- `vrf-table auto`: The `mgmt` VRF is associated with the default VRF table.

- `auto swp11` and `iface swp11`: These lines define the configuration for the swp11 interface. It is assigned the IPv4 address `10.0.0.34` with a netmask of `255.255.255.224` (equivalent to a `/27` subnet).

- `auto swp12` and `iface swp12`: Similar to swp11, the swp12 interface is assigned the IPv4 address `10.0.0.130` with the same netmask.

- `auto bridge` and `iface bridge`: These lines define the configuration for a bridge interface. Bridges are used to connect multiple network interfaces together. In this case:
    - The bridge is assigned the IPv4 address `10.0.10.1` with a netmask of `255.255.255.0` (equivalent to a `/24` subnet).
    - The bridge includes the swp1 and swp2 interfaces (`bridge-ports swp1 swp2`).
    - The bridge is not VLAN-aware (`bridge-vlan-aware no`).

## Configuration file (frr.conf)

The routers are configured to run both BGP and OSPF. There is no particular reason to run both routing protocols in this topology other than experimentation. Typically, BGP is used in data centres due its ability to provide more control, but OSPF is also used in come case.


### Spine Configuration

This section explain the configuration commands the build configuration on a spine switch:

- `hostname spine01`: Sets the hostname of the device to "spine01".

- `service integrated-vtysh-config`: Enables integrated configuration mode, which allows for the configuration of routing protocols and other networking features directly from the VTY shell.

- `router bgp 65199`: Enters BGP (Border Gateway Protocol) configuration mode with the specified autonomous system number (AS 65199).

- `bgp router-id 10.255.255.1`: Sets the BGP router ID to 10.255.255.1.

- `no bgp ebgp-requires-policy`: Disables the requirement for eBGP (external BGP) peers to have an explicitly defined export policy.

- `neighbor 10.0.0.34 remote-as external`: Configures a BGP neighbor relationship with the IP address 10.0.0.34 and specifies that it is an external BGP peer (as opposed to an internal BGP peer).

- `neighbor 10.0.0.66 remote-as external`: Configures another BGP neighbor relationship with the IP address 10.0.0.66, also specifying it as an external BGP peer.

- `neighbor 10.0.0.98 remote-as external`: Configures yet another BGP neighbor relationship, this time with the IP address 10.0.0.98, also specifying it as an external BGP peer.

- `router ospf`: Enters OSPF (Open Shortest Path First) configuration mode.

- `network 10.0.0.32/27 area 0`: Configures OSPF to advertise the network 10.0.0.32/27 (a subnet with a 27-bit mask) in OSPF area 0.

- `network 10.0.0.64/27 area 0`: Similarly, configures OSPF to advertise the network 10.0.0.64/27 in OSPF area 0.

- `network 10.0.0.96/27 area 0`: Configures OSPF to advertise the network 10.0.0.96/27 in OSPF area 0.

- `network 10.0.10.0/24 area 0`: Configures OSPF to advertise the network 10.0.10.0/24 in OSPF area 0.


### Leaf Configuration

This configuration sets up the device as a BGP router within AS 65101, establishing BGP neighbor relationships with two external peers. It also configures OSPF for internal routing, including the advertisement of specific networks. Additionally, it disables IPv6 forwarding and sets up integrated configuration mode for easier management.


- `hostname leaf01`: Sets the hostname of the device to "leaf01".

- `no ipv6 forwarding`: Disables IPv6 forwarding, indicating that the device will not forward IPv6 packets.

- `service integrated-vtysh-config`: Enables integrated configuration mode for the VTY shell, allowing for easier configuration of routing protocols and networking features.

- `router bgp 65101`: Enters BGP configuration mode with the specified autonomous system number (AS 65101).

- `bgp router-id 10.255.255.3`: Sets the BGP router ID to 10.255.255.3.

- `no bgp ebgp-requires-policy`: Disables the requirement for eBGP peers to have an explicitly defined export policy.

- `neighbor 10.0.0.33 remote-as external`: Configures a BGP neighbor relationship with the IP address 10.0.0.33, specifying it as an external BGP peer.

- `neighbor 10.0.0.129 remote-as external`: Configures another BGP neighbor relationship with the IP address 10.0.0.129, also specifying it as an external BGP peer.

- `address-family ipv4 unicast`: Enters IPv4 unicast address family configuration mode.

- `network 10.0.10.0/24`: Configures BGP to advertise the network 10.0.10.0/24.

- `exit-address-family`: Exits the IPv4 unicast address family configuration mode.

- `router ospf`: Enters OSPF configuration mode.

- `passive-interface swp1`: Configures interface swp1 as a passive interface for OSPF, meaning OSPF messages will not be sent or received on this interface.

- `network 10.0.0.32/27 area 0`: Configures OSPF to advertise the network 10.0.0.32/27 in OSPF area 0.

- `network 10.0.0.128/27 area 0`: Similarly, configures OSPF to advertise the network 10.0.0.128/27 in OSPF area 0.

- `network 10.0.10.0/24 area 0`: Configures OSPF to advertise the network 10.0.10.0/24 in OSPF area 0.
