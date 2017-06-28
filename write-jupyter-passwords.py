import json
import sys

try:
    from notebook.auth import passwd
except ImportError:
    from IPython.lib import passwd

def write_password_json(user):
    with open("jupyter-passwords/%s.passwd" % (user,), "r") as f:
        word = passwd(f.readline().strip())
        js = { "NotebookApp": { "password" : word } }
        with open("jupyter_notebook_configs/%s.json" % (user,), "w") as f2:
            json.dump(js, f2)

if __name__ == '__main__':
    if len(sys.argv) == 2:
        # Assume one user
        write_password_json(sys.argv[1])
    elif len(sys.argv) == 4:
        # Assume range
        prefix = sys.argv[1]
        low = int(sys.argv[2])
        high = int(sys.argv[3])
        for i in range(low, high):
            write_password_json("%s-%d" % (prefix, i))
    else:
        print "Usage: write-jupyter-passwords.py user [low high]"
        sys.exit(1)
