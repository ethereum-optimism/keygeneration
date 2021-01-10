#!/bin/bash

docker run \
    --rm \
    -v $PWD:/home \
    --entrypoint /bin/bash \
    ubuntu:bionic \
    /home/bionic.sh
