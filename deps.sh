#!/bin/bash

PACKAGES="build-essential nodejs"

cd /home

apt-get update
apt-get install curl -y

curl -sL https://deb.nodesource.com/setup_14.x | bash -

apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances \
    --no-pre-depends ${PACKAGES} | grep "^\w")
