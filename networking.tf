# This creates 2 public networks and 2 private ones for HA in different AZs. The public networks have the NAT Gateway and the EIP associated to it as well as the 
# route to the Internet Gateway

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_subnet
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "public_network" {
  vpc_id = aws_vpc.main.id
}

resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_network.id
  }
}

resource "aws_eip" "public_network" {
  vpc = true
}

resource "aws_subnet" "public_network" {
  cidr_block        = var.public_subnet_cidrs[0]
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}c"
}

resource "aws_nat_gateway" "public_network" {
  allocation_id = aws_eip.public_network.id
  subnet_id     = aws_subnet.public_network.id
}

resource "aws_eip" "public_network1" {
  vpc = true
}

resource "aws_subnet" "public_network1" {
  cidr_block        = var.public_subnet_cidrs[1]
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}a"
}

resource "aws_nat_gateway" "public_network1" {
  allocation_id = aws_eip.public_network1.id
  subnet_id     = aws_subnet.public_network1.id
}

resource "aws_route_table" "public_networks" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_network.id
  }
}

resource "aws_route_table_association" "public_network" {
  route_table_id = aws_route_table.public_networks.id
  subnet_id      = aws_subnet.public_network.id
}

resource "aws_subnet" "private_network" {
  cidr_block        = var.private_subnet_cidrs[0]
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}b"
}

resource "aws_subnet" "private_network1" {
  cidr_block        = var.private_subnet_cidrs[1]
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}a"
}

resource "aws_route_table_association" "private_network1" {
  route_table_id = aws_route_table.private_networks.id
  subnet_id      = aws_subnet.private_network1.id
}

resource "aws_route_table_association" "private_network" {
  route_table_id = aws_route_table.private_networks.id
  subnet_id      = aws_subnet.private_network.id
}

resource "aws_route_table" "private_networks" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_network.id
  }
}
