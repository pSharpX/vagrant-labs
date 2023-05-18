#!/bin/bash

## Jenkins Installation

# Installing Jenkins Dependencies
installing_dependencies(){    
    #  Install tools and dependencies
    apt-get install -y git ca-certificates curl gnupg

    #  Installation of Java
    apt-get install -y openjdk-17-jdk openjdk-17-jre

    # Verify the Java version using the following command
    java -version
}

jenkins_installation(){
    # Add the repository key to your system
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

    # Next, let’s append the Debian package repository address to the server’s sources.list:
    sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

    # Run apt update so that apt will use the new repository.
	apt-get update
	sudo apt install -y jenkins
}

configure_jenkins(){
    # To automatically start Jenkins and containerd on boot for other Linux distributions using systemd, run the following commands
    echo "******** Enabling Jenkins to start on boot and start Jenkins immediately:"
    sudo systemctl enable jenkins.service

    # To set up a UFW firewall
    # If the firewall is inactive, the following commands will allow OpenSSH and enable the firewall
    sudo ufw allow OpenSSH
    sudo ufw enable

    # By default, Jenkins runs on port 8080. Open that port using ufw
    sudo ufw allow 8080

    # Check ufw’s status to confirm the new rules
    sudo ufw status
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_for_jenkins_on_timestamp
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
echo "******** Installating Jenkins Dependencies..."
installing_dependencies

echo "******** Installating Jenkins Dependencies..."
jenkins_installation

echo "******** Configuring Jenkins service..."
configure_jenkins

# Running Jenkins
echo "******** Running Jenkins"
sudo systemctl start jenkins.service

# Check if Jenkins will automatically initiate after a reboot
echo "******** Checking if Jenkins will automatically initiate after a reboot"
sudo systemctl is-enabled jenkins.service

# Checking if Jenkins is running by running one of the following commands 
echo "******** Checking if Jenkins is running by running one of the following commands"
sudo systemctl status jenkins.service

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"