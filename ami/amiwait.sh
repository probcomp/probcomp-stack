#!/bin/sh

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
    wait)       echo '#' state $reason; sleep 15;;
    done)       break;;
    error)      exit 1;;
    esac
done
