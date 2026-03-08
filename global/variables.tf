variable "project" {
  type        = string
  description = "Project tag/prefix, e.g., chess-ai"
}

variable "aws_region" {
  type        = string
  description = "Region to deploy the VPC"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.20.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Number of AZs to spread subnets across"
  default     = 2
}