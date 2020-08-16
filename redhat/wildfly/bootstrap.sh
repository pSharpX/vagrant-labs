#!/bin/sh

JAVA_8=1.6.0
JAVA_7=1.7.0
JAVA_8=1.8.0
JAVA_VERSION=$JAVA_8
M2_VERSION=3.6.3
GRADLE_VERSION=6.2.1
WILDFLY_VERSION=18.0.1

java_installation(){
  echo "########## Installing Java $JAVA_VERSION"
  yum -y install java-$JAVA_VERSION-openjdk-devel

  echo "########## Java Version"
  java -version

  JAVA_HOME_VAR=$(dirname $(dirname $(readlink $(readlink $(which javac)))))

  echo "########## Setting Java environment variables"
  sudo sh -c "echo export JAVA_HOME=$JAVA_HOME_VAR >> /etc/profile"
  sudo sh -c "echo export PATH=$PATH:$JAVA_HOME_VAR/bin >> /etc/profile"
  sudo sh -c "echo export CLASSPATH=.:$JAVA_HOME_VAR/jre/lib:$JAVA_HOME_VAR/lib:$JAVA_HOME_VAR/lib/tools.jar >> /etc/profile"

  # source the file or logout and back in.
  source /etc/profile

  echo $JAVA_HOME
  echo $PATH
  echo $CLASSPATH

  echo "Java $JAVA_VERSION is now installed on your CentOS system"
}

maven_installation(){
  echo "########## Installing Maven $M2_VERSION"
  
  echo "########## Downloading Apache Maven $M2_VERSION"
  wget -nv https://www-us.apache.org/dist/maven/maven-3/$M2_VERSION/binaries/apache-maven-$M2_VERSION-bin.tar.gz -P /tmp

  # When the download is completed, extract the archive in the /opt directory:
  sudo tar xf /tmp/apache-maven-$M2_VERSION-bin.tar.gz -C /opt

  echo "Removing /tmp/apache-maven-$M2_VERSION-bin.tar.gz"
  sudo rm /tmp/apache-maven-$M2_VERSION-bin.tar.gz

  # we will create a symbolic link maven that will point to the Maven installation directory:
  sudo ln -s /opt/apache-maven-$M2_VERSION /opt/maven

  # Setup environment variables
  sudo touch /etc/profile.d/maven.sh
  echo "########## Setting Maven environment variables"

  echo export M2_HOME=/opt/maven >> /etc/profile.d/maven.sh
  echo export MAVEN_HOME=/opt/maven >> /etc/profile.d/maven.sh
  echo export PATH=$PATH:/opt/maven/bin >> /etc/profile.d/maven.sh

  # Make the script executable by running the following chmod command:
  sudo chmod +x /etc/profile.d/maven.sh
  # sudo chown vagrant: /etc/profile.d/maven.sh

  # source the file or logout and back in.
  source /etc/profile.d/maven.sh

  echo "########## Maven Version"
  mvn -version

  echo $M2_HOME
  echo $MAVEN_HOME
  echo $PATH

  echo "Apache Maven $M2_VERSION is now installed on your CentOS system"
}

gradle_installation(){
  echo "########## Installing Gradle $GRADLE_VERSION"

  echo "########## Downloading Gradle $GRADLE_VERSION"
  wget -nv https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip -P /tmp

  #  extract the zip file in the /opt/gradle directory:
  echo "########## Extracting zip file to /opt/gradle"
  sudo unzip -q -d /opt/gradle /tmp/gradle-$GRADLE_VERSION-bin.zip

  echo "Removing /tmp/gradle-$GRADLE_VERSION-bin.zip"
  sudo rm /tmp/gradle-$GRADLE_VERSION-bin.zip

  # Verify that the Gradle files are extracted by listing the /opt/gradle/gradle-* directory
  ls /opt/gradle/gradle-$GRADLE_VERSION

  # Setup environment variables
  # sudo touch /etc/profile.d/gradle.sh # [1] Not working. Export PATH in this file not being recognized
  echo "########## Setting Gradle environment variables"

  # echo export GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION >> /etc/profile.d/gradle.sh
  # echo export PATH=$PATH:/opt/gradle/gradle-$GRADLE_VERSION/bin >> /etc/profile.d/gradle.sh
  echo export GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION >> /etc/profile
  echo export PATH=$PATH:/opt/gradle/gradle-$GRADLE_VERSION/bin >> /etc/profile

  # Make the script executable by running the following chmod command:
  # sudo chmod +x /etc/profile.d/gradle.sh # [1] Not working. Export PATH in this file not being recognized
  # sudo chown vagrant: /etc/profile.d/gradle.sh # [1] Not working. Export PATH in this file not being recognized

  # source the file or logout and back in.
  # source /etc/profile.d/gradle.sh # [1] Not working. Export PATH in this file not being recognized
  source /etc/profile

  echo "########## Gradle Version"
  gradle  -v

  echo $GRADLE_HOME
  echo $PATH

  echo "Gradle $GRADLE_VERSION is now installed on your CentOS system"
}

wildfly_installation(){
  echo "########## Installing Wildfly $WILDFLY_VERSION"

  # Running WildFly as the root user is a security risk and not considered best practice
  # To modifiy vagrant user and create a group named wildfly with home directory /opt/wildfly
  sudo groupadd -r wildfly

  # To add an existing user to a secondary group, use the usermod -a -G command followed the name of the group and the user:
  sudo usermod -a -G vagrant wildfly
  
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

  sudo echo JAVA_HOME=$JAVA_HOME >> /etc/wildfly/wildfly.conf
  sudo echo WILDFLY_HOME=/opt/wildfly >> /etc/wildfly/wildfly.conf
  sudo echo JBOSS_USER=wildfly >> /etc/wildfly/wildfly.conf
  sudo echo WILDFLY_USER=wildfly >> /etc/wildfly/wildfly.conf

  # Change Wildfly user define in wildfly.service
  sudo sed -n 's/User=wildfly/User=vagrant/g' /etc/systemd/system/wildfly.service

  # The scripts inside bin directory must have executable flag
  sudo sh -c 'chmod +x /opt/wildfly/bin/*.sh'

  # Change the directory ownership to user and group wildfly with the following chown command :
  sudo chown -RH vagrant: /opt/wildfly

  # Reload systemd service
  sudo systemctl daemon-reload

  # Start and enable WildFly service:
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

# Install unzip on CentOS and Fedora
# yum -y install unzip

# Java Installation
# java_installation

# Maven Installation
# maven_installation

# Gradle Installation
# gradle_installation

# Wildfly Installation
wildfly_installation

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created Wildfly Dev virtual machine."
echo "Shuting down !"
sudo shutdown -h now