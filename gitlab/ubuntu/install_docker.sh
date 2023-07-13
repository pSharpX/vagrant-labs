#!/bin/bash

## Docker Installation

# Installing Docker Dependencies
installing_dependencies(){    
    #  Install tools and dependencies
    apt-get install -y git ca-certificates curl gnupg
}

docker_installation(){
    # Add Docker’s official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Use the following command to set up the repository
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	apt-get update
	apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	
	# Add vagrant user to Docker group
	usermod -aG docker vagrant
}

configure_docker(){
    # To automatically start Docker and containerd on boot for other Linux distributions using systemd, run the following commands
    echo "******** Enabling Docker to start on boot and start Docker immediately:"
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_for_docker_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'sudo apt update && sudo apt upgrade -y'"
  exit
fi

lsb_release -ds

# sudo apt update && sudo apt upgrade -y
apt update && apt upgrade -y 

# Installing dependencies
echo "******** Installating Docker Dependencies..."
installing_dependencies

echo "******** Installating Docker Dependencies..."
docker_installation

echo "******** Configuring Docker service..."
configure_docker

# Running Docker
echo "******** Running Docker"
sudo systemctl start docker.service

echo "******** Print the Docker version"
sudo docker --version

# Check if Docker will automatically initiate after a reboot
echo "******** Checking if Docker will automatically initiate after a reboot"
sudo systemctl is-enabled docker.service

# Checking if Docker is running by running one of the following commands 
echo "******** Checking if Docker is running by running one of the following commands"
sudo systemctl status docker.service

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"