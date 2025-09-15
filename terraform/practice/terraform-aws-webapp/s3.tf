resource "aws_s3_bucket" "app_bucket" {
  bucket = "terraform-webapp-bucket-${random_id.bucket.hex}"
}

resource "random_id" "bucket" {
  byte_length = 4
}
