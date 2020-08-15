#!/bin/bash

# Exporting environment variables
echo "=========> Exporting environment vars...."
source vars.sh

# Up and running vms

echo "=========> Up & Run vms...."
echo "=========> 1). Database VM: Building and provisioning ...."
# vagrant up db
echo "=========> 1). Database VM: Up & Running ...."
echo "=========> 2). WEB VM: Building and provisioning ...."
vagrant up web
echo "=========> 2). WEB VM: Up & Running ...."

read -n 1 -s -r -p "Press any key to continue"