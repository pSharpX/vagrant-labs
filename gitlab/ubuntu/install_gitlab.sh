#!/bin/bash

## Gitlab Installation

# Installing Gitlab Dependencies
installing_dependencies(){    
    #  Install tools and dependencies
    apt-get install -y git ca-certificates curl openssh-server tzdata perl

    # Install Postfix to send emails
    debconf-set-selections <<< "postfix postfix/mailname string cluster.gitlab.pe"
    debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
    apt-get install --assume-yes postfix

    #  Installation of Java
    apt-get install -y openjdk-17-jdk openjdk-17-jre

    # Verify the Java version using the following command
    java -version
}

gitlab_installation(){
    # Add the gitlab repository to your system
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

    # Run apt update so that apt will use the new repository.
	apt-get update

    # Disabling this option since gitlab package is not present in ubuntu 23.04 yet
    #sudo EXTERNAL_URL="http://cluster.gitlab.pe" apt-get install -y gitlab-ce

    wget --content-disposition https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/bionic/gitlab-ce_14.1.2-ce.0_amd64.deb/download.deb

    dpkg -i gitlab-ce_14.1.2-ce.0_amd64.deb
}

configure_gitlab(){
    # To automatically start Gitlab and containerd on boot for other Linux distributions using systemd, run the following commands
    echo "******** Enabling Gitlab to start on boot and start Gitlab immediately:"
    
    sed -i "/^external_url/ s|'.*|'http://cluster.gitlab.pe'|" /etc/gitlab/gitlab.rb

    # Run the following command to reconfigure the services of gitlab:
    gitlab-ctl reconfigure

    # Now, using the following command, you will start the gitlab services on your system.
    gitlab-ctl start

    # You can also check the status of services either running on your system
    sudo gitlab-ctl status

    sudo cat /etc/gitlab/initial_root_password | grep 'Password:'
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_for_gitlab_on_timestamp
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
echo "******** Installating Gitlab Dependencies..."
installing_dependencies

echo "******** Installating Gitlab Dependencies..."
gitlab_installation

echo "******** Configuring Gitlab service..."
configure_gitlab

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"