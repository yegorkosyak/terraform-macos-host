variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-central-1"
}

variable "key_name" {
  description = "RSA private key"
  type        = string
  default     = "macos_key"
}