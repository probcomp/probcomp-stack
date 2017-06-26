#!/bin/sh

# Throwaway script for starting the fleet of instances for the O'Reilly workshop

set -Ceu

# Reset the working directory to the script's path
my_abs_path=$(readlink -f "$0")
root_dirname=$(dirname "$my_abs_path")
cd "$root_dirname"

action=$1
from=$2
to=$3
instance=$4
prefix=oreilly
ami_id=ami-751b2c63

case $action in
    create|update)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            stack=probcomp-stack-$user
            echo "`echo ${action%e} | tr cu CU`ing $stack"
            ./stack-start.sh $action $user $instance $ami_id &
            sleep 1
        done
        wait
        for i in `seq $from $to`
        do
            user=$prefix-$i
            stack=probcomp-stack-$user
            echo "Waiting for $stack to come up"
            ./aws/stackwait.sh $stack || true
            sleep 1
        done
        for i in `seq $from $to`
        do
            user=$prefix-$i
            stack=probcomp-stack-$user
            echo "Finalizing $stack"
            ./stack-finish.sh $user || true
            sleep 1
        done
        ;;
    delete)
        for i in `seq $from $to`
        do
            echo "Deleting probcomp-stack-oreilly-$i"
            aws cloudformation delete-stack --stack-name probcomp-stack-oreilly-$i
            sleep 1
        done
        ;;
    grab-content)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            echo "Collecting content on probcomp-stack-$user"
            (./login.sh $user 'wget --progress=dot:giga -O - https://probcomp-oreilly20170627.s3.amazonaws.com/content-package.tgz | gunzip -c | tar xf -' 2>&1 | while read line; do echo $user: $line; done) &
        done
        wait
        ;;
    marco-install)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            echo "Installing Marco's stuff on probcomp-stack-$user"
            (./login.sh $user 'cd ~/gen && ./install.sh' 2>&1 | while read line; do echo $user: $line; done) &
        done
        wait
        ;;
    set-passwords)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            echo "Setting the password on probcomp-stack-$user"
            ./set-jupyter-password.sh $user oreilly-passwords/$i.passwd || true
        done
        ;;
    *)
        printf >&2 'Unknown action %s\n' "$action"
        exit 1
        ;;
esac
