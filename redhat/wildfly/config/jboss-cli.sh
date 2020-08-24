#!/bin/sh

jboss-cli.sh --connect --command="deploy target/javaee7-1.0-SNAPSHOT.war --force"

jboss-cli.sh --connect --command=deployment-info

jboss-cli.sh --connect --command="undeploy javaee7-1.0-SNAPSHOT.war"