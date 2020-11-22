#!/bin/bash

# SQL Server edition or product key.
SQL_SERVER_PID='Developer'
# SA user password.
SQL_SERVER_SA_PASSWORD='vagrant@2020'
# Configure the TCP port that SQL Server listens on (default 1433).
SQL_SERVER_TCP_PORT=1433
# Directory where the new SQL Server database data files (.mdf) are created.
SQL_SERVER_DATA_DIR=/mssql_data_dir
# Directory where the new SQL Server database log (.ldf) files are created
SQL_SERVER_LOG_DIR=/mssql_log_dir

install_mssql_server(){
  # Import the necessary repository key
  echo "******** Importing the necessary repository key..."
  sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

  echo "******** Adding Microsoft SQL Server 2019 Ubuntu repository..."
  sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"

  # Install MS SQL Server
  echo "******** Installing MS SQL Server"
  sudo apt-get update
  sudo apt-get install -y mssql-server

  # Configure MS SQL server
  # See: https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables?view=sql-server-ver15
  echo "******** Configure MS SQL server"
  sudo ACCEPT_EULA='Y' MSSQL_PID=$SQL_SERVER_PID MSSQL_SA_PASSWORD=$SQL_SERVER_SA_PASSWORD MSSQL_TCP_PORT=$SQL_SERVER_TCP_PORT MSSQL_DATA_DIR=$SQL_SERVER_DATA_DIR MSSQL_LOG_DIR=$SQL_SERVER_LOG_DIR /opt/mssql/bin/mssql-conf setup

  # Enable MSSQL-SERVER to start on boot and start MSSQL-SERVER immediately:
  echo "******** Enabling MSSQL-SERVER to start on boot and start MSSQL-SERVER immediately:"
  sudo systemctl enable mssql-server

  # Running MSSQL-SERVER
  echo "******** Running MSSQL-SERVER"
  sudo systemctl start mssql-server

  # Check if MSSQL-SERVER will automatically initiate after a reboot
  echo "******** Checking if MSSQL-SERVER will automatically initiate after a reboot"
  sudo systemctl is-enabled mssql-server

  # Checking if MSSQL-SERVER is running by running one of the following commands 
  echo "******** Checking if MSSQL-SERVER is running by running one of the following commands"
  sudo systemctl status mssql-server
}

install_mssql_tools(){
  # Import the necessary repository key
  echo "******** Importing the necessary repository key..."
  sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

  echo "******** Adding Microsoft SQL Server Command Line Tools Ubuntu repository..."
  sudo wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
  # sudo wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
  # sudo curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

  # Installing MS SQL tools and unixODBC plugin
  echo "******** Installing MS SQL tools and unixODBC plugin"
  sudo apt-get update
  sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17

  # optional: for bcp and sqlcmd
  sudo ACCEPT_EULA='Y' apt-get install -y mssql-tools

  # optional: for unixODBC development headers
  sudo apt-get install -y unixodbc-dev

  # Configure PATH for MS SQL binaries
  # Add /opt/mssql-tools/bin/ to your PATH environment variable in a bash shell.
  echo "******** Configure PATH for MS SQL binaries"
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /home/vagrant/.bash_profile
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /home/vagrant/.bashrc
  source ~/.bashrc
  source /home/vagrant/.bashrc
}

## MSSQL-SERVER Installation
echo "******** Microsoft SQL Server 2019 Installation on Linux"

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'sudo apt update && sudo apt upgrade -y'"
  exit
fi

lsb_release -ds

# sudo apt update && sudo apt upgrade -y
sudo apt-get update && sudo apt-get upgrade -y

# SQL Server Installation
echo "******** MSSQL Server package installation..."
install_mssql_server

# SQL Server Tools Installation
echo "******** MSSQL Server Command Line Tools package installation..."
install_mssql_tools

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"