terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "bucket-7f02bd9d9e093578"
    key    = "terraform.tfstate"
    region = "us-east-1"
    
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