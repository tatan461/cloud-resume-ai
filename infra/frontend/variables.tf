variable "aws_region" {
  description = "Main deployment region"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for the site"
  type        = string
}

variable "domain_name" {
  description = "Your domain, e.g. yourname.dev"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
}
