#!/bin/sh

# Throwaway script for starting the fleet of instances for the O'Reilly workshop

set -Ceu

# Reset the working directory to the script's path
my_abs_path=$(readlink -f "$0")
root_dirname=$(dirname "$my_abs_path")
cd "$root_dirname"

action=$1
prefix=$2
from=$3
to=$4
instance=${5:-t2.micro}
ami_id=${6:-ami-751b2c63}

case $action in
    create|update)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            stack=probcomp-stack-$user
            echo "`echo ${action%e} | tr cu CU`ing $stack"
            ./stack-start.sh $action $user $instance $ami_id &
            sleep 0.3
        done
        wait
        for i in `seq $from $to`
        do
            user=$prefix-$i
            stack=probcomp-stack-$user
            echo "Waiting for $stack to come up"
            ./aws/stackwait.sh $stack || true
            sleep 0.3
        done
        for i in `seq $from $to`
        do
            user=$prefix-$i
            stack=probcomp-stack-$user
            echo "Finalizing $stack"
            ./stack-finish.sh $user || true
            sleep 0.3
        done
        ;;
    delete)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            echo "Deleting probcomp-stack-$user"
            aws cloudformation delete-stack --stack-name probcomp-stack-$user
            sleep 0.3
        done
        for i in `seq $from $to`
        do
            user=$prefix-$i
            stack=probcomp-stack-$user
            echo "Waiting for $stack to come down"
            ./aws/stackwait.sh $stack || true
            sleep 0.3
        done
        ;;
    deb-upgrade)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            echo "Upgrading Ubuntu packages on probcomp-stack-$user"
            (./login.sh $user 'sudo apt-get update -q && sudo apt-get upgrade -y -q' 2>&1 \
                 | while read line; do echo $user: $line; done) &
        done
        wait
        ;;
    fetch-logs)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            echo "Fetching logs from probcomp-stack-$user"
            mkdir -p "logs/${user}"
            (./get.sh $user '/home/ubuntu/.iventure_logs/' "logs/${user}" -r -t 2>&1 \
                 | while read line; do echo $user: $line; done) &
        done
        wait
        ;;
    grab-content)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            echo "Collecting content on probcomp-stack-$user"
            (./login.sh $user 'wget --progress=dot:giga -O - https://probcomp-oreilly20170627.s3.amazonaws.com/content-package.tgz | gunzip -c | tar xf -' 2>&1 \
                 | while read line; do echo $user: $line; done) &
        done
        wait
        ;;
    marco-install)
        for i in `seq $from $to`
        do
            user=$prefix-$i
            echo "Installing Marco's stuff on probcomp-stack-$user"
            (./login.sh $user 'cd ~/gen && ./install.sh' 2>&1 \
                 | while read line; do echo $user: $line; done) &
        done
        wait
        ;;
    set-passwords)
        python write-jupyter-passwords.py $prefix $from $(($to + 1)) # Fence-post
        for i in `seq $from $to`
        do
            user=$prefix-$i
            echo "Setting the password on probcomp-stack-$user"
            (./set-jupyter-password.sh $user 2>&1 \
                 | while read line; do echo $user: $line; done) &
        done
        wait
        ;;
    *)
        printf >&2 'Unknown action %s\n' "$action"
        exit 1
        ;;
esac
