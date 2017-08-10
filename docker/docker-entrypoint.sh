#!/bin/bash
set -e

# activate python2 environment
source activate python2

#cp -r /branding ~/.jupyter/custom
if [ ! -f ~/work/satellites-predictive.ipynb ]; then
  mkdir -p ~/tmp
  cd ~/tmp && wget --progress=dot:giga -O - https://${CONTENT_URL} | gunzip -c | tar xf -
  mv ~/tmp/notebook/* ~/work/
  rm -r ~/tmp
fi

# create symlinks for apt packages to work with conda
cd /opt/conda/envs/python2/lib/python2.7/site-packages
for p in bayeslite cpgm crosscat iventure jupyter_probcomp venture; do
  ln -s /usr/lib/python2.7/dist-packages/$p
done

cd ~
exec "start-notebook.sh"
