#!/bin/sh

set -Ceu

USER=$1
shift

: ${SSH:=ssh}

exec ${SSH} -i bch20170503-ec2.pem \
  -o UserKnownHostsFile=./known_hosts/$USER \
  -o CheckHostIP=no \
  -o StrictHostKeyChecking=yes \
  "ubuntu@ssh.$USER.stack.probcomp.net" ${1+"$@"}
