#!/bin/bash

BOX_NAME=${1:-"psharpx/ansible-awx-primary"}
BOX_FILE=${2:-"ansible-awx-primary.box"}

# Check whether file exist or not
if [ ! -f "$BOX_FILE" ]; then
    echo "******** File($BOX_FILE) was not found."
    echo "******** Vagrant VM has to be packaged before registering."
    exit
fi

echo "=========> 1). VM: Adding Custom VBox ...."
if [[ "$(vagrant box add $BOX_NAME $BOX_FILE 2> /dev/null)" == "" ]]; then
    echo "******** An error occured while running 'vagrant box add' command."
    echo "******** Command: 'vagrant box add $BOX_NAME $BOX_FILE'"
    exit
fi
echo "=========> 2). VM: Box added successfully ...."

read -n 1 -s -r -p "Press any key to continue"