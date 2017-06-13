#!/bin/sh

set -Ceu

user=$1
shift
source=$1
shift
dest=$1
shift

scp -i bch20170503-ec2.pem -o userknownhostsfile=known_hosts \
  "$source" "ubuntu@ssh.$user.stack.probcomp.net:$dest" $@
