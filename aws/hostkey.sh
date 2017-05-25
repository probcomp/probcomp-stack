#!/bin/sh

set -Ceu

: ${AWS:=aws}
: ${JQ:=jq}

progname="`basename "$0"`"

if [ $# -ne 2 ]; then
    printf >&2 'Usage: %s <stack> <hostname>\n' "$progname"
    exit 1
fi

stack="$1"
hostname="$2"

get_id ()
{

    terms='.StackResourceSummaries[]'
    condition='.LogicalResourceId == "Instance"'
    result='.PhysicalResourceId'
    ${AWS} cloudformation list-stack-resources --stack-name "$stack" \
	| ${JQ} -r "${terms} | select(${condition}) ${result}"
}

get_console_output ()
{
    local id

    id="$1"
    ${AWS} ec2 get-console-output --instance-id="$id" \
	| ${JQ} -r .Output \
	| tr -d '\r'
}

extract_known_hosts ()
{

    start='/^-----BEGIN SSH HOST KEY KEYS-----$/'
    end='/^-----END SSH HOST KEY KEYS-----$/'
    action='{ print hostname, $1, $2 }'
    awk -v hostname="$hostname" "${start},${end} ${action}" \
	| tail -n +2 | head -n -1
}

id="`get_id`"
get_console_output "$id" | extract_known_hosts
