#!/bin/sh

# Reset the working directory to the script's path
my_abs_path=$(readlink -f "$0")
root_dirname=$(dirname "$my_abs_path")
cd "$root_dirname"

set -Ceu

user=$1
password=$2

rm -f jupyter_notebook_config.json
ipython write-jupyter-password.py "$password" > jupyter_notebook_config.json
./put.sh "$user" jupyter_notebook_config.json /home/ubuntu/.jupyter/jupyter_notebook_config.json
./login.sh "$user" ./restart-jupyter.sh
