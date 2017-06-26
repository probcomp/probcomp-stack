import json
import sys

try:
    from notebook.auth import passwd
except ImportError:
    from IPython.lib import passwd

if len(sys.argv) > 1:
    word = passwd(sys.argv[1])
else:
    word = passwd()

js = { "NotebookApp": { "password" : word } }
json.dump(js, sys.stdout)
