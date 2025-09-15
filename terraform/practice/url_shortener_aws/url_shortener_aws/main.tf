terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.region
}

# ------- DynamoDB table (short -> original) -------
resource "aws_dynamodb_table" "url_table" {
  name         = "url_shortener"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short"

  attribute {
    name = "short"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Project = "url-shortener"
  }
}

# ------- IAM role for Lambda -------
resource "aws_iam_role" "lambda_role" {
  name = "urlshortener-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "",
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Basic logging
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Least-privilege access to only our table
resource "aws_iam_policy" "dynamodb_policy" {
  name   = "urlshortener-dynamodb-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "RWTable",
        Effect: "Allow",
        Action: [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        Resource: aws_dynamodb_table.url_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ddb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

# ------- Package Lambda from local source -------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

# ------- Lambda function -------
resource "aws_lambda_function" "url_shortener" {
  function_name = "url_shortener_py"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10
  memory_size      = 256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.url_table.name
      BASE_HOST  = "" # optional: custom domain/CloudFront host; blank => API host used
    }
  }

  tags = {
    Project = "url-shortener"
  }
}

# ------- API Gateway (HTTP API v2) -------
resource "aws_apigatewayv2_api" "api" {
  name          = "url-shortener-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 3600
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.url_shortener.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 10000
}

# POST /shorten -> create short URL
resource "aws_apigatewayv2_route" "shorten" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /shorten"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# GET /{short} -> redirect
resource "aws_apigatewayv2_route" "redirect" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /{short}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url_shortener.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# Stage (auto deploy)
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = var.stage
  auto_deploy = true
}
