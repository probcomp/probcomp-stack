default-target: allclean .PHONY
.PHONY:

SHELL := $(SHELL) -eu

PROJECT = stack-20170505
SUBPROJECT = ami

AWS = aws
SSH = ssh

PROFILE = $(PROJECT)

AWSCLI = $(AWS) --profile $(PROFILE)
TAG_PROJECT = \
	$(AWSCLI) ec2 create-tags \
		--tags Key=probcomp/project,Value=$(PROJECT) \
		--resources
TAG_NAME = \
	$(AWSCLI) ec2 create-tags \
		--tags Key=Name,Value=probcomp/$(@:.json=)/$(PROJECT) \
		--resources
FILTER_PROJECT = \
	--filters Name=tag-key,Values=probcomp/project \
	--filters Name=tag-value,Values=$(PROJECT)

all: ami

allclean: .PHONY
allclean: all
	$(MAKE) clean

clean: .PHONY

clean: clean-tmp
clean-tmp: .PHONY
	-rm -f *.tmp

distclean: .PHONY
	$(MAKE) clean

show: .PHONY
	@echo $($(VAR))

DESCRIBE_RESOURCES = $(AWSCLI) ec2 describe-tags $(FILTER_PROJECT)
describe-resources: .PHONY
	@$(DESCRIBE_RESOURCES)

###############################################################################
# VPC: Virtual Private Cloud
#
# A VPC is just a private IPv4 address space that can be partitioned
# into subnets and have two flags about DNS settings, described here:
#
# https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-dns.html
#
# General VPC documentation: https://aws.amazon.com/documentation/vpc/

# Parameters:
#
# VPC_CIDR_BLOCK
#       Private IPv4 address range for the whole VPC.
VPC_CIDR_BLOCK = 10.0.0.0/16

vpc.json:
	-rm -f $@.tmp
	$(AWSCLI) ec2 create-vpc \
		--cidr-block $(VPC_CIDR_BLOCK) \
		> $@.tmp
	vpc_id=`jq -r .Vpc.VpcId < $@.tmp` && \
	$(TAG_PROJECT) "$$vpc_id" && \
	$(TAG_NAME) "$$vpc_id" && \
	$(AWSCLI) ec2 modify-vpc-attribute \
		--enable-dns-hostnames \
		--vpc-id "$$vpc_id" \
		&& \
	$(AWSCLI) ec2 modify-vpc-attribute \
		--enable-dns-support \
		--vpc-id "$$vpc_id" \
		&& \
	mv -f $@.tmp $@

DESCRIBE_VPCS = $(AWSCLI) ec2 describe-vpcs $(FILTER_PROJECT)
describe-vpcs: .PHONY
	@$(DESCRIBE_VPCS)

LIST_VPCS = $(DESCRIBE_VPCS) | jq -r '.Vpcs[].VpcId'
list-vpcs: .PHONY
	@$(LIST_VPCS)

clean: _clean-vpcs
_clean-vpcs: .PHONY
_clean-vpcs: _clean-gateways
_clean-vpcs: _clean-secgroups
_clean-vpcs: _clean-subnets
	$(MAKE) clean-vpcs
clean-vpcs: .PHONY
	@echo '#' WARNING: May fail if there are still subnets in use.
	$(LIST_VPCS) \
		| while read id; do \
			$(AWSCLI) ec2 delete-vpc --vpc-id "$$id"; \
		done
	-rm -f vpc.json

###############################################################################
# Security Groups
#
# A security group is a named set of ingress and egress rules in a
# VPC.  We authorize ports 22 (ssh), 80 (http), and 443 (https).

# Parameters:
#
# SECGROUP_NAME
#       Name of the security group.
#
# SECGROUP_DESC
#       Description of the security group.
SECGROUP_NAME = probcomp/secgroups-testing/$(PROJECT)
SECGROUP_DESC = $(SECGROUP_NAME)

secgroup.json: vpc.json
	-rm -f $@.tmp
	vpc_id=`jq -r .Vpc.VpcId < vpc.json` && \
	$(AWSCLI) ec2 create-security-group \
		--description '$(SECGROUP_DESC)' \
		--group-name '$(SECGROUP_NAME)' \
		--vpc-id "$$vpc_id" \
		> $@.tmp
	group_id=`jq -r .GroupId < $@.tmp` && \
	$(TAG_PROJECT) "$$group_id" && \
	$(TAG_NAME) "$$group_id" && \
	$(AWSCLI) ec2 authorize-security-group-ingress \
		--cidr 0.0.0.0/0 \
		--group-id "$$group_id" \
		--port 22 \
		--protocol tcp \
		&& \
	$(AWSCLI) ec2 authorize-security-group-ingress \
		--cidr 0.0.0.0/0 \
		--group-id "$$group_id" \
		--port 80 \
		--protocol tcp \
		&& \
	$(AWSCLI) ec2 authorize-security-group-ingress \
		--cidr 0.0.0.0/0 \
		--group-id "$$group_id" \
		--port 443 \
		--protocol tcp \
		# end of authorize-security-group-ingress options
	mv -f $@.tmp $@

DESCRIBE_SECGROUPS = $(AWSCLI) ec2 describe-security-groups $(FILTER_PROJECT)
describe-secgroups: .PHONY
	@$(DESCRIBE_SECGROUPS)

LIST_SECGROUPS = $(DESCRIBE_SECGROUPS) | jq -r '.SecurityGroups[].GroupId'
list-secgroups: .PHONY
	@$(LIST_SECGROUPS)

clean: _clean-secgroups
_clean-secgroups: .PHONY
_clean-secgroups: _clean-instances
	$(MAKE) clean-secgroups
clean-secgroups: .PHONY
	@echo '#' WARNING: May fail if there are still instances in use.
	$(LIST_SECGROUPS) \
		| while read id; do \
			$(AWSCLI) ec2 delete-security-group \
				--group-id "$$id"; \
		done
	-rm -f secgroup.json

###############################################################################
# Route table
#
# Automatically created for the VPC, we just need to get its id.

routetab.json: vpc.json
	-rm -f $@.tmp
	vpc_id=`jq -r .Vpc.VpcId < vpc.json` && \
	$(AWSCLI) ec2 describe-route-tables \
		--filters Name=vpc-id,Values="$$vpc_id" \
		| jq '{"RouteTable": .RouteTables[0]}' > $@.tmp
	mv -f $@.tmp $@

DESCRIBE_ROUTETABS = \
	vpc_ids=`$(LIST_VPCS)` && \
	vpc_ids_comma=`echo "$$vpc_ids" | tr \\n , | head -c -1` && \
	$(AWSCLI) ec2 describe-route-tables \
		--filters Name=vpc-id,Values="$$vpc_ids_comma"
describe-routetabs: .PHONY
	@$(DESCRIBE_ROUTETABS)

LIST_ROUTETABS = $(DESCRIBE_ROUTETABS) | jq -r '.RouteTables[].RouteTableId'
list-routetabs: .PHONY
	@$(LIST_ROUTETABS)

clean: clean-routetabs
clean-routetabs: .PHONY
	-rm -f routetab.json

###############################################################################
# Subnet
#
# A subnet is a section of address space in a VPC from which an EC2
# instance's IP address may be drawn.

# Parameters:
#
# SUBNET_CIDR_BLOCK
#       Private IPv4 address range for the subnet within
#       VPC_CIDR_BLOCK.
SUBNET_CIDR_BLOCK = 10.0.0.0/24

subnet.json: vpc.json
	-rm -f $@.tmp
	vpc_id=`jq -r .Vpc.VpcId < vpc.json` && \
	$(AWSCLI) ec2 create-subnet \
		--cidr-block $(SUBNET_CIDR_BLOCK) \
		--vpc-id "$$vpc_id" \
		> $@.tmp
	subnet_id=`jq -r .Subnet.SubnetId < $@.tmp` && \
	$(TAG_PROJECT) "$$subnet_id" && \
	$(TAG_NAME) "$$subnet_id"
	mv -f $@.tmp $@

DESCRIBE_SUBNETS = $(AWSCLI) ec2 describe-subnets $(FILTER_PROJECT)
describe-subnets: .PHONY
	@$(DESCRIBE_SUBNETS)

LIST_SUBNETS = $(DESCRIBE_SUBNETS) | jq -r '.Subnets[].SubnetId'
list-subnets: .PHONY
	@$(LIST_SUBNETS)

clean: _clean-subnets
_clean-subnets: .PHONY
_clean-subnets: _clean-instances
#_clean-subnets: _clean-rtassocs
	$(MAKE) clean-subnets
clean-subnets: .PHONY
	@echo '#' WARNING: May fail if there are still instances in use.
	$(LIST_SUBNETS) \
		| while read id; do \
			$(AWSCLI) ec2 delete-subnet --subnet-id "$$id"; \
		done
	-rm -f subnet.json

###############################################################################
# Route table association
#
# A route table association is necessary for a subnet to reach other
# networks.  There is no actual information here.  Why it is necessary
# is currently beyond my sleep-addled me.

rtassoc.json: routetab.json
rtassoc.json: subnet.json
rtassoc.json: vpc.json
	-rm -f $@.tmp
	routetab_id=`jq -r .RouteTable.RouteTableId < routetab.json` && \
	subnet_id=`jq -r .Subnet.SubnetId < subnet.json` && \
	$(AWSCLI) ec2 associate-route-table \
		--route-table-id "$$routetab_id" \
		--subnet-id "$$subnet_id" \
		> $@.tmp
	mv -f $@.tmp $@

DESCRIBE_RTASSOCS = \
	$(DESCRIBE_ROUTETABS) | jq '[.RouteTables[].Associations[]]'
describe-rtassocs: .PHONY
	@$(DESCRIBE_RTASSOCS)

LIST_RTASSOCS = $(DESCRIBE_RTASSOCS) | jq -r '.[].RouteTableAssociationId'
list-rtassocs: .PHONY
	@$(LIST_RTASSOCS)

#clean: _clean-rtassocs
_clean-rtassocs: .PHONY
	$(MAKE) clean-rtassocs
clean-rtassocs: .PHONY
	$(LIST_RTASSOCS) \
		| while read id; do \
			$(AWSCLI) ec2 disassociate-route-table \
				--association-id "$$id"; \
		done
	-rm -f rtassoc.json

###############################################################################
# Gateway
#
# A gateway is a nexus to the outside world.  The outside world is a
# scary place.  Presumably this is why you must explicitly opt in to
# having a nexus to it.  Otherwise there is no semantic content to
# this either.

gateway.json: routetab.json
gateway.json: vpc.json
	-rm -f $@.tmp
	$(AWSCLI) ec2 create-internet-gateway > $@.tmp
	gateway_id=`jq -r .InternetGateway.InternetGatewayId < $@.tmp` && \
	$(TAG_PROJECT) "$$gateway_id" && \
	$(TAG_NAME) "$$gateway_id" && \
	vpc_id=`jq -r .Vpc.VpcId < vpc.json` && \
	$(AWSCLI) ec2 attach-internet-gateway \
		--internet-gateway-id "$$gateway_id" \
		--vpc-id "$$vpc_id" \
		&& \
	routetab_id=`jq -r .RouteTable.RouteTableId < routetab.json` && \
	$(AWSCLI) ec2 create-route \
		--destination-cidr-block 0.0.0.0/0 \
		--gateway-id "$$gateway_id" \
		--route-table-id "$$routetab_id" \
		# end of create-route options
	mv -f $@.tmp $@

DESCRIBE_GATEWAYS = \
	$(AWSCLI) ec2 describe-internet-gateways $(FILTER_PROJECT)
describe-gateways: .PHONY
	@$(DESCRIBE_GATEWAYS)

LIST_GATEWAYS = \
	$(DESCRIBE_GATEWAYS) | jq -r '.InternetGateways[].InternetGatewayId'
list-gateways: .PHONY
	@$(LIST_GATEWAYS)

clean: _clean-gateways
_clean-gateways: .PHONY
_clean-gateways: _clean-instances
	$(MAKE) clean-gateways
clean-gateways: .PHONY
	$(LIST_GATEWAYS) \
		| while read id; do \
			$(LIST_VPCS) \
			| while read vpc_id; do \
				$(AWSCLI) ec2 detach-internet-gateway \
					--internet-gateway-id "$$id" \
					--vpc-id "$$vpc_id"; \
			done && \
			if routetab_id=`jq -r .RouteTable.RouteTableId < routetab.json`; then \
				$(AWSCLI) ec2 delete-route \
					--route-table-id "$$routetab_id" \
					--destination-cidr-block 0.0.0.0/0; \
			fi && \
			$(AWSCLI) ec2 delete-internet-gateway \
				--internet-gateway-id "$$id"; \
		done
	-rm -f gateway.json

###############################################################################
# Instances and reservation
#
# A reservation is a collection of related instances.  An instance is
# a magic computer that lives in the cloud and plays the harp.

# Parameters:
#
# AMI_ID
#       Id (`ami-...') of the AMI on which the AMI we are about to
#       create is based.
#
# INSTANCE_TYPE
#       EC2 instance type.
#
# KEY_NAME
#       Name of the ssh identity.
#
# KEY_FILE
#       Path to private key for the ssh identity.

# ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20170414
AMI_ID = ami-80861296
INSTANCE_TYPE = t2.micro
KEY_NAME = $(PROJECT)
KEY_FILE = $(KEY_NAME).pem

reservation.json: secgroup.json
reservation.json: subnet.json
	-rm -f $@.tmp
	secgroup_id=`jq -r .GroupId < secgroup.json` && \
	subnet_id=`jq -r .Subnet.SubnetId < subnet.json` && \
	$(AWSCLI) ec2 run-instances \
		--associate-public-ip-address \
		--count 1 \
		--image-id $(AMI_ID) \
		--instance-type t2.micro \
		--key-name $(KEY_NAME) \
		--security-group-ids "$$secgroup_id" \
		--subnet-id "$$subnet_id" \
		> $@.tmp && \
	instance_ids=`jq -r '.Instances[].InstanceId' < $@.tmp` && \
	$(TAG_PROJECT) $$instance_ids && \
	$(AWSCLI) ec2 create-tags \
		--tags Key=Name,Value=$(PROJECT) \
		--resources $$instance_ids
	mv -f $@.tmp $@

# No dependency on bootwait.sh even though we use it, since
# (a) it doesn't materially affect the output, and
# (b) it is not autogenerated.
instance.json: reservation.json
	-rm -f $@.tmp
	instance_ids=`jq -r '.Instances[].InstanceId' < reservation.json` && \
	sh bootwait.sh \
		$(AWSCLI) ec2 describe-instance-status \
			--instance-ids $$instance_ids \
			&& \
	$(AWSCLI) ec2 describe-instances \
		--instance-ids $$instance_ids \
		| jq '.Reservations[0].Instances[0]' > $@.tmp
	mv -f $@.tmp $@

DESCRIBE_INSTANCES = $(AWSCLI) ec2 describe-instances $(FILTER_PROJECT)
describe-instances: .PHONY
	@$(DESCRIBE_INSTANCES)

LIST_INSTANCES = \
	$(DESCRIBE_INSTANCES) | jq -r '.Reservations[].Instances[].InstanceId'
list-instances: .PHONY
	@$(LIST_INSTANCES)

clean: _clean-instances
_clean-instances: .PHONY
	$(MAKE) clean-instances
clean-instances: .PHONY
	$(LIST_INSTANCES) \
		| xargs -r $(AWSCLI) ec2 terminate-instances --instance-ids
	-rm -f instance.json
	-rm -f reservation.json

###############################################################################
# ssh known hosts
#
# Works only on first boot!
#
# XXX Also only works a couple minutes after the first boot.  Whisky
# tango foxtrot?

known_hosts: instance.json
	-rm -f $@.tmp
	instance_id=`jq -r .InstanceId < instance.json` && \
	ip_addr=`jq -r .PublicIpAddress < instance.json` && \
	sh conswait.sh \
		$(AWSCLI) ec2 get-console-output \
		--instance-id "$$instance_id" && \
	$(AWSCLI) ec2 get-console-output \
		--instance-id "$$instance_id" \
		| jq -r .Output \
		| tr -d '\r' \
		| awk -v hostname="$$ip_addr" \
			'/^-----BEGIN SSH HOST KEY KEYS-----$$/,/^-----END SSH HOST KEY KEYS-----$$/ { print hostname, $$1, $$2 }' \
		| tail -n +2 | head -n -1 \
		> $@.tmp
	mv -f $@.tmp $@

clean: clean-known_hosts
clean-known_hosts: .PHONY
	-rm -f known_hosts

###############################################################################
# Setup

setup.stamp: gateway.json
setup.stamp: instance.json
setup.stamp: known_hosts
#setup.stamp: rtassoc.json
setup.stamp: setup.sh
	-rm -f $@.tmp
	ip_addr=`jq -r '.PublicIpAddress' < instance.json` && \
	$(SSH) -i $(KEY_FILE) -o UserKnownHostsFile=known_hosts \
		ubuntu@"$$ip_addr" \
		'sh -x' < setup.sh
	touch $@.tmp
	mv -f $@.tmp $@

clean: clean-setup.stamp
clean-setup.stamp: .PHONY
	-rm -f setup.stamp

###############################################################################
# AMI

# Parameters:
#
# AMI_REV
#       Revision number of resulting AMI for default AMI_NAME.
#
# AMI_NAME
#       Name of the resulting AMI.

AMI_REV = 0
AMI_NAME = probcomp/images-testing/$(PROJECT)-$(AMI_REV)

ami.json: reservation.json
ami.json: setup.stamp
	-rm -f $@.tmp
	instance_id=`jq -r '.Instances[0].InstanceId' < reservation.json` && \
	$(AWSCLI) ec2 create-image \
		--instance-id "$$instance_id" \
		--name $(AMI_NAME) \
		> $@.tmp && \
	image_id=`jq -r .ImageId < $@.tmp` && \
	$(TAG_PROJECT) "$$image_id"
	mv -f $@.tmp $@

DESCRIBE_AMIS = $(AWSCLI) ec2 describe-images $(FILTER_PROJECT)
describe-amis: .PHONY
	@$(DESCRIBE_AMIS)

LIST_AMIS = $(DESCRIBE_AMIS) | jq -r '.Images[].ImageId'
list-amis: .PHONY
	@$(LIST_AMIS)

distclean: _clean-amis
_clean-amis: .PHONY
	$(MAKE) clean-amis
clean-amis: .PHONY
	$(LIST_AMIS) \
		| while read id; do \
			$(AWSCLI) ec2 deregister-image --image-id "$$id"; \
		done
	-rm -f ami.json

ami: .PHONY
ami: ami.json
	image_id=`jq -r .ImageId < ami.json` && \
	sh amiwait.sh \
		$(AWSCLI) ec2 describe-images --image-ids "$$image_id"
