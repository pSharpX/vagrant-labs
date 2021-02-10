#!/bin/bash

HOME_DIR=/home/vagrant
KUBECTL_LATEST_STABLE_VERSION=https://dl.k8s.io/release/stable.txt

kubectl_installation(){  
  ## Download the latest release with the command:
  curl -sLO "https://dl.k8s.io/release/$(curl -L -s $KUBECTL_LATEST_STABLE_VERSION)/bin/linux/amd64/kubectl"

  ## Validate the binary (optional)
  ## curl -LO "https://dl.k8s.io/$(curl -L -s $KUBECTL_LATEST_STABLE_VERSION)/bin/linux/amd64/kubectl.sha256"

  ## Validate the kubectl binary against the checksum file:
  ## echo "$(<kubectl.sha256) kubectl" | sha256sum --check

  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

minikube_installation(){
  ## Binary download
  curl -sLO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
}

config_minikube() {
  # Setup environment variables
  sudo touch /etc/profile.d/minikube.sh
  echo "########## Setting Minikube/Kubernetes environment variables"
  echo export MINIKUBE_WANTUPDATENOTIFICATION=false >> /etc/profile.d/minikube.sh
  echo export MINIKUBE_WANTREPORTERRORPROMPT=false >> /etc/profile.d/minikube.sh
  echo export MINIKUBE_HOME=$HOME_DIR >> /etc/profile.d/minikube.sh
  echo export CHANGE_MINIKUBE_NONE_USER=true >> /etc/profile.d/minikube.sh
  echo export KUBECONFIG=$HOME_DIR/.kube/config >> /etc/profile.d/minikube.sh

  # Make the script executable by running the following chmod command:
  sudo chmod +x /etc/profile.d/minikube.sh
  # sudo chown vagrant: /etc/profile.d/gradle.sh
  # source the file or logout and back in.
  source /etc/profile.d/minikube.sh 

  sudo mkdir -p $HOME_DIR/.kube
  sudo touch $HOME_DIR/.kube/config
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_minikube_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'sudo apt update && sudo apt upgrade -y'"
  exit
fi

lsb_release -ds

# sudo apt update && sudo apt upgrade -y
# sudo apt-get update && sudo apt-get upgrade -y

## turn swap off for working with kubernetes locally
echo "******** Turning swap off for working with kubernetes locally..."
sudo swapoff -a

## Installing dependencies for minikube
echo "******** Installing dependencies for minikube..."
sudo apt-get install -y conntrack

# Kubectl installation
echo "******** Kubectl installation..."
kubectl_installation

# Minikube installation
echo "******** Minikube installation..."
minikube_installation

# Minikube configuration
echo "******** Minikube configuration..."
config_minikube

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"
