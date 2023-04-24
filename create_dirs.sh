#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]
then 
    echo "You must run this shell script as root!"
    exit -1
fi

mkdir ./server/
chown -Rv 65532:65532 ./server/