#!/bin/bash

## Yay(AUR Helper) Installation

install_yay_dependencies(){
  echo "******** Check git avalability: "
  if [[ "$(git --help 2> /dev/null)" == "" ]]; then

      echo "******** Git is not installed!"
      # Create NGINX cache directories and set proper permissions
      echo "******** Installing Git..."
      sudo pacman -S git --noconfirm
  fi
  sudo pacman -S base-devel --noconfirm
}

install_yay(){
  echo "******** Installing Yay(AUR Helper)..."
  
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -sri --noconfirm
}

## Yay(AUR Helper) Installation
echo "******** Yay(AUR Helper) Installation"

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'pacman -Syu'"
  exit
fi

sudo pacman-key --init
sudo pacman-key --populate
sudo pacman-key --refresh-keys
sudo pacman -Sy archlinux-keyring --noconfirm

echo "******** Updating system..."
sudo pacman -Syu --noconfirm

# Yay(AUR Helper) dependencies installation
echo "******** Yay(AUR Helper) dependencies installation..."
install_yay_dependencies

# Yay(AUR Helper) Installation
echo "******** Yay(AUR Helper) installation..."
install_yay

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"