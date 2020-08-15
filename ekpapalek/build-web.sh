#!/bin/sh

REPOSITORY=${GIT_REPOSITORY}
DATABASE_NAME=${APP_DATABASE_NAME}
DATABASE_USER=${APP_DATABASE_USER}
DATABASE_PASSWORD=${APP_DATABASE_PASS}
DATABASE_HOST=${APP_DATABASE_HOST}
DATABASE_PORT=${APP_DATABASE_PORT}
APPLICATION_PORT=${APP_WEB_PORT}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'apt-get update && apt-get upgrade'"
  echo ""
  exit
fi

apt update
apt -y upgrade

echo "******** Installing jq and moreutils"
apt-get -y install jq
apt install -y moreutils

if [[ "$(python3 --version 2> /dev/null)" == "" ]]; then
    echo "******** Python3 was not found. We'll continue installing python .."
    apt install -y software-properties-common
    add-apt-repository ppa:deadsnakes/ppa
    apt update
    apt install -y python3.6
fi
echo "******** Checking python3 version installed"
echo "$(python3 ––version)"

echo "******** Installing Pip, a package manager for python"
apt install -y python3-pip

echo "******** Installing aditional tools por development"
apt install -y build-essential libssl-dev libffi-dev python3-dev

echo "******** Installing django package"
pip3 install Django==2.0.6

echo "******** Installing virtualenv using pip3"
pip3 install virtualenv

echo "******** Installation completed successfully !"

# Get the ekpapalek git repo
echo "Clonning the following repo https://gitlab.com/iisotec/ekpapalek.git"
mkdir -p /repo
if [ ! -d "/repo/ekpapalek" ]; then
  git clone $REPOSITORY /repo/ekpapalek
fi
chown -R vagrant:vagrant /repo/ekpapalek

echo "******** Moving to the repo root directory and copying the json config file"
cd /repo/ekpapalek
cp config/example_config.json_copy config/develop.json

echo "******** Updating the database-config secction in develop.json file"
cat config/develop.json | jq '.["database-config"].db_name = $v' --arg v $DATABASE_NAME | sponge config/develop.json
cat config/develop.json | jq '.["database-config"].db_user = $v' --arg v $DATABASE_USER | sponge config/develop.json
cat config/develop.json | jq '.["database-config"].db_password = $v' --arg v $DATABASE_PASSWORD | sponge config/develop.json
cat config/develop.json | jq '.["database-config"].db_host = $v' --arg v $DATABASE_HOST | sponge config/develop.json
cat config/develop.json | jq '.["database-config"].db_port = $v' --arg v $DATABASE_PORT | sponge config/develop.json

# Installing dependencies for ekpapalek

echo "******** Installing dependencies for ekpapalek"
pip3 install -r requirements.txt

echo "******** Making first migrations"
python3 ./manage.py makemigrations

echo "******** Running migrations"
python3 ./manage.py migrate

echo "******** Creating super user"
python3 ./manage.py createsuperuser

echo "Run the application typing the following command: python3 ./manage.py runserver 0.0.0.0:8000"
echo "http://localhost:${APPLICATION_PORT}/"
echo "It's DONE !!"