import json
import sys

try:
    from notebook.auth import passwd
except ImportError:
    from IPython.lib import passwd

if len(sys.argv) > 1:
    with open(sys.argv[1], "r") as f:
        word = passwd(f.readline().strip())
else:
    word = passwd()

js = { "NotebookApp": { "password" : word } }
json.dump(js, sys.stdout)
