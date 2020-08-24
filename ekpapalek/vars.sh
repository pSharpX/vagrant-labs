#!/bin/sh

# Edit the following to change database configuration
export APP_PROJECT_NAME="ekpapalek"
export APP_DATABASE_USER="pgsql_admin"
export APP_DATABASE_PASS=''
export APP_DATABASE_NAME="ekpapalek_db"

# Change only if there is trouble using these ip's or ports
export APP_DATABASE_HOST="192.168.33.14"
export APP_DATABASE_PORT=5432
export APP_WEB_HOST="192.168.33.13"
export APP_WEB_PORT=8000

# Git credentials for downloading private repository
export GIT_CREDENTIAL_USERNAME=""
export GIT_CREDENTIAL_PASSWORD=''
export GIT_REPOSITORY="https://$GIT_CREDENTIAL_USERNAME:$GIT_CREDENTIAL_PASSWORD@gitlab.com/iisotec/ekpapalek.git"