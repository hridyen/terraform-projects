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

# Generate a random bucket suffix
resource "random_id" "random" {
  byte_length = 8
}

# Create S3 bucket
resource "aws_s3_bucket" "webapp" {
  bucket = "webapp-${random_id.random.hex}"
}

# Upload index.html file
resource "aws_s3_object" "indexhtml" {
  bucket = aws_s3_bucket.webapp.bucket
  source = "./index.html"
  key    = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "stylescss" {
  bucket = aws_s3_bucket.webapp.bucket
  source = "./styles.css"
  key    = "styles.css"
  content_type = "text/css"
}



# Allow public access settings
resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.webapp.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}



# Public read policy for bucket
resource "aws_s3_bucket_policy" "webapp" {
  bucket = aws_s3_bucket.webapp.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.webapp.id}/*"
        ]
      }
    ]
  })
  

  depends_on = [aws_s3_bucket_public_access_block.example]
}
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.webapp.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}
output "name" {
  value = aws_s3_bucket_website_configuration.example.website_endpoint
}