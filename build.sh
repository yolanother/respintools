#!/bin/bash

cd `dirname $0`
path=`dirname $(readlink -f $0)`

if [ ! -d dist ]; then
    mkdir dist
fi

buildall=""
if [ "$1" == "build-all" ]; then
    buildall="build-all"
    shift
fi

submit=""
if [ "$1" == "submit" ]; then
    submit="submit"
    shift
fi

if [ -n "$1" ]; then
    echo $* | xargs -d ' ' -i ./create-deb build packages/{}
fi

if [ -n "$buildall" ]; then
    ls -c1 packages | xargs -i ./create-deb build packages/{}
fi
find packages -name "*.deb" -exec mv {} dist/ \;
./create-deb refresh-repo $path/repo.header dist/ $path/../doubtech-gpg

if [ -n "$submit" ]; then
    rsync -avz -e ssh dist/ yolan@doubtech.com:ubuntu.doubtech.com/dists/ubuntumobi
fi
