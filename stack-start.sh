#!/bin/sh

set -Ceu

action=$1
user=$2
instance=$3
ami_id=${4:-ami-0f6b2119}

aws cloudformation $action-stack \
    --stack-name probcomp-stack-$user \
    --template-body file://aws/stack.yaml \
    --parameters ParameterKey=Name,ParameterValue=$user \
      ParameterKey=InstanceType,ParameterValue=$instance \
      ParameterKey=KeyName,ParameterValue=bch20170503-ec2 \
      ParameterKey=CertificateArn,ParameterValue=arn:aws:acm:us-east-1:590421120965:certificate/f3ac3e7b-b8fd-4bb8-9bb7-c2f9299c9233 \
      ParameterKey=Hostname,ParameterValue=$user.stack \
      ParameterKey=Zone,ParameterValue=probcomp.net. \
      ParameterKey=BaseAMI,ParameterValue=$ami_id
