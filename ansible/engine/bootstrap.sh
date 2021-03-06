#!/bin/bash


PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'yum check-update && yum -y update'"
  exit
fi


# Update package list and upgrade all packages
yum check-update
yum clean all
yum -y update

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created Ansible (controller/node) machine"
# echo "Shuting down !"
# sudo shutdown -h now