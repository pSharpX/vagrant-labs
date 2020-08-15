#!/bin/bash

#Heavily inspired by clivewalkden/centos-7-package.sh
# ( https://gist.github.com/clivewalkden/b4df0074fc3a84f5bc0a39dc4b344c57 )
#However, this one was tested... 2017-JAN-09

VBOX_VERSION=6.1.10

vagrant init centos/7
vagrant up
vagrant ssh -c "sudo yum -y update"
vagrant ssh -c "sudo yum -y install wget nano kernel-devel gcc"
vagrant ssh -c "sudo cd /opt && sudo wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso -O /opt/VBGAdd.iso"
vagrant ssh -c "sudo mount /opt/VBGAdd.iso -o loop /mnt"
vagrant ssh -c "sudo sh /mnt/VBoxLinuxAdditions.run --nox11"
vagrant ssh -c "sudo umount /mnt"
vagrant ssh -c "sudo rm /opt/VBGAdd.iso"

#Check that we can halt and boot
vagrant halt
vagrant up

#Halt again and package
vagrant halt
#vagrant package

#And finally, clean up 
# mv package.box centos7vb.box
vagrant package --vagrantfile Vagrantfile --output centos7-primary.box
# rm Vagrantfile
vagrant destroy -f
