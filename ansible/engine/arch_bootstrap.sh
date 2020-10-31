#!/bin/bash


PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'pacman -Syu'"
  exit
fi

sudo pacman-key --init
sudo pacman-key --populate
sudo pacman-key --refresh-keys
sudo pacman -Sy archlinux-keyring --noconfirm

# Update package list and upgrade all packages
sudo pacman -Syu --noconfirm

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created Ansible (controller/node) machine"
# echo "Shuting down !"
# sudo shutdown -h now