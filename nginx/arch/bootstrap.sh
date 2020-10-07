#!/bin/sh

## NGINX Installation

nginx_installation(){
  echo "******** Installing NGINX..."
  pacman -S nginx
}

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'yum check-update && yum -y update'"
  exit
fi

echo "******** Updating system..."
pacman -Syu

echo "******** Installating NGINX Dependencies..."
nginx_installation

echo "******** Starting NGINX service..."
systemctl start nginx

systemctl enable nginx

systemctl status nginx

echo "******** Installation completed successfully !"