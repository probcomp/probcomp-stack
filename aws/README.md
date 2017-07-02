Use this automation with

```
aws cloudformation create-stack \
    --stack-name probcomp-stack-<user> \
    --template-body file://aws/stack.yaml \
    --parameters ParameterKey=Name,ParameterValue=<user> \
      ParameterKey=InstanceType,ParameterValue=<instance> \
      ParameterKey=KeyName,ParameterValue=<key> \
      ParameterKey=CertificateArn,ParameterValue=arn:aws:acm:us-east-1:590421120965:certificate/f3ac3e7b-b8fd-4bb8-9bb7-c2f9299c9233 \
      ParameterKey=Hostname,ParameterValue=<user>.stack \
      ParameterKey=Zone,ParameterValue=probcomp.net.
```

The command returns quickly, but the actual creation takes about 5 minutes.

If something goes wrong (which will be silent), the CloudFormation
section of the AWS console is helpful.

Can change instance types by running `aws cloudformation update-stack`
with the same arguments as above.
