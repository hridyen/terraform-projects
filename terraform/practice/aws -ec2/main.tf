terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "server" {
  
ami = "ami-020cba7c55df1f615"
instance_type = "t2.micro"

tags = {
    Name = "MyServer"
}

}