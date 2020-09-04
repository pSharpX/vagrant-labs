#!/bin/bash

# Validate Vagrantfile
echo "=========> Validating Vagrantfile..."
if [[ "$(vagrant validate 2> /dev/null)" == "" ]]; then
    echo "******** Vagrantfile not found or contains errors."
    exit
fi

# Up and running vms
echo "=========> Up & Run vm...."
echo "=========> 1). VM: Building and provisioning ...."
vagrant destroy -f

if [[ "$(vagrant up 2> /dev/null)" == "" ]]; then
    echo "******** An error occured while running 'vagrant up' command."
    exit
fi

# Machine is shutdown so we need up machine again
echo "=========> 2). VM: Up & Running ...."
vagrant up

# Check whether VM contains provisioned file
echo "=========> 3). VM: Removing provisioned file ...."
PROVISIONED_ON=/etc/vm_provision_on_timestamp
vagrant ssh -c "test -f $PROVISIONED_ON && sudo rm $PROVISIONED_ON"

vagrant halt
echo "=========> 4). VM: Packaging VBox Custom Box ...."
if [[ "$(vagrant package --vagrantfile Vagrantfile --output openjdk8-primary.box java_dev_environment 2> /dev/null)" == "" ]]; then
    echo "******** An error occured while running 'vagrant package' command."
    echo "******** 1) Invalid options were specified."
    exit
fi

echo "=========> 5). VM: Destroying temporary VM ...."
vagrant destroy -f
echo "=========> 6). VM: Box is Done ...."
read -n 1 -s -r -p "Press any key to continue"