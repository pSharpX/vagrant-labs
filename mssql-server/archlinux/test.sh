#!/bin/bash

echo "******** Check git avalability: "
if [[ "$(git --help 2> /dev/null)" == "" ]]; then
    
    # Create NGINX cache directories and set proper permissions
    echo "******** Git is not installed!"
    exit
fi

echo "******** Test completed successfully !"