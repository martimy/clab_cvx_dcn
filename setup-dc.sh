#!/bin/bash

# Create switches
for BR in switch01 switch02 switch03
do
  echo Create switch $BR
  ovs-vsctl --may-exist add-br $BR
done
