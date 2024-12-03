variable "region" {
  description = "AWS region"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "iam_user_name" {
  description = "The name of the IAM user for read-only access"
  type        = string
}
