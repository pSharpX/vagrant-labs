#!/bin/sh

apt update
apt -y upgrade

if [[ "$(python3 --version 2> /dev/null)" == "" ]]; then
    echo "******** Python was not found. We'll continue installing python .."
    apt install software-properties-common
    add-apt-repository ppa:deadsnakes/ppa
    apt update
    apt install python3.6
fi
echo "******** Checking python version installed"
echo $(python3 ––version)

echo "******** Installing Pip, a packager"
apt install -y python3-pip

echo "******** Installing aditional tools por development"
apt install build-essential libssl-dev libffi-dev python3-dev

echo "******** Installing django package"
pip3 install Django==2.0.6

echo "******** Installing virtualenv using pip3"
pip3 install virtualenv

echo "******** Installation completed successfully !"