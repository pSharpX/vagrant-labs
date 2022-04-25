#!/bin/sh

LATEST_AWX=17.0.1

# **************** Install Ansible AWX on CentOS 8 ****************
update_packages_repo_url(){
  echo ">>>>>>>>>> Update Packages Repository URL"
  sudo sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
  sudo sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

  sudo dnf clean all
  sudo dnf swap centos-linux-repos centos-stream-repos -y
}

required_packages_installation(){
  echo ">>>>>>>>>> Install the EPEL repository in your system"
  sudo dnf install epel-release -y
  
  echo ">>>>>>>>>> Install some additional packages required to run AWX on your system"
  sudo dnf install git gcc gcc-c++ nodejs gettext device-mapper-persistent-data lvm2 bzip2 -y
  sudo yum install python3-pip libseccomp-devel -y
}

docker_installation(){
  echo ">>>>>>>>>> Installing docker-ce repository"
  sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

  echo ">>>>>>>>>> Installing docker-ce"
  sudo dnf -y install docker-ce --nobest

  # Start the Docker service and enable it to start after system reboot
  sudo systemctl enable docker
  # To join the docker group that is allowed to use the docker daemon
  sudo usermod -G docker -a $USER
  sudo usermod -G docker -a vagrant

  # Restart the docker daemon
  sudo systemctl restart docker

  # Verify the status of Docker service
  systemctl status docker

  docker version
  echo "docker-ce is now installed on your CentOS system"
}

docker_compose_installation(){
  echo ">>>>>>>>>> Installing Docker compose"
  pip3 install docker docker-compose

  echo ">>>>>>>>>> Docker compose Version"
  docker-compose --version

  echo "Docker compose is now installed on your CentOS system"
}

ansible_installation(){
  echo ">>>>>>>>>> Installing Ansible"
  dnf install ansible -y

  echo ">>>>>>>>>> Ansible Version"
  ansible --version

  echo "Ansible is now installed on your CentOS system"
}

ansible_awx_installation(){
  echo ">>>>>>>>>> Installing Ansible AWX"
  cd ~

  ## Get the latest release of ansible awx tarball and extract it. 
  echo ">>>>>>>>>> Downloading the latest release of ansible awx tarball"

  #LATEST_AWX=$(curl -s https://api.github.com/repos/ansible/awx/tags |egrep name |head -1 |awk '{print $2}' |tr -d '"|,')
  curl -L -o ansible-awx-$LATEST_AWX.tar.gz https://github.com/ansible/awx/archive/$LATEST_AWX.tar.gz && \
  tar xvfz ansible-awx-$LATEST_AWX.tar.gz && \
  rm -f ansible-awx-$LATEST_AWX.tar.gz

  ## Download and extract awx-logos repository. 
  echo ">>>>>>>>>> Downloading awx-logos repository"

  curl -L -o awx-logos.tar.gz https://github.com/ansible/awx-logos/archive/master.tar.gz
  tar xvfz awx-logos.tar.gz

  ## Rename awx-logos-master folder as awx-logos  
  mv awx-logos-master awx-logos

  ## Remove tarball
  rm -f *awx*.tar.gz

  ## Enter awx folder.
  cd ~/awx-$LATEST_AWX/installer

  echo ">>>>>>>>>> AWX: Initial Configurations"

  ## The tarball includes bunch of ansible playbooks and roles to install AWX with an inventory file that holds default configuration variables.
  ## We are going to change the inventory file (located at installer/inventory) in order to deploy AWX with additional configurations like https support, official logos etc.
 
  ## 2)
  # As mentioned above, AWX requires a postgreSQL database and installer will automatically create a psql container for it. But in order to keep data in a persistent location, we need to create a folder to hold the db files in the host system and tell its path to the installer via postgres_data_dir variable.

  ## Create a folder in /opt/ to hold awx psql data
  mkdir -p /opt/awx-psql-data

  ## Provide psql data path to installer.
  sed -i "s|^postgres_data_dir.*|postgres_data_dir=/opt/awx-psql-data|g" inventory

  ## 4)

  ## Next changes is use of eye-candy AWX logos from awx-logos repository.
  ## I think the default logo that comes with AWX itself is horrible, so changing it might be good choice (believe me :)

  ## Replace awx_official parameter
  sed -i -E "s|^#([[:space:]]?)awx_official=false|awx_official=true|g" inventory

cat <<EOF >> vars.yml
admin_user: 'awx-admin'
admin_password: 'CHANGE_ME'
pg_password: 'pgpass'
secret_key: 'mysupersecret'
awx_official: 'true'
EOF

  ## ansible-playbook -i inventory install.yml
  ## ansible-playbook -i inventory install.yml -e @vars.yml
  ## ansible-playbook -i inventory install.yml -e @vars.yml -e 'ansible_python_interpreter=/usr/bin/python3'

  echo "Ansible AWX is now installed on your CentOS system"
}

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'yum check-update && yum -y update'"
  exit
fi

# Update packages URL
update_packages_repo_url

# Update package list and upgrade all packages

#sudo yum check-update
#sudo yum clean all
#sudo yum -y update

# Required packages Installation
required_packages_installation

# Docker Installation
docker_installation

# Docker Compose Installation
docker_compose_installation

# Ansible Installation
ansible_installation

# Ansibe AWX Installation
ansible_awx_installation

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created Ansible AWX dev virtual machine."
# echo "Shuting down !"
# sudo shutdown -h now