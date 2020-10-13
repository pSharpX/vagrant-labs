#!/bin/sh

WILDFLY_VERSION=18.0.1

wildfly_installation(){
  echo "########## Installing Wildfly $WILDFLY_VERSION"

  # Running WildFly as the root user is a security risk and not considered best practice
  # To modifiy vagrant user and create a group named wildfly with home directory /opt/wildfly
  sudo groupadd -r wildfly
  # To add an existing user to a secondary group, use the usermod -a -G command followed the name of the group and the user:
  sudo usermod -a -G wildfly vagrant
  
  echo "########## Downloading Wildfly $WILDFLY_VERSION"
  wget -nv https://download.jboss.org/wildfly/$WILDFLY_VERSION.Final/wildfly-$WILDFLY_VERSION.Final.tar.gz -P /tmp
  # When the download is completed, extract the archive in the /opt directory:
  sudo tar xf /tmp/wildfly-$WILDFLY_VERSION.Final.tar.gz -C /opt
  echo "Removing /tmp/wildfly-$WILDFLY_VERSION.Final.tar.gz"
  sudo rm /tmp/wildfly-$WILDFLY_VERSION.Final.tar.gz

  # We will create a symbolic link wildfly that will point to the Wildfly installation directory:
  sudo ln -s /opt/wildfly-$WILDFLY_VERSION.Final /opt/wildfly

  ###### Configure Systemd
  # Start by creating a directory which will hold the WildFly configuration file:
  sudo mkdir -p /etc/wildfly
  # Copy WildFly systemd service, configuration file and start scripts templates from the /opt/wildfly/docs/contrib/scripts/systemd/ directory.
  sudo cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.conf /etc/wildfly/
  sudo cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/
  sudo cp /opt/wildfly/docs/contrib/scripts/systemd/launch.sh /opt/wildfly/bin/

  sudo echo WILDFLY_CONSOLE_BIND=192.168.99.16 >> /etc/wildfly/wildfly.conf
  sudo echo JAVA_HOME=$JAVA_HOME >> /etc/wildfly/wildfly.conf
  sudo echo WILDFLY_HOME=/opt/wildfly >> /etc/wildfly/wildfly.conf
  sudo echo JBOSS_USER=wildfly >> /etc/wildfly/wildfly.conf
  sudo echo WILDFLY_USER=wildfly >> /etc/wildfly/wildfly.conf

  # Setup environment variables
  sudo touch /etc/profile.d/wildfly.sh
  echo "########## Setting Wildfly environment variables"
  echo export JBOSS_HOME=/opt/wildfly >> /etc/profile.d/wildfly.sh
  echo export WILDFLY_HOME=/opt/wildfly >> /etc/profile.d/wildfly.sh
  echo export PATH=\$PATH:/opt/wildfly/bin >> /etc/profile.d/wildfly.sh

  # Make the script executable by running the following chmod command:
  sudo chmod +x /etc/profile.d/wildfly.sh
  # source the file or logout and back in.
  source /etc/profile.d/wildfly.sh

  # The scripts inside bin directory must have executable flag
  sudo sh -c 'chmod +x /opt/wildfly/bin/*.sh'
  # Change the directory ownership to user and group wildfly with the following chown command :
  sudo chown -RH vagrant: /opt/wildfly

  # Change Wildfly user define in wildfly.service
  sudo sed -i 's/User=.*/User=vagrant/g' /etc/systemd/system/wildfly.service
  sudo sed -i 's/ExecStart=.*/ExecStart=\/opt\/wildfly\/bin\/launch.sh $WILDFLY_MODE $WILDFLY_CONFIG $WILDFLY_BIND $WILDFLY_CONSOLE_BIND/g' /etc/systemd/system/wildfly.service
  sudo sed -i 's/$WILDFLY_HOME\/bin\/domain.*/$WILDFLY_HOME\/bin\/domain.sh -c $2 -b $3 -bmanagement $4/g' /opt/wildfly/bin/launch.sh
  sudo sed -i 's/$WILDFLY_HOME\/bin\/standalone.*/$WILDFLY_HOME\/bin\/standalone.sh -c $2 -b $3 -bmanagement $4/g' /opt/wildfly/bin/launch.sh

  sudo mkdir /var/run/wildfly/
  sudo chown vagrant: /var/run/wildfly/

  # Reload systemd service
  sudo systemctl daemon-reload
  echo "########## Starting and enabling WildFly service:"
  sudo systemctl start wildfly
  sudo systemctl enable wildfly

  # Verify that the service is running
  echo "########## Wildfly Status"
  sudo systemctl status wildfly
  echo "Wildfly $WILDFLY_VERSION is now installed on your CentOS system"
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

# Wildfly Installation
wildfly_installation

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created Wildfly Dev virtual machine."
# echo "Shuting down !"
# sudo shutdown -h now