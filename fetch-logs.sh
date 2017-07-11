#!/bin/sh

# Get the session logs off a running instance and dump them in logs/USER.

set -Ceu

user=$1

mkdir -p "logs/${user}"
./get.sh $user '/home/ubuntu/.iventure_logs/' "logs/${user}" -r -t -v
