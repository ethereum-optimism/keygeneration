#!/bin/bash

# Scratchpad features
BUILD_ESSENTIAL=build-essential/build-essential_12.4ubuntu1_amd64.deb

function build_essential () {
    wget $MIRROR/$BUILD_ESSENTIAL
    FILE=$(echo $BUILD_ESSENTIAL | cut -d / -f2)
    DIGEST=$(shasum -a 256 $FILE | cut -d ' ' -f1)

    EXPECT=$(curl --silent \
        https://packages.ubuntu.com/bionic/amd64/build-essential/download \
        | grep 'SHA256' \
        | grep -oP '(?<=<tt>).*?(?=</tt>)')

    echo "GOT $DIGEST"
    echo "EXPECT $EXPECT"
}

function compare () {
    for FILE in *.deb; do
        PKG=$(echo $FILE | cut -d '_' -f1)
        URL=$MAIN/$PKG/download

        EXPECT=$(curl --silent \
            $URL \
            | grep 'SHA256' \
            | grep -oP '(?<=<tt>).*?(?=</tt>)')
        GOT=$(shasum -a 256 $FILE | cut -d ' ' -f1)

        if [[ "$EXPECT" != "$GOT" ]]; then
            echo "$PKG mismatch"
            echo "Expected: $EXPECT"
            echo "Got:      $GOT"
        else
            echo "$PKG match"
        fi
    done
}
