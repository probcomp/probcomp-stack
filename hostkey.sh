#!/bin/sh

set -Ceu

user=$1

./aws/hostkey.sh "probcomp-stack-$user" "ssh.$user.stack.probcomp.net"
