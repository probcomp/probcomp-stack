#!/bin/sh

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
