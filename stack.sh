#!/bin/sh

set -Ceu

# Reset the working directory to the script's path
my_abs_path=$(readlink -f "$0")
root_dirname=$(dirname "$my_abs_path")
cd "$root_dirname"

action=$1
user=$2
instance=$3
ami_id=${4:-ami-751b2c63}

if [ ! -f "jupyter-passwords/${user}.passwd" ]; then
    printf >&2 "missing jupyter-passwords/${user}.passwd\n"
    exit 1
fi

./stack-start.sh $action $user $instance $ami_id

./aws/stackwait.sh probcomp-stack-$user

./stack-finish.sh $user

# This chunk is copied from fleet.sh

# Upgrade to the latest versions of our packages
./login.sh $user 'sudo apt-get update -q && sudo apt-get upgrade -y -q'

# Collect the introductory content
./login.sh $user 'wget --progress=dot:giga -O - https://probcomp-oreilly20170627.s3.amazonaws.com/content-package.tgz | gunzip -c | tar xf -'

# Install Gen
./login.sh $user 'cd ~/gen && ./install.sh'

# Compute the password json file
python ./write-jupyter-passwords.py $user

# Set the password
./set-jupyter-password.sh $user
