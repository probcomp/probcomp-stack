#!/bin/sh

# Wait for a Cloudformation stack with the given name to come up.

# Wait up to 25 minutes.

set -Ceu

progname="`dirname "$0"`"
stackname=$1
aws=${AWS:-aws}

i=0

while [ $i -lt 100 ]; do
    action=done
    reason=
    for status in `$aws cloudformation describe-stacks --stack-name "$stackname" \
                   | jq -r '.Stacks[].StackStatus'`
    do
        case $status in
        CREATE_IN_PROGRESS|DELETE_IN_PROGRESS|REVIEW_IN_PROGRESS|UPDATE_IN_PROGRESS|ROLLBACK_IN_PROGRESS|UPDATE_ROLLBACK_IN_PROGRESS)
            action=wait
            reason=$status
            ;;
        UPDATE_COMPLETE_CLEANUP_IN_PROGRESS|UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS)
            action=wait
            reason=$status
            ;;
        CREATE_COMPLETE|DELETE_COMPLETE|UPDATE_COMPLETE)
            ;;
        *)
            action=error
            printf >&2 '%s: failed: %s\n' "$progname" "$status"
            ;;
        esac
    done
    case $action in
    wait)       echo '#' stack $stackname in state $reason, waiting 15 sec; sleep 15;;
    done)       break;;
    error)      exit 1;;
    esac
done
