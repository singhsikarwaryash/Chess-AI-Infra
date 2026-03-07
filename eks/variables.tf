variable "project" {
  type        = string
  description = "Project prefix"
  default     = "chess-ai"
}

variable "aws_region" {
  type        = string
  description = "AWS region for EKS"
  default     = "ap-south-1"
}

variable "cluster_version" {
  type        = string
  description = "EKS Kubernetes minor version"
  default     = "1.35"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from PR-04 outputs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for worker nodes"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs (used by ALB)"
  default     = []
}