#!/bin/sh

set -Ceu

# Reset the working directory to the script's path
my_abs_path=$(readlink -f "$0")
root_dirname=$(dirname "$my_abs_path")
echo "$root_dirname"
cd "$root_dirname"

release=${1:-0.1}

# Build the bare release container as a base
docker build -t probcomp/base -f docker/ubuntu1604-jupyter docker

# Collect the content to release into a directory
rm -rf release-playpen
mkdir -p release-playpen
release-archive.sh "$release"
cp "probcomp-stack-$release.zip" release-playpen
(cd release-playpen && unzip "probcomp-stack-$release.zip")
cp docker/ubuntu1604-jupyter-full release-playpen

# Build the full release container
docker build -t "probcomp/stack-release:$release" \
       -f release-playpen/ubuntu1604-jupyter-full \
       release-playpen/

# Export it
tarball="probcomp-stack-full-$release.tar"
docker save --output="$tarball" "probcomp/stack-release:$release"

# Zip it for transport
zipball="probcomp-stack-full-$release.zip"
zip "$zipball" "$tarball"
sha256sum "$zipball"
