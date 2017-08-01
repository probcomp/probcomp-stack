#!/bin/sh

aws ec2 describe-instances --filters "Name=instance-state-code,Values=16" \
| jq --from-file running-cost-table.jq -r
