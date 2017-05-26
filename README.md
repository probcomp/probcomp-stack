probcomp-stack: MIT Probabilistic Computing Project software stack

We currently support two deployment mechanisms
- An isolated EC2 instance on the group's AWS account
- A local Docker container

EC2 model
---------

- Each user gets exactly one EC2 machine
- Each user's machine is completely isolated from all the other
  users' machines
- We pay for the machines
- We have a *nix client workflow for administering the fleet
- We can insist on each user having a fleet-wide unique username
- We can let a given person have several usernames and thus use
  several independent machines, but we do not support cluster
  computing (in this iteration of the management software)

Deploying on and managing isolated EC2 instances
------------------------------------------------

### Prerequisites

- Installed AWS command-line interface `aws`, and `jq`.

- AWS credentials authorized to manipulate EC2 resources and use
  CloudFormation.  For instance, the `AmazonEC2FullAccess`,
  `AmazonRoute53FullAccess`, and `ProbcompCloudFormationFullAccess`
  policies suffice.

- SSH keypair the instances will trust, uploaded to AWS
  (e.g., `bch20170503-ec2.pem`, or you can make your own).

- A DNS domain.  Ours is `probcomp.net` (entered into the command line
  tool with the trailing `.`).

- SSL certificate under the AWS certificate manager.  Ours covers
  `*.stack.probcomp.net`.

### Update the Ubuntu packages of our software

See the `packaging` repository.

### Create a stack for a new user

Choose:
- User name (e.g., their name)
- Initial instance type (e.g., t2.micro [default] for testing, or
  c3.8xlarge for compute)
- Initial password

Run

```
aws cloudformation create-stack \
    --stack-name probcomp-stack-<user> \
    --template-body file://path/to/aws/stack.yaml \
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

If Issue #4 is not fixed, manually set the Jupyter notebook password

Install the initial content from the `workshop-materials` repository
using `scp` or `rsync`.

### Change the instance type for a user

- Run `aws cloudformation update-stack` with the same arguments as above, except with the new instance type.

May also need to manually restart the jupyter server, if Issue #3 is
not fixed yet.

### Terminate a user's instance

Run `aws cloudformation delete-stack --stack-name probcomp-stack-<user>`

### SSH into the instance

- Get the instance's ssh host key by running

   ./aws/hostkey.sh probcomp-stack-<user> <user>.stack.probcomp.net > known_hosts

  (this will silently leave a blank known_hosts file if the instance
  hasn't finished booting yet.)

- ssh -i <private-key> -o userknownhostsfile=./known_hosts ubuntu@ssh.<user>.stack.probcomp.net

### Change a user's Jupyter notebook password

- SSH into the instance and run `jupyter notebook password` interactively,
  and/or see solution to Issue #4

Deploying locally in Docker
---------------------------

The stack can be bundled as a docker image, derived from components developed
in separate Git repositories and distributed via Ubuntu .deb packages
in <https://github.com/probcomp/packaging>.

Pick a directory where you want notebooks to go, say
/path/to/notebooks -- perhaps under your home directory on your
laptop, or perhaps the mount point of an Elastic Block Store on your
Amazon EC2 instance.

Pick the name for an image, say probcomp/stack:20170503-3 for the
third attempt on May 3rd 2017.

Run:

```
% docker build -t probcomp/stack:20170503-0 -f docker/ubuntu1604 .
% mkdir /path/to/notebooks
% docker run --rm --publish 127.0.0.1:8080:8080/tcp \
    -v /path/to/notebooks:/notebook \
    probcomp/stack:20170503-0
```

Then point a web browser at

http://127.0.0.1:8080/

(Beware: All other processes in the system with access to the TCP/IP
stack, including those running with credentials other than yours, can
reach your jupyter notebook.)

Dockerfiles available:

- `docker/ubuntu1604`
        Ubuntu 16.04 with system packages and probcomp stack

- `docker/ubuntu1604-jupyter`
        Ubuntu 16.04 with system packages, probcomp stack, and pypi jupyter

The version of jupyter on pypi is newer than the version of ipython
notebook in Ubuntu 16.04, but the level of QA and reliability on any
particular base system such as Ubuntu 16.04 is unpredictable.
