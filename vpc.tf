# For Provider
provider "aws" {
  region = var.AWS_REGION
}

# For VPC
resource "aws_vpc" "shan_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags = {
        Name = "shan-vpc"
    }
}

# For Subnets
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.shan_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
        Name = "public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.shan_vpc.id
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
        Name = "private_subnet"
    }
}

# For Internet Gateway
resource "aws_internet_gateway" "shan-igw" {
    vpc_id = aws_vpc.shan_vpc.id
    tags = {
        Name = "shan-IGW"
    }
} 

# For Route Tables
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.shan_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.shan-igw.id
    }
    tags = {
        Name = "public_rt"
    }
}

# For Route associations public
resource "aws_route_table_association" "public_rt_asn" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}
