variable "project" {
  description = "Project prefix for all resources"
  type        = string
  default     = "dataviz"
}

variable "env" {
  description = "Environment name (dev/prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}
