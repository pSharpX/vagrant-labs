#!/bin/bash

echo "=========> 1). VM: Adding Custom VBox ...."
# vagrant box add --box-version 1.0 psharpx/centos7-primary centos7-primary.box
vagrant box add psharpx/centos7-primary centos7-primary.box
echo "=========> 3). VM: Box added successfully ...."

read -n 1 -s -r -p "Press any key to continue"