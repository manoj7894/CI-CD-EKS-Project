resource "aws_vpc" "vpc" {
    cidr_block       = var.vpc_id
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    
    tags = {
        Name = "vpc01"
    }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id  # Replace with your VPC ID
  cidr_block        = var.public_subnet_id_value   # Replace with your desired CIDR block
  availability_zone = var.availability_zone # Replace with your desired Availability Zone
   map_public_ip_on_launch = true           # Enable auto-assign public IP

  # Optional: Assign tags to your subnets
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id  # Replace with your VPC ID
  cidr_block        = var.private_subnet_id_value  # Replace with your desired CIDR block
  availability_zone = var.availability_zone1 # Replace with your desired Availability Zone

  # Optional: Assign tags to your subnets
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  # Optional: Assign tags to your Internet Gateway
  tags = {
    Name = "My Internet Gateway"
  }
}

resource "aws_eip" "eip" {
    vpc  = true

  # Optional: Associate tags with the Elastic IP
  tags = {
    Name = "MyElasticIP"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

# Optional: Associate tags with the Elastic IP
  tags = {
    Name = "net-gateway"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Optional: Assign tags to your route table
  tags = {
    Name = "MyRouteTable"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  # Optional: Assign tags to your route table
  tags = {
    Name = "MyRouteTable2"
  }
}

resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt2.id
}