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
            echo "`echo ${action%e} | tr cu CU`ing probcomp-stack-oreilly-$i"
            ./stack.sh $action $prefix-$i $instance $ami_id &
            sleep 2
        done
        wait
        ;;
    delete)
        for i in `seq $from $to`
        do
            echo "Deleting probcomp-stack-oreilly-$i"
            aws cloudformation delete-stack --stack-name probcomp-stack-oreilly-$i
        done
        ;;
    *)
        printf >&2 'Unknown action %s\n' "$action"
        exit 1
        ;;
esac
