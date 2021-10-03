#!/bin/bash

restart_ssh_service() {
  systemctl restart sshd
}

enable_ssh_password_authentication() {
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
}


PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'yum check-update && yum -y update'"
  exit
fi

# Update package list and upgrade all packages
#yum check-update
#yum clean all
#yum -y update

# 1.
enable_ssh_password_authentication
restart_ssh_service


# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"