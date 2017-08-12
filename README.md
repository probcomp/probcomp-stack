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

Save the password in the file `jupyter-passwords/<user>.passwd`

Make sure the desired content (from `workshop-materials`, presumably)
is uploaded as a compressed tar archive at
`https://probcomp-oreilly20170627.s3.amazonaws.com/content-package.tgz`

Run
```
./stack.sh create <user> <instance>
```

If something goes wrong, the CloudFormation section of the AWS console
is helpful.

Right now this script bakes in some assumptions specific to my
(axch's) machine, such as the choice and location of the key pair to
start the instance with.  It may be necessary to make some adjustments
to get it to work for you, or invoke the pieces separately.

Test it by browsing `https://<user>.stack.probcomp.net`

Check in the host key in the `known_hosts` directory, and a line about
who it's for in the `running-stacks.org` file.

### Create a fleet of many instances for some purpose

Choose
- Base name for the fleet stacks
- Range of indexes to set up
- Instance type (e.g., c3.8xlarge)

Create passwords for all the instances, in files named `jupyter-passwords/<base>-<i>.passwd`

Make sure the desired content (from `workshop-materials`, presumably)
is uploaded as a compressed tar archive at
`https://probcomp-oreilly20170627.s3.amazonaws.com/content-package.tgz`
- Perhaps this may call for
  (cd ../workshop-materials && aws s3 cp content-package.tgz s3://probcomp-oreilly20170627/content-package.tgz)

Run
```
./fleet.sh create <base-name> <low> <high> [<instance> [<ami-id>]]
```

Then run whichever of
```
./fleet.sh deb-upgrade <base-name> <low> <high>
./fleet.sh grab-content <base-name> <low> <high>
./fleet.sh marco-install <base-name> <low> <high>
./fleet.sh set-passwords <base-name> <low> <high>
```
are desired

Check a few by browsing `https://<base>-<i>.stack.probcomp.net`

### Print physical cards with urls and passwords to hand out

Make sure the passwords are all present in files named `jupyter-passwords/<user>.passwd`.

Loop editing and rerunning the script `url-cards.sh` until the output is as desired.

### Change the instance type for a user

- Run `./stack.sh update <user> <new-instance>`

### Terminate a user's instance

Run `aws cloudformation delete-stack --stack-name probcomp-stack-<user>`

### Stop or resatrt a user's instance

Log in to the EC2 console, find the instance tagged `<user>/instance`,
and stop or restart it.  Note that this requires an extra step to
re-enable the ssh address below, per
https://github.com/probcomp/probcomp-stack/issues/38

### SSH into the instance

- The instance's ssh host key should be saved in `known_hosts/<user>`

- `login.sh <user>`
  which runs
  `ssh -i <private-key> -o UserKnownHostsFile=./known_hosts/<user> -o CheckHostIP=no -o StrictHostKeyChecking=yes ubuntu@ssh.<user>.stack.probcomp.net`
  with the default key (namely, bch20170503-ec2.pem)

### Transfer files to and from the instance

- `put.sh <user> <local-source> <remote-dest>`
- `get.sh <user> <remote-source> <local-dest>`

### Change a user's Jupyter notebook password

- SSH into the instance
- activate the virtual environment `venv`
- `jupyter notebook password`

Or

- write the new password to `jupyter-passwords/<user>.passwd`
- `python write-jupyter-passwords.py <user>`
- `./set-jupyter-password.sh <user>`

### Restart a user's Jupyter notebook server, if needed

`./restart-jupyter.sh`

### Visit the Jupyter notebook server

https://<user>.stack.probcomp.net/

### Collect usage logs

`./fleet.sh fetch-logs <base-name> <low> <high>`

### Share usage logs with the lab

`rsync -r -v logs/ probcomp-1.csail.mit.edu:/data/probcomp/ppaml/probcomp-stack-logs`

### Assess and explain current $ burn rate

`./aws-spend.sh`

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
% docker build -t probcomp/stack:20170503-0 -f docker/ubuntu1604-jupyter .
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

Updating Probcomp software
--------------------------

The current process for getting an instance with a fresh package set:
- Build, sign, and upload our packages to our apt repo
  http://probcomp.csail.mit.edu/ubuntu-prerelease
  - instructions in https://github.com/probcomp/packaging/tree/master/ubuntu
  - probcomp-ubuntu-keyring
  - python-bayeslite
  - python-cgpm
  - python-crosscat
  - python-iventure
  - python-pytest
  - python-venture
  - Taylor and Axch have code signing keys
- make the instance apt-get update and apt-get upgrade
