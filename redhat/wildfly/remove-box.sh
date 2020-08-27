#!/bin/bash

BOX_NAME=${1:-"psharpx/wildfly-primary"}

echo "=========> 1). VM: Removing custom Box from vagrant ...."
if [[ "$(vagrant box remove $BOX_NAME 2> /dev/null)" == "" ]]; then
    echo "******** An error occured while running 'vagrant box remove' command."
    echo "******** Command: 'vagrant box remove $BOX_NAME'"
    exit
fi
echo "=========> 2). VM: Box removed successfully ...."

read -n 1 -s -r -p "Press any key to continue"