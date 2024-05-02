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
