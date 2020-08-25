#!/bin/sh

echo "Updating system..."
sudo yum update -y

echo "Adding user vagrant to vboxsf group (to access shared folder) ..."
sudo gpasswd -a vagrant vboxsf
sudo chown -R vagrant: /media/sf_vagrant

echo "Setting default keyboard..."
sudo localectl set-x11-keymap pt

echo "Installing wget..."
sudo yum -y install wget

echo "Updating metadata cache to install unzip..."
sudo yum -y makecache
echo "Installing unzip..."
sudo yum -y install unzip

echo "Initial script finished!"

echo "preparing xfce installation..."

echo "installing epel-release required for xfce..."
sudo yum -y install epel-release

echo "installing xfce desktop environment..."
yum -y groupinstall x11
yum -y groups install "Xfce"

echo "setting graphical environment as default..."
systemctl set-default graphical.target

echo "Shuting down!"
sudo shutdown -h now