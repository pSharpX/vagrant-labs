#!/bin/sh

echo "Updating system..."
sudo yum update -y

echo "Adding user vagrant to vboxsf group (to access shared folder) ..."
sudo gpasswd -a vagrant vboxsf
sudo chown -R vagrant: /media/sf_vagrant

echo "Setting default keyboard..."
sudo localectl set-x11-keymap pt

echo "Initial script finished!"

echo "preparing GNOME installation..."

echo "installing xfce desktop environment..."
yum -y groupinstall "Server with GUI"
# or Workstation

echo "setting graphical environment as default..."
systemctl set-default graphical.target

echo "Shuting down!"
sudo shutdown -h now