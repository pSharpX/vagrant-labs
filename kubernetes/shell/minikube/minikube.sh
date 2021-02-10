#!/bin/bash

KUBECTL_LATEST_STABLE_VERSION=https://dl.k8s.io/release/stable.txt

kubectl_installation(){  
  ## Download the latest release with the command:
  curl -LO "https://dl.k8s.io/release/$(curl -L -s $KUBECTL_LATEST_STABLE_VERSION)/bin/linux/amd64/kubectl"

  ## Validate the binary (optional)
  ## curl -LO "https://dl.k8s.io/$(curl -L -s $KUBECTL_LATEST_STABLE_VERSION)/bin/linux/amd64/kubectl.sha256"

  ## Validate the kubectl binary against the checksum file:
  ## echo "$(<kubectl.sha256) kubectl" | sha256sum --check

  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

minikube_installation(){
  ## Binary download
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
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

# Kubectl installation
echo "******** Kubectl installation..."
kubectl_installation

# Minikube installation
echo "******** Minikube installation..."
minikube_installation

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"
