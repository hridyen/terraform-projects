variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "stage" {
  description = "API stage name"
  type        = string
  default     = "dev"
}
