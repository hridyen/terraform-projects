terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Get latest Ubuntu 20.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

 
  
}

# Lookup existing SG by name
data "aws_security_group" "server" {
  tags = {
   
   
   Name = "MySG"
   ENV = "PROD"
  

}
}

output "aws_ami" {
  value = data.aws_ami.ubuntu.id
}

output "security_group" {
  value = data.aws_security_group.server.id
}
#vpc
data "aws_vpc" "name" {
  tags = {
    Name = "vpc1"
    ENV = "PROD"
  
}
}
#output vpc
output "vpc" {
  value = data.aws_vpc.name.id
}
#availabilty  zone
data "aws_availability_zones" "available" {
  state = "available"
}
#output
output "availability_zone" {
  value = data.aws_availability_zones.available
}
#currnet ac  dewtail
data "aws_caller_identity" "name" {
}

#output caller idenity 
output "caller_identity" {
  value = data.aws_caller_identity.name
}

#region 
data "aws_region" "region" {
 
}
#output region
output "region" {
  value = data.aws_region.region
}
#subnet id
data "aws_subnet" "subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.name.id]
  }
  tags = {
    Name = "private-subnet"
  }
}
# Create an EC2 instance using that SG and subnet
resource "aws_instance" "server" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.micro"
  subnet_id =  data.aws_subnet.subnet.id
  security_groups = [ data.aws_security_group.server.id]
  
  tags = {
    Name = "MyServer"
  }
}
