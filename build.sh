#!/bin/bash

mkdir -p releases/build_2.0.1-tomasz/vfat
cp -r -f snx_autorun.sh releases/build_2.0.1-tomasz/vfat/
cp -r -f bootstrap releases/build_2.0.1-tomasz/vfat/bootstrap/
cp -f bootstrap/wpa_supplicant.conf.tomasz releases/build_2.0.1-tomasz/vfat/bootstrap/wpa_supplicant.conf

mkdir -p releases/build_2.0.1-tomasz/ext2
cp -r -f data releases/build_2.0.1-tomasz/ext2/data/
chown -R root releases/build_2.0.1-tomasz/ext2/data/
chgrp -R root releases/build_2.0.1-tomasz/ext2/data/
