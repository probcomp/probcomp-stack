#!/bin/sh

set -Ceu

name=$1

rm -f ~/hostname.tmp
echo "$1" > ~/hostname.tmp
sudo mv ~/hostname.tmp /etc/hostname
sudo hostname "$1"
