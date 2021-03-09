#!/bin/sh

# Edit the following to change database configuration
export APP_PROJECT_NAME="shopify_api"
export APP_DATABASE_USER="pgsql_admin"
export APP_DATABASE_PASS='pgsql_admin123'
export APP_DATABASE_NAME="shopify_db"

# Change only if there is trouble using these ip's or ports
export APP_DATABASE_HOST="192.168.99.14"
export APP_DATABASE_PORT=3306