#!/bin/sh

set -Ceu
release=${1:-0.2}

# login to gcr
GOOGLE_APPLICATION_CREDENTIALS=~/.gcp/probcomp.json
docker login -u oauth2accesstoken -p "$(gcloud auth application-default print-access-token)" https://us.gcr.io

# Build the bare release container as a base
docker build --no-cache -t us.gcr.io/hazel-aria-174703/probcomp:${release} \
  -f docker/ubuntu1604-jupyter-gcp docker
docker push us.gcr.io/hazel-aria-174703/probcomp:${release}
