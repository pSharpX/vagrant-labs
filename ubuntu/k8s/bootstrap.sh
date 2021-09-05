#!/bin/bash


set_hostnames() {
  
cat <<EOF >> /etc/hosts
192.168.99.100 kube-master.ose.pe kube-master
192.168.99.101 kube-nodo1.ose.pe kube-nodo1
192.168.99.102 kube-nodo2.ose.pe kube-nodo2
EOF

}

install_tools() {
  apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release vim net-tools

  # if we see this when execute kubeadm init, then install
  # [preflight] WARNING: ebtables not found in system path
  # apt-get install ebtables ethtool
  # yum install ebtables ethtool
}

disable_swap() {
  swapoff -a
  sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
}

enable_docker_repo() {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
  echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
}

install_docker() {
  apt-get remove docker docker-engine docker.io containerd runc
  apt-get install -y docker-ce docker-ce-cli containerd.io

  # Create daemon json config file
tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

  groupadd docker
  usermod -aG docker $USER
  usermod -aG docker vagrant

# Start and enable Services
  systemctl daemon-reload
  systemctl restart docker
  systemctl enable docker
  #systemctl enable --now docker
}

activate_kubernetes_config() {
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF >>  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

  sysctl --system
}

enable_kubernetes_repo() {
  curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
}

install_kubernetes() {
  apt-get install -y kubelet kubeadm kubectl
  # this option used to mark a package as held back, which will block the package from being installed, upgraded or removed.
  apt-mark hold kubelet kubeadm kubectl

  systemctl enable --now kubelet
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'sudo apt update && sudo apt upgrade -y'"
  exit
fi

lsb_release -ds

# Update package list and upgrade all packages
# sudo apt update && sudo apt upgrade -y
# apt update && sudo apt upgrade -y

# Preparing VM for provisioning a kubernetes cluster

# 1.
set_hostnames

# 2.
disable_swap

# 3.
activate_kubernetes_config
enable_docker_repo
enable_kubernetes_repo

# 4.
apt-get update && apt-get upgrade -y

# 5.
install_tools
install_docker
install_kubernetes

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"