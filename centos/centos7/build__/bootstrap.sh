#!/bin/sh

VBOX_VERSION=6.1.10

v_box_guest_aditions_installation(){
  echo "########## Installing VBoxGuestAdditions $VBOX_VERSION"
  echo "########## Downloading tools ===>>>>"
  sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  sudo rpm -Uvh http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/d/dkms-2.6.1-1.el7.noarch.rpm

  sudo yum -y install wget perl gcc dkms kernel-devel kernel-headers make bzip2
  echo "########## Downloading VBoxGuestAdditions ===>>>>"
  sudo cd /opt && sudo wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso -O /opt/VBGAdd.iso
  sudo mount /opt/VBGAdd.iso -o loop /mnt
  echo "########## Running VBoxGuestAdditions ===>>>>"
  sudo sh /mnt/VBoxLinuxAdditions.run --nox11
  sudo umount /mnt
  echo "########## Cleaning files ===>>>>"
  sudo rm /opt/VBGAdd.iso
  cat /dev/null > ~/.bash_history
}

# Update package list and upgrade all packages
yum check-update
yum clean all && rm -rf /var/cache/yum
yum -y update

v_box_guest_aditions_installation

# sudo /etc/init.d/vboxadd setup

echo "Successfully created virtual machine."
echo ""