#!/bin/sh

# Wait for an AMI to finish being created.  The AMI is specified by
# passing a command with the same output behavior as aws ec2
# describe-images --image-ids <whatever> to this as arguments.  This
# will repeatedly invoke that command, waiting for its output to
# indicate success.

# Wait up to 25 minutes.

set -Ceu

progname="`dirname "$0"`"

i=0

while [ $i -lt 100 ]; do
    action=done
    reason=
    for state in `"$@" | jq -r '.Images[].State'`
    do
        case $state in
        pending)
            action=wait
            reason=$state
            ;;
        available)
            ;;
        *)
            action=error
            printf >&2 '%s: failed: %s\n' "$progname" "$state"
            ;;
        esac
    done
    case $action in
    wait)       echo '#' ami state $reason waiting 15 seconds; sleep 15;;
    done)       break;;
    error)      exit 1;;
    esac
done
