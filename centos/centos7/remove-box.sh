#!/bin/bash

echo "=========> 1). VM: Removing custom Box from vagrant ...."
vagrant box remove psharpx/centos7-primary
echo "=========> 3). VM: Box removed successfully ...."

read -n 1 -s -r -p "Press any key to continue"