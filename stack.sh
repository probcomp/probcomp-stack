#!/bin/sh

set -Ceu

# Reset the working directory to the script's path
my_abs_path=$(readlink -f "$0")
root_dirname=$(dirname "$my_abs_path")
cd "$root_dirname"

action=$1
user=$2
instance=$3
ami_id=${4:-ami-0f6b2119}

./stack-start.sh $action $user $instance $ami_id

./aws/stackwait.sh probcomp-stack-$user

./stack-finish.sh $user
