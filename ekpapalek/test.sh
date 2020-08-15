#!/bin/sh -e

# Edit the following to change the name of the database user that will be created:
echo "###################################"
echo "\\${APP_DATABASE_PASS}"
echo $APP_DATABASE_PASS
echo \'$APP_DATABASE_PASS\'
echo "###################################"

APP_DB_USER=${APP_DATABASE_USER}
APP_DB_PASS=${APP_DATABASE_PASS}

# Edit the following to change the name of the database that is created (defaults to the user name)
APP_DB_NAME=${APP_DATABASE_NAME}
APP_DB_PORT=${APP_DATABASE_PORT}
