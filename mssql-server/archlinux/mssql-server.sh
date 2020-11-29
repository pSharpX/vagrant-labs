#!/bin/bash

# SQL Server edition or product key.
SQL_SERVER_PID='Developer'
# SA user password.
SQL_SERVER_SA_PASSWORD='vagrant@2020'
# Configure the TCP port that SQL Server listens on (default 1433).
SQL_SERVER_TCP_PORT=1433
# Directory where the new SQL Server database data files (.mdf) are created.
# SQL_SERVER_DATA_DIR=/mssql_data_dir
# Directory where the new SQL Server database log (.ldf) files are created
# SQL_SERVER_LOG_DIR=/mssql_log_dir


install_mssql_server(){
  # Install MS SQL Server
  echo "******** Installing MS SQL Server"
  yay -S --noconfirm mssql-server msodbcsql mssql-tools

  # Configure MS SQL server
  # See: https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables?view=sql-server-ver15
  echo "******** Configure MS SQL server"
  sudo ACCEPT_EULA='Y' MSSQL_PID=$SQL_SERVER_PID MSSQL_SA_PASSWORD=$SQL_SERVER_SA_PASSWORD MSSQL_TCP_PORT=$SQL_SERVER_TCP_PORT /opt/mssql/bin/mssql-conf setup
  # sudo ACCEPT_EULA='Y' MSSQL_PID=$SQL_SERVER_PID MSSQL_SA_PASSWORD=$SQL_SERVER_SA_PASSWORD MSSQL_TCP_PORT=$SQL_SERVER_TCP_PORT MSSQL_DATA_DIR=$SQL_SERVER_DATA_DIR MSSQL_LOG_DIR=$SQL_SERVER_LOG_DIR /opt/mssql/bin/mssql-conf setup

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
  # Install MS SQL Server Tools
  echo "******** Installing MS SQL Server Tools"
  
}

## MSSQL-SERVER Installation
echo "******** Microsoft SQL Server 2019 Installation on Linux"

PROVISIONED_ON=/etc/vm_provision_2_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'pacman -Syu'"
  exit
fi

echo "******** Updating system..."
sudo pacman -Syu --noconfirm

# SQL Server Installation
echo "******** MSSQL Server package installation..."
install_mssql_server

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"