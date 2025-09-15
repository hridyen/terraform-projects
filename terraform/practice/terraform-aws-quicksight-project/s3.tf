resource "aws_s3_bucket" "raw" {
  bucket        = local.raw_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "processed" {
  bucket        = local.processed_name
  force_destroy = true
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = local.artifacts_name
  force_destroy = true
}

# Upload Glue script
resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.artifacts.id
  key    = local.glue_scripts_key
  source = "${path.module}/scripts/etl_job.py"
  etag   = filemd5("${path.module}/scripts/etl_job.py")
}

# Sample CSV upload
resource "aws_s3_object" "sample_csv" {
  bucket       = aws_s3_bucket.raw.id
  key          = "incoming/sample_sales.csv"
  content      = <<CSV
order_id,order_date,region,category,product,quantity,unit_price
1001,2024-01-03,North,Electronics,Headphones,2,49.99
1002,2024-01-05,West,Home,Fan,1,24.50
1003,2024-02-10,South,Electronics,Keyboard,3,19.90
1004,2024-03-12,East,Apparel,T-Shirt,4,9.99
1005,2024-03-14,North,Grocery,Coffee,5,5.49
CSV
  content_type = "text/csv"
}
