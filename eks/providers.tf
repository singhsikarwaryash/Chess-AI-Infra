provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = var.project
      Stack   = "eks"
      Managed = "terraform"
    }
  }
}