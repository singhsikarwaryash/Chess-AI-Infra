variable "project" {
  type        = string
  description = "Project tag/prefix, e.g., chess-ai"
}

variable "aws_region" {
  type        = string
  description = "AWS region to create state resources"
  default     = "ap-south-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state (e.g., chess-ai-tfstate-<uniq>)"
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking (e.g., chess-ai-tf-lock)"
}