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

resource "random_id" "random" {
    byte_length = 8
  
}
resource "aws_s3_bucket" "bucket1" {
  
bucket = "bucket-${random_id.random.hex}"

}
resource "aws_s3_object" "data" {
    bucket = aws_s3_bucket.bucket1.bucket
    source = "./mytext.txt"
    key = "mydata.txt"
  
}

output "name" {
  value = random_id.random.hex
}
