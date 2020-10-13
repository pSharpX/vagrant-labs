#!/bin/sh

# Upload your archive to WildFly using the following command:
curl -F "file=@target/javaee7-1.0-SNAPSHOT.war" --digest http://u1:p1@localhost:9990/management/add-content

# This command:
#
# Makes a POST request using form-encoded (“-F”) data with one field (“file”) defining the location of the WAR file
# “target/javaee7-1.0-SNAPSHOT.war” is the location of the WAR file
# “u1″ is the administrative user with password “p1″
# “localhost:9090″ is the default management host and port for WildFly instance
# WildFly management port uses digest authentication and that is defined using “–digest”
# Prints the output as something like:
# {“outcome” : “success”, “result” : { “BYTES_VALUE” : “+Dg9u1ALXacrndNdLrT3DQSaqjw=” }}

# Deploy the archive
curl -S -H "Content-Type: application/json" -d '{"content":[{"hash": {"BYTES_VALUE" : "+Dg9u1ALXacrndNdLrT3DQSaqjw="}}], "address": [{"deployment":"javaee7-1.0-SNAPSHOT.war"}], "operation":"add", "enabled":"true"}' --digest http://u1:p1@localhost:9990/management

# This command:
#
# Sends a POST request (“-d”) with JSON payload
# The value assigned to “result” name in the JSON response of previous command is used in this command
# Content type of the payload is explicitly specified to be “application/json”
# “add” command triggers the deployment of the archive
# Application archive is enabled as well, as opposed to not by default
# As earlier, ”u1″ is the administrative user with password “p1″
# As earlier, ”localhost:9090″ is the default management host and port for WildFly instance
# As earlier, WildFly management port uses digest authentication and that is defined using “–digest”