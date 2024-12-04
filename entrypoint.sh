#!/bin/bash
cd /root

## get architecture 

## determine which MFT to download

https://www.mellanox.com/downloads/MFT/mft-4.30.0-139-arm64-rpm.tgz
https://www.mellanox.com/downloads/MFT/mft-4.30.0-139-x86_64-rpm.tgz

https://dl.fedoraproject.org/pub/epel/9/Everything/aarch64/Packages/m/mlnx-tools-23.07-1.el9.noarch.rpm
https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/Packages/m/mlnx-tools-23.07-1.el9.noarch.rpm

dnf install MLNXTOOLS


tar -xzf MFTTOOLS 
cd /root/mft-*
./install.sh --without-kernel

sleep infinity & wait
