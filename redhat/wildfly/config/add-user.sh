#!/bin/sh

USERNAME=${1:-"admin"}
PASSWORD=${2:-'\$admin123.a'}

ADD_USER="add-user.sh"

echo "******* Adding default wildfly user: $USERNAME"
sh -c "$ADD_USER -u $USERNAME -p $PASSWORD"
echo "******* Wildfly user added successfully"
read -n 1 -s -r -p "Press any key to continue"

# Adding a WildFly User in non-interactive ways

# How to create a management user in the Default Realm
# $ ./add-user.sh -u 'adminuser1' -p 'password1!'

# How to create an Application user belonging to a single group:
# $ ./add-user.sh -a -u 'appuser1' -p 'password1!' -g 'guest'

# Create an Application user belonging to multiple groups:
# $ ./add-user.sh -a -u 'appuser1' -p 'password1!' -g 'guest,app1group,app2group'

# How to create an Application user belonging to single group using alternate properties files:
# $ ./add-user.sh -a -u appuser1 -p password1! -g app1group -sc /home/username/userconfigs/ -up appusers.properties -gp appgroups.properties