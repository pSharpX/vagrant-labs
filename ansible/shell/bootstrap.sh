#!/bin/sh

# **************** Install Docker/Ansible Engine on Ubuntu ****************

required_packages_installation(){
  echo ">>>>>>>>>> Install some additional packages required to run Docker/Ansible on your system"
  sudo apt install apt-transport-https ca-certificates curl software-properties-commony -y

}

docker_installation(){
  echo ">>>>>>>>>> Installing docker-ce repository"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  sudo apt update -y
  apt-cache policy docker-ce

  echo ">>>>>>>>>> Installing docker-ce"
  sudo apt install docker-ce -y

  # Start the Docker service and enable it to start after system reboot
  sudo systemctl enable docker
  # To join the docker group that is allowed to use the docker daemon
  sudo usermod -aG docker $USER
  sudo usermod -aG docker vagrant

  # Restart the docker daemon
  sudo systemctl restart docker

  # Verify the status of Docker service
  systemctl status docker

  echo "docker-ce is now installed on your Ubuntu system"
}

ansible_installation(){
  echo ">>>>>>>>>> Installing Ansible"
  sudo apt install ansible -y

  echo ">>>>>>>>>> Ansible Version"
  ansible --version

  echo "Ansible is now installed on your Ubuntu system"
}

docker_compose_installation(){
  echo ">>>>>>>>>> Installing Docker compose"
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  echo ">>>>>>>>>> Docker compose Version"
  docker-compose --version

  echo "Docker compose is now installed on your Ubuntu system"
}

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'apt -y update'"
  exit
fi


# Update package list and upgrade all packages
sudo apt update -y

# Required packages Installation
required_packages_installation

# Docker Installation
docker_installation

# Docker Compose Installation
docker_compose_installation

# Ansible Installation
ansible_installation

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created Ansible Engine virtual machine."
# echo "Shuting down !"
# sudo shutdown -h now