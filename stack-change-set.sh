#!/bin/bash

# Create a Cloudformation Change Set to examine what it would take to
# bring a stack into conformance with the desired instance type and
# any changes in how it is supposed to be set up.

# Empirically, haven't found this to be all that useful, because
# Cloudformation can't seem to figure out when it would be safe not to
# recreate an instance, and recreating instances is annoying.

action=$1
user=$2
instance=$3
ami_id=${4:-ami-0f6b2119}

aws cloudformation $action-change-set \
    --stack-name probcomp-stack-$user \
    --change-set-name probcomp-stack-$user-update \
    --template-body file://aws/stack.yaml \
    --parameters ParameterKey=Name,ParameterValue=$user \
      ParameterKey=InstanceType,ParameterValue=$instance \
      ParameterKey=KeyName,ParameterValue=bch20170503-ec2 \
      ParameterKey=CertificateArn,ParameterValue=arn:aws:acm:us-east-1:590421120965:certificate/f3ac3e7b-b8fd-4bb8-9bb7-c2f9299c9233 \
      ParameterKey=Hostname,ParameterValue=$user.stack \
      ParameterKey=Zone,ParameterValue=probcomp.net. \
      ParameterKey=BaseAMI,ParameterValue=$ami_id

case $action in
    create)
        aws cloudformation describe-change-set --stack-name probcomp-stack-$user --change-set-name probcomp-stack-$user-update
        ;;
    *)
        ;;
esac
