#!/bin/sh

if [[ "$(python3 --version 2> /dev/null)" == "" ]]; then
    echo "Python was not found. We'll continue installing python .."
fi

read -n 1 -s -r -p "Press any key to continue"