output "s3_bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}

output "dynamodb_table" {
  value = aws_dynamodb_table.metadata.name
}

output "lambda_function" {
  value = aws_lambda_function.file_metadata.function_name
}
