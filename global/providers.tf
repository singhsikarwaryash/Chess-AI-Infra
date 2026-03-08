provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = var.project
      Stack   = "global"
      Managed = "terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}