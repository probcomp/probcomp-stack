#!/bin/sh

set -Ceu

sudo apt-get update -qq

# XXX BEGIN KLUDGE https://bugs.launchpad.net/cloud-init/+bug/1309079
sudo rm /boot/grub/menu.lst
sudo update-grub-legacy-ec2 -y
sudo apt-get upgrade -qq
# XXX END KLUDGE https://bugs.launchpad.net/cloud-init/+bug/1309079

sudo apt-get install -qq lsb-release
sudo apt-get install -qq wget

wget http://probcomp.csail.mit.edu/ubuntu-prerelease/probcomp-ubuntu.asc
echo 127cbe9d37b8944033d61f9416e2a540384136ed4b6a6a431eeee78fe3555308 \
    probcomp-ubuntu.asc \
| sha256sum -c

sudo apt-key add probcomp-ubuntu.asc

echo deb http://probcomp.csail.mit.edu/ubuntu-prerelease \
    $(lsb_release -s -c) main \
| sudo tee /etc/apt/sources.list.d/probcomp.list
sudo apt-get update -qq
sudo apt-get install -qq probcomp-ubuntu-keyring
sudo apt-get install -qq python-bayeslite
sudo apt-get install -qq python-cgpm
sudo apt-get install -qq python-crosscat
sudo apt-get install -qq python-iventure
sudo apt-get install -qq python-pytest
sudo apt-get install -qq python-venture

sudo apt-get install -qq python-pip
sudo apt-get install -qq python-virtualenv
virtualenv --system-site-packages ~/venv
(
    set -Ceu
    . ~/venv/bin/activate
    pip install -U 'ipython<6' jupyter
)

sudo apt-get install -qq letsencrypt
