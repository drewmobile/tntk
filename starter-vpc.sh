#!/bin/bash

# makes a VPC with 10.0.0.0/16 CIDR
vpc_id=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --output text --query 'Vpc.VpcId')
echo vpc_id=$vpc_id

# enable DNS support
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-support "{\"Value\":true}"
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-hostnames "{\"Value\":true}"

# tag the vpc
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=my_vpc

#wait for the vpc
echo -n "waiting for vpc to become available"
while state=$(aws ec2 describe-vpcs --vpc-ids $vpc_id --output text --query 'Vpcs[0].State'); test "$state" != "available"; do
    echo -n "."
    sleep 5
done
echo "vpc is available"

#create an internet gateway
igw=$(aws ec2 create-internet-gateway --output text --query 'InternetGateway.InternetGatewayId')

#attach the internet gateway to the vpc
echo "attaching internet gateway $igw to vpc $vpc_id"
aws ec2 attach-internet-gateway --internet-gateway-id $igw --vpc-id $vpc_id

# get the route table id for the vpc
rtb_id=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$vpc_id --output text --query 'RouteTables[0].RouteTableId')
echo "route table id is $rtb_id"

# create our main subnets
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.0.0/24 --availability-zone us-east-1a --output text --query 'Subnet.SubnetId')
echo "subnet id is $subnet_id"

# tag the subnet
aws ec2 create-tags --resources $subnet_id --tags Key=Name,Value=my_subnet

# associate the route table with the subnet
aws ec2 associate-route-table --route-table-id $rtb_id --subnet-id $subnet_id

# create another subnet
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.10.0/24 --availability-zone us-east-1b --output text --query 'Subnet.SubnetId')
echo "subnet id is $subnet_id"

# tag the subnet
aws ec2 create-tags --resources $subnet_id --tags Key=Name,Value=my_other_subnet

# associate the route table with the subnet
aws ec2 associate-route-table --route-table-id $rtb_id --subnet-id $subnet_id

# create a route to the internet gateway
aws ec2 create-route --route-table-id $rtb_id --destination-cidr-block 0.0.0.0/0 --gateway-id $igw

# create a security group
sg=$(aws ec2 create-security-group --group-name my_security_group --description "my security group" --vpc-id $vpc_id --output text --query 'GroupId')
echo "security group id is $sg"

# allow inbound ssh
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 22 --cidr 0.0.0.0/0   # allow inbound ssh

# allow inbound http
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 80 --cidr 0.0.0.0/0   # allow inbound http

# create a key pair
aws ec2 create-key-pair --key-name my_key --query 'KeyMaterial' --output text > my_key.pem
chmod 400 my_key.pem

# create an instance
instance_id=$(aws ec2 run-instances --image-id ami-0b33d91d --count 1 --instance-type t2.micro --key-name my_key --associate-public-ip-address --security-group-ids $sg --subnet-id $subnet_id --output text --query 'Instances[0].InstanceId')
echo "instance id is $instance_id"

# wait for the instance to be running
echo -n "waiting for instance to be running"
while state=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[0].Instances[0].State.Name'); test "$state" != "running"; do
    echo -n "."
    sleep 5
done
echo "instance is running"

# get the public dns name of the instance
public_dns=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[0].Instances[0].PublicDnsName')
echo "public dns name is $public_dns"

# wait for the instance to be reachable
echo -n "waiting for instance to be reachable"
while ! ssh -i my_key.pem -o StrictHostKeyChecking=no ec2-user@$public_dns hostname; do
    echo -n "."
    sleep 5
done

echo "instance is reachable"
echo "ssh -i my_key.pem ec2-user@$public_dns"

# clean up
#aws ec2 terminate-instances --instance-ids $instance_id
#aws ec2 delete-security-group --group-id $sg
#aws ec2 disassociate-route-table --association-id $rtb_assoc_id
#aws ec2 delete-route-table --route-table-id $rtb_id

#aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $vpc_id
#aws ec2 delete-internet-gateway --internet-gateway-id $igw

#aws ec2 delete-subnet --subnet-id $subnet_id
#aws ec2 delete-vpc --vpc-id $vpc_id
#rm my_key.pem



