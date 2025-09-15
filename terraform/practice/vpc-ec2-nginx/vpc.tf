#create vpc 

resource "aws_vpc" "vpc1" {
  
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc1"
  }
}
#private subnet

resource "aws_subnet" "private" {
  
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.vpc1.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet"
  }
}

#public  subnet

resource "aws_subnet" "public" {
  
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.vpc1.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet"
  }
}
#internet gatewAY 

resource "aws_internet_gateway" "igw1" {
  
  vpc_id = aws_vpc.vpc1.id
  tags = {
Name = "igw1"

  }
}

#routing table

resource "aws_route_table" "rt1" {
  
  vpc_id = aws_vpc.vpc1.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
  tags = {
    Name = "rt1"
  }
}

resource "aws_route_table_association" "public-sub" {
   route_table_id = aws_route_table.rt1.id
    subnet_id      = aws_subnet.public.id
  
}

