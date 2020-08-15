#!/bin/bash

# Up and running vms

echo "=========> Up & Run vm...."
vagrant destroy -f
echo "=========> 1). VM: Building and provisioning ...."
vagrant up
echo "=========> 2). VM: Up & Running ...."
vagrant halt
vagrant up
vagrant halt
echo "=========> 2). VM: Packaging VBox Custom Box ...."
vagrant package --vagrantfile Vagrantfile --output centos7-primary.box
echo "=========> 3). VM: Destroying temporary VM ...."
vagrant destroy -f
echo "=========> 4). VM: Box is Done ...."
read -n 1 -s -r -p "Press any key to continue"