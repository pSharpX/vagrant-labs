#!/bin/bash

docker_installation(){
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
  apt-get install -y docker-ce

  #Añada al usuario al grupo docker.
  sudo usermod -aG docker $USER
}

docker_machine_installation(){
  DOCKER_MACHINE_URL=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -sL $DOCKER_MACHINE_URL/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
  chmod +x /usr/local/bin/docker-machine
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_docker_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'sudo apt update && sudo apt upgrade -y'"
  exit
fi

lsb_release -ds

# sudo apt update && sudo apt upgrade -y
# sudo apt-get update && sudo apt-get upgrade -y

# Docker installation
echo "******** Docker Community Edition installation..."
docker_installation

# Docker-machine installation
echo "******** Docker-Machine installation..."
docker_machine_installation

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"
