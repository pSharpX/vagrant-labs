#!/bin/sh -e

# MariaDB (MySQL Forks)

# Edit the following to change the name of the database user that will be created:
APP_DB_USER=${APP_DATABASE_USER}
APP_DB_PASS=${APP_DATABASE_PASS}

# Edit the following to change the name of the database that is created (defaults to the user name)
APP_DB_NAME=${APP_DATABASE_NAME}
APP_DB_PORT=${APP_DATABASE_PORT}

# Edit the following to change the version of MySQL that is installed
MDB_VERSION=10.5.9

###########################################################
# Changes below this line are probably not necessary
###########################################################

print_db_usage () {
  echo "Your MySQL database has been setup and can be accessed on your local machine on the forwarded port (default: 3306)"
  echo "  Host: localhost"
  echo "  Port: $APP_DB_PORT"
  echo "  Database: $APP_DB_NAME"
  echo "  Username: $APP_DB_USER"
  echo "  Password: $APP_DB_PASS"
  echo ""
  echo "Admin access to postgres user via VM:"
  echo "  vagrant ssh"
  echo "  sudo mysql -u root -p $APP_DB_PASS"
  echo ""
  echo "mysql access to app database user via VM:"
  echo "  vagrant ssh"
  echo "  sudo mysql -u $APP_DB_USER -p $APP_DB_PASS"
  echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost $APP_DB_NAME"
  echo ""
  echo "Env variable for application development:"
  echo "  DATABASE_URL=mysql://$APP_DB_USER:$APP_DB_PASS@localhost:$APP_DB_PORT/$APP_DB_NAME"
  echo ""
  echo "Local command to access the database via psql:"
  echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost -p $APP_DB_PORT $APP_DB_NAME"
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'apt-get update && apt-get upgrade'"
  echo ""
  print_db_usage
  exit
fi


###########################################################
# Installation
###########################################################

# You can also create a custom MariaDB sources.list file.
MDB_REPO_APT_SOURCE=/etc/apt/sources.list.d/MariaDB.list
if [ ! -f "$MDB_REPO_APT_SOURCE" ]
then
  echo "MariaDB 10.5 repository list - created $(date)"
  echo "Updating source list"
  # MariaDB 10.5 repository list - created 2021-03-09 01:25 UTC
  # http://downloads.mariadb.org/mariadb/repositories/
  echo "deb [arch=amd64,arm64,ppc64el] http://sgp1.mirrors.digitalocean.com/mariadb/repo/10.5/ubuntu $(lsb_release -cs) main" > "$MDB_REPO_APT_SOURCE"
  echo "deb-src http://sgp1.mirrors.digitalocean.com/mariadb/repo/10.5/ubuntu $(lsb_release -cs) main" > "$MDB_REPO_APT_SOURCE"

  sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
fi

# Update package list and upgrade all packages
echo "Update package list and upgrade all packages"
sudo apt-get -y update
sudo apt-get -y install software-properties-common

# Once the key is imported and the repository added you can install MariaDB 10.5 from the MariaDB repository with:
echo "Installing MariaDB 10.5 from the MariaDB repository"
# sudo apt-get -y install mariadb-server galera-4 mariadb-client libmariadb3 mariadb-backup mariadb-common
sudo apt-get -y install mariadb-server mariadb-client libmariadb3 mariadb-common


# The MariaDB service will start automatically, to verify it type
echo "Checking MariaDB status"
sudo systemctl status mariadb
sudo mysql -V


###########################################################
# Configuration
###########################################################

# Make sure that NOBODY can access the server without a password
echo "Configuring users and databases"
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('$APP_DB_PASS') WHERE User = 'root'"
 
# Kill the anonymous users
sudo mysql -e "DROP USER IF EXISTS ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
sudo mysql -e "DROP USER IF EXISTS ''@'$(hostname)'"
# Kill off the demo database
sudo mysql -e "DROP DATABASE IF EXISTS test"

echo "Creating $APP_DATABASE_NAME database..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $APP_DATABASE_NAME"
 
echo "Creating production database..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS production"

echo "Creating $APP_DATABASE_USER and grant all permissions to $APP_DATABASE_NAME database..."
sudo mysql -e "CREATE USER IF NOT EXISTS '$APP_DATABASE_USER'@'localhost' IDENTIFIED BY '$APP_DATABASE_PASS'"
sudo mysql -e "GRANT ALL PRIVILEGES ON $APP_DATABASE_NAME.* to '$APP_DATABASE_USER'@'localhost'"

echo "Creating production_user and grant all permissions to production database..." 
sudo mysql -e "CREATE USER IF NOT EXISTS 'production_user'@'localhost' IDENTIFIED BY '$APP_DATABASE_PASS'"
sudo mysql -e "GRANT ALL PRIVILEGES ON production.* to 'production_user'@'localhost'"
 
# Make our changes take effect
sudo mysql -e "FLUSH PRIVILEGES"


# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created MySQL dev virtual machine."
echo ""
print_db_usage