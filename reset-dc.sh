#!/bin/bash

# Remove all switches
ovs-vsctl --if-exists del-br switch01
ovs-vsctl --if-exists del-br switch02
ovs-vsctl --if-exists del-br switch03

