#!/bin/sh

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
