locals {
  cluster_name = "${var.project}-eks"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = true
  enable_irsa                     = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # grant cluster-admin to the creator (your EC2 role)
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    vpc-cni    = { most_recent = true }
    kube-proxy = { most_recent = true }
    coredns    = { most_recent = true }
  }

  eks_managed_node_groups = {
    spot-ng = {
      ami_type       = "AL2_x86_64"
      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      min_size     = 1
      max_size     = 2
      desired_size = 1

      subnet_ids = var.private_subnet_ids
      labels     = { role = "spot" }
      taints     = []
    }
  }
}

# Pull details for providers
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

# Configure k8s/helm providers to talk to the new cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# IRSA role for AWS Load Balancer Controller
module "lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name = "${var.project}-alb-controller"

  attach_lb_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# Install AWS Load Balancer Controller via Helm (version left unpinned to pull latest compatible)
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  depends_on = [module.eks, module.lb_controller_irsa]

  set { name = "clusterName"  value = module.eks.cluster_name }
  set { name = "region"       value = var.aws_region }
  set { name = "vpcId"        value = var.vpc_id }

  set { name = "serviceAccount.create" value = "true" }
  set { name = "serviceAccount.name"   value = "aws-load-balancer-controller" }
  set {
    # escape the slash in HCL
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_controller_irsa.iam_role_arn
  }
}

# Namespaces
resource "kubernetes_namespace" "envs" {
  for_each = toset(["chess-dev", "chess-stage", "chess-prod"])
  metadata {
    name = each.key
    labels = { project = var.project, env = each.key }
  }
  depends_on = [module.eks]
}