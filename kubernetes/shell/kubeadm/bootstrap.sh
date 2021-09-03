#!/bin/bash


set_hostnames() {
  
cat <<EOF >> /etc/hosts
192.168.99.100 kube-master.ose.pe kube-master
192.168.99.101 kube-nodo1.ose.pe kube-nodo1
192.168.99.102 kube-nodo2.ose.pe kube-nodo2
EOF

}

install_tools() {
  yum install -y vim net-tools
}

disable_firewall() {
  systemctl stop firewalld
  systemctl disable firewalld
}

disable_selinux() {
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
}

disable_swap() {
  swapoff -a
  sed -i '/swap/d' /etc/fstab
}

activate_kubernetes_config() {
cat <<EOF >>  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
}

install_docker() {
  yum install -y docker

  groupadd docker
  usermod -aG docker $USER

  systemctl enable docker && systemctl start docker
}

enable_kubernetes_repo() {
cat <<EOF >> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
}

install_kubernetes() {
  yum install -y kubelet-1.14.10-0.x86_64 kubeadm-1.14.10-0.x86_64 kubectl-1.14.10-0.x86_64
  systemctl enable --now kubelet
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

# Preparing VM for provisioning a kubernetes cluster

# 1.
set_hostnames

# 2.
disable_firewall
disable_selinux
disable_swap

# 3.
install_tools
install_docker

# 4.
activate_kubernetes_config
enable_kubernetes_repo
install_kubernetes

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"