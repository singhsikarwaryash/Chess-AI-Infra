output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = data.aws_eks_cluster.this.endpoint
  description = "EKS API server endpoint"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "OIDC provider ARN (IRSA)"
}

output "lb_controller_role_arn" {
  value       = module.lb_controller_irsa.iam_role_arn
  description = "IAM role ARN used by AWS Load Balancer Controller"
}

output "managed_node_groups" {
  value       = module.eks.eks_managed_node_groups
  description = "Managed node groups"
}