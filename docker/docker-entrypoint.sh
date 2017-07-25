#!/bin/sh
set -e

#. /venv/bin/activate
#cp -r /branding ~/.jupyter/custom
if [ ! -f /notebook/satellites-predictive.ipynb ]; then
  cd /tmp && wget --progress=dot:giga -O - https://${CONTENT_URL} | gunzip -c | tar xf -
  mv notebook/* /notebook/
fi

cd /notebook
exec /usr/local/bin/jupyter notebook --ip='*' --port=8080 --no-browser --NotebookApp.token= \
  --allow-root --NotebookApp.iopub_data_rate_limit=10000000000
