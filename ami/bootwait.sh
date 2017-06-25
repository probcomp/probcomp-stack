#!/bin/sh

# Wait for an EC2 instance to boot.  The instance is specified by
# passing a command with the same output behavior as aws ec2
# describe-instance-status --instance-ids <whatever> to this as
# arguments.  This will repeatedly invoke that command, waiting for
# its output to indicate success.

# Wait up to 25 minutes.

set -Ceu

progname="`dirname "$0"`"

i=0

while [ $i -lt 100 ]; do
    action=done
    reason=
    for status in `"$@" | jq -r '.InstanceStatuses[].InstanceStatus.Status'`
    do
        case $status in
        null|initializing)
            action=wait
            reason=$status
            ;;
        ok)
            ;;
        *)
            action=error
            printf >&2 '%s: failed: %s\n' "$progname" "$status"
            ;;
        esac
    done
    case $action in
    wait)       echo '#' status $reason; sleep 15;;
    done)       break;;
    error)      exit 1;;
    esac
done
