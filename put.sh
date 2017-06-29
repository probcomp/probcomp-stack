#!/bin/sh

set -Ceu

user=$1
shift
source=$1
shift
dest=$1
shift

rsync -e "ssh -i bch20170503-ec2.pem \
  -o UserKnownHostsFile=known_hosts/$user \
  -o CheckHostIP=no \
  -o StrictHostKeyChecking=yes" \
  ${1+"$@"} "$source" "ubuntu@ssh.$user.stack.probcomp.net:$dest"
