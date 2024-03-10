The main topology in this lab is described in a YAML file `cvx-dcn.clab.yaml'. Here is a break down of the key components in the file:

- `name: cdc`: This specifies the name of the Containerlab environment, which stands for "Cumulus Data Centre."

- `topology`: This section defines the topology of the network.

- The `nodes` section contains definitions for each node in the network. Nodes can represent various devices like switches, routers, or servers.
   - Each node is given a unique name (`leaf01`, `spine01`, etc.).
   - Each node has properties:
     - `kind`: Specifies the type of node. In this case, `cvx` and `linux` are used, representing Cumulus VX and Linux-based servers respectively.
     - `image`: Specifies the Docker image used for the node.
     - `runtime`: Specifies the runtime environment. Here, 'docker' is used instead of the default 'ignite'for the reasons explained [here](https://containerlab.dev/manual/kinds/cvx/).
     - `binds`: Specifies the volumes to mount into the container. This enables attaching files or folders on the host machine to the container.
     - `mgmt-ipv4`: Specifies the management IPv4 address of the node. All containers can communicate with each other via the default bridge 'clab'. This is considered the management network.
     - `group`: Assigns nodes to specific groups. The group provides hints for visulizing the network.

- The `links` section defines the connections between nodes.
   - Each link connects two nodes using endpoints, which are specified as b`[node_name:interface]`. For example, `leaf01:swp1` represents interface `swp1` on node `leaf01`.

- The `mgmt` section specifies management-related configurations, in this case, it changes the default gateway IPv4 address.
