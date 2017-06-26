#!/bin/sh

set -Ceu

USER=$1
shift

: ${SSH:=ssh}

exec ${SSH} -i bch20170503-ec2.pem \
  -o UserKnownHostsFile=./known_hosts \
  -o CheckHostIP=no \
  "ubuntu@ssh.$USER.stack.probcomp.net" "$@"
