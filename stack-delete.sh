#!/bin/sh

set -Ceu

user=$1

aws cloudformation delete-stack --stack-name probcomp-stack-$user
./aws/stackwait.sh probcomp-stack-$user
