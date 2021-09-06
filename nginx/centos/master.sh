#!/bin/bash

update_so() {
  # Update package list and upgrade all packages
  yum check-update
  yum clean all
  yum -y update
}

set_hostnames() {
cat <<EOF >> /etc/hosts
192.168.99.110 nginx-master.ose.pe nginx-master
192.168.99.111 nginx-nodo1.ose.pe nginx-nodo1
192.168.99.112 nginx-nodo2.ose.pe nginx-nodo2
EOF
}

install_tools() {
  yum install -y vim net-tools yum-utils
}

enable_firewall_http_service() {
  #Habilitar regla que permite el puerto 80/http  y 443/https en el firewall
  firewall-cmd --permanent --add-service=http
  firewall-cmd --permanent --add-service=https
  firewall-cmd --reload
}

disable_selinux() {
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
}

enable_docker_repo() {
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
}

enable_nginx_repo() {
cat <<EOF >> /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx-repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOF
}

install_nginx() {
  yum -y install nginx
  systemctl enable nginx
  systemctl start nginx
}

install_docker() {
  yum install -y docker-ce docker-ce-cli containerd.io

  groupadd docker
  usermod -aG docker $USER
  usermod -aG docker vagrant

  systemctl enable docker && systemctl start docker
}

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'yum check-update && yum -y update'"
  exit
fi

# Preparing VM for NGINX installation

# 1.
set_hostnames
install_tools
enable_nginx_repo

# 2.
disable_selinux
enable_firewall_http_service

# 3.
update_so

# 4.
install_nginx
enable_docker_repo
install_docker

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"