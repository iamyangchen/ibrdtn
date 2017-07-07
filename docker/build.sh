#!/bin/bash

cd ../ibrdtn
cd ibrdtn && make dist
cd ../ibrcommon && make dist
cd ../daemon && make dist
cd ../tools && make dist

cd ../../docker/
cp ../ibrdtn/ibrdtn/ibrdtn-1.0.1.tar.gz ./
cp ../ibrdtn/daemon/ibrdtnd-1.0.1.tar.gz ./
cp ../ibrdtn/ibrcommon/ibrcommon-1.0.1.tar.gz ./
cp ../ibrdtn/tools/ibrdtn-tools-1.0.1.tar.gz ./

docker build -t ibrdtn .