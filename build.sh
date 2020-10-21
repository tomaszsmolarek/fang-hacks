#!/bin/bash

mkdir -p releases/build_2.0.1-tomasz2/vfat
cp -r -f snx_autorun.sh releases/build_2.0.1-tomasz2/vfat/
cp -r -f bootstrap releases/build_2.0.1-tomasz2/vfat/bootstrap/
cp -f bootstrap/wpa_supplicant.conf.tomasz releases/build_2.0.1-tomasz2/vfat/bootstrap/wpa_supplicant.conf

mkdir -p releases/build_2.0.1-tomasz2/ext2
cp -r -f data releases/build_2.0.1-tomasz2/ext2/data/
cp -f bootstrap/wpa_supplicant.conf.tomasz releases/build_2.0.1-tomasz2/ext2/data/etc/wpa_supplicant.conf
chown -R root releases/build_2.0.1-tomasz2/ext2/data/
chgrp -R root releases/build_2.0.1-tomasz2/ext2/data/
