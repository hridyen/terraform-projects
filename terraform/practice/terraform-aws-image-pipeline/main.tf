provider "aws" {
  region = "ap-south-1"
}

# S3 bucket
resource "aws_s3_bucket" "uploads" {
  bucket = "hriday-image-uploads"
  force_destroy = true
}

# DynamoDB table
resource "aws_dynamodb_table" "metadata" {
  name         = "ImageMetadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "filename"

  attribute {
    name = "filename"
    type = "S"
  }
}

# Lambda execution role
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach policies to Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy_dynamo" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Package Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

# Lambda function
resource "aws_lambda_function" "file_metadata" {
  function_name = "ImageMetadataLambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMO_TABLE = aws_dynamodb_table.metadata.name
    }
  }
}
# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_metadata.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}


# S3 -> Lambda trigger
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_metadata.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_function.file_metadata]
}
