#!/bin/sh

# Reset the working directory to the script's path
my_abs_path=$(readlink -f "$0")
root_dirname=$(dirname "$my_abs_path")
cd "$root_dirname"

set -Ceu

user=$1

./put.sh "$user" jupyter_notebook_configs/$user.json /home/ubuntu/.jupyter/jupyter_notebook_config.json
./login.sh "$user" ./restart-jupyter.sh
