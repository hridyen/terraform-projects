output "api_base_url" {
  description = "Base invoke URL for the HTTP API stage"
  value       = "${aws_apigatewayv2_api.api.api_endpoint}/${var.stage}"
}

output "table_name" {
  value = aws_dynamodb_table.url_table.name
}
