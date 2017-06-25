#!/bin/sh

# Wait for an EC2 instance to display console output The instance is
# specified by passing a command with the same output behavior as aws
# ec2 get-console-output --instance-id <whatever> to this as
# arguments.  This will repeatedly invoke that command, waiting for
# its output to appear.

# Wait up to 25 minutes.

set -Ceu

progname="`dirname "$0"`"

i=0

while [ $i -lt 100 ]; do
    case `"$@" | jq -r .Output` in
    null)
	echo '# no console output yet, waiting 15sec'
	sleep 15
	;;
    *)
	break;;
    esac
done
