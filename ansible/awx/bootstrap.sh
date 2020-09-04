#!/bin/sh

# **************** Install Ansible AWX on CentOS 8 ****************

required_packages_installation(){
  echo ">>>>>>>>>> Install the EPEL repository in your system"
  dnf install epel-release -y

  echo ">>>>>>>>>> Install some additional packages required to run AWX on your system"
  dnf install git gcc gcc-c++ nodejs gettext device-mapper-persistent-data lvm2 bzip2 -y
}

docker_installation(){
  echo ">>>>>>>>>> Installing docker-ce repository"
  dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

  echo ">>>>>>>>>> Installing docker-ce"
  dnf -y install docker-ce --nobest

  # Start the Docker service and enable it to start after system reboot
  systemctl enable docker
  # To join the docker group that is allowed to use the docker daemon
  sudo usermod -G docker -a $USER

  # Restart the docker daemon
  sudo systemctl restart docker

  # Verify the status of Docker service
  systemctl status docker

  echo "docker-ce is now installed on your CentOS system"
}

ansible_installation(){
  echo ">>>>>>>>>> Installing Ansible"
  dnf install ansible python3-pip -y

  echo ">>>>>>>>>> Ansible Version"
  ansible --version

  echo "Ansible is now installed on your CentOS system"
}

docker_compose_installation(){
  echo ">>>>>>>>>> Installing Docker compose"
  pip3 install docker-compose

  echo ">>>>>>>>>> Docker compose Version"
  docker-compose --version

  echo "Docker compose is now installed on your CentOS system"
}

ansible_awx_installation(){
  echo ">>>>>>>>>> Installing Ansible AWX"
  ## Change dir to the home directory.
  cd ~

  ## Get the latest release of ansible awx tarball and extract it. 
  echo ">>>>>>>>>> Downloading the latest release of ansible awx tarball"
  LATEST_AWX=$(curl -s https://api.github.com/repos/ansible/awx/tags |egrep name |head -1 |awk '{print $2}' |tr -d '"|,')
  curl -L -o ansible-awx-$LATEST_AWX.tar.gz https://github.com/ansible/awx/archive/$LATEST_AWX.tar.gz && \
  tar xvfz ansible-awx-$LATEST_AWX.tar.gz && \
  rm -f ansible-awx-$LATEST_AWX.tar.gz

  ## Download and extract awx-logos repository. 
  echo ">>>>>>>>>> Downloading awx-logos repository"
  ## (We could use git to clone the repo; but it requires git to be installed on the host.)
  curl -L -o awx-logos.tar.gz https://github.com/ansible/awx-logos/archive/master.tar.gz
  tar xvfz awx-logos.tar.gz

  ## Rename awx-logos-master folder as awx-logos  
  mv awx-logos-master awx-logos

  ## Remove tarball
  rm -f *awx*.tar.gz

  ## Enter awx folder.  
  cd awx-$LATEST_AWX

  # Initial Configurations
  echo ">>>>>>>>>> AWX: Initial Configurations"

  ## The tarball includes bunch of ansible playbooks and roles to install AWX with an inventory file that holds default configuration variables.
  ## We are going to change the inventory file (located at installer/invetory) in order to deploy AWX with additional configurations like https support, official logos etc.
  

  ## 1)

  ## By default, installer deploys AWX via docker-compose and uses official awx docker images which published on dockerhub to creates postgresql, redis, 
  ## and a nginx based frontend container that required by AWX.

  ## But if you want to do some additional configurations like https support; you need to build your local awx images by comment out
  ## Disable dockerhub reference in order to build local images.

  # sed -i "s|^dockerhub_base=ansible|#dockerhub_base=ansible|g" installer/inventory

  ## Note: As of AWX version 6.1.0, the only way to enable https support is building local images. 
  ## So, if you want to use official awx images from dockerhub, you SSL setup that we cover later in this post, cannot be done!

  ## 2)

  # As mentioned above, AWX requires a postgreSQL database and installer will automatically create a psql container for it. But in order to keep data in a persistent location, we need to create a folder to hold the db files in the host system and tell its path to the installer via postgres_data_dir variable.

  ## Create a folder in /opt/ to hold awx psql data
  mkdir -p /opt/awx-psql-data

  ## Provide psql data path to installer.
  sed -i "s|^postgres_data_dir.*|postgres_data_dir=/opt/awx-psql-data|g" installer/inventory

  ## 3)

  ## Next parameters we’ll change is ssl_certificate which tells the installer enable https support for the frontend with the provided ssl key pair. 
  ## (By default it only supports http.). With this parameter, we need to provide “a file” that should includes both a SSL certificate and its private key.

  ## In this step, I’ll create a self-signed SSL located at /etc/awx-ssl/ folder and merge the .key and .crt files in another file at /etc/awx-ssl/awx-bundled-key.crt. Then I’ll pass the file path to ssl_certificate variable:

  ## Create awx-ssl folder in /etc.
  # mkdir -p /etc/awx-ssl/

  ## Make a self-signed ssl certificate
  # openssl req -subj '/CN=secops.tech/O=Secops Tech/C=TR' \
  #   -new -newkey rsa:2048 \
  #   -sha256 -days 1365 \
  #   -nodes -x509 \
  #   -keyout /etc/awx-ssl/awx.key \
  #   -out /etc/awx-ssl//awx.crt

  ## Merge awx.key and awx.crt files
  # cat /etc/awx-ssl/awx.key /etc/awx-ssl/awx.crt > /etc/awx-ssl/awx-bundled-key.crt
  
  ## Pass the full path of awx-bundled-key.crt file to ssl_certificate variable in inventory.
  # sed -i -E "s|^#([[:space:]]?)ssl_certificate=|ssl_certificate=/etc/awx-ssl/awx-bundled-key.crt|g" installer/inventory

  ## 4)

  ## Next changes is use of eye-candy AWX logos from awx-logos repository.
  ## I think the default logo that comes with AWX itself is horrible, so changing it might be good choice (believe me :)

  ## Replace awx_official parameter
  sed -i -E "s|^#([[:space:]]?)awx_official=false|awx_official=true|g" installer/inventory

  ## 5)

  ## Next, we need to change admin_userand admin_passwordparameters. 
  ## By default, installer creates a super user and you can access the AWX ui with “admin/password” credentials. 
  ## However changing the defaults is a good habit.

  ## Define the default admin username
  sed -i "s|^admin_user=.*|admin_user=awx-admin|g" installer/inventory

  ## Set a password for the admin
  sed -i "s|^admin_password=.*|admin_password=CHANGE_ME|g" installer/inventory

  ## Installation
  ## As I said before, AWX comes with a installer ansible playbooks/roles which makes the whole installation process simple. 
  ## When you done with your configuration changes in the inventory file, you can just run the installer playbook like below:

  ## Enter the installer directory.
  cd ~/awx-$LATEST_AWX/installer

  ## Initiate install.yml
  ansible-playbook -i inventory install.yml

  echo "Ansible AWX is now installed on your CentOS system"
}

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'yum check-update && yum -y update'"
  exit
fi


# Update package list and upgrade all packages
yum check-update
yum clean all
yum -y update

# Required packages Installation
required_packages_installation

# Docker Installation
docker_installation

# Ansible Installation
ansible_installation

# Docker Compose Installation
docker_compose_installation

# Ansibe AWX Installation
ansible_awx_installation

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created Ansible AWX dev virtual machine."
# echo "Shuting down !"
# sudo shutdown -h now