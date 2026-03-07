locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Simple subnetting: /19 per AZ for private and public
  private_subnets = [
    for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 3, i)  # /19
  ]
  public_subnets = [
    for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 3, i + 8) # /19 offset
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_dns_support   = true
  enable_dns_hostnames = true

  # Cost-optimized: one NAT gateway shared by private subnets
  enable_nat_gateway = true
  single_nat_gateway = true

  # Optional: map public IPs for public subnets
  map_public_ip_on_launch = true

  # Tags useful for EKS/ALB
  tags = {
    "kubernetes.io/cluster/${var.project}-eks" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
