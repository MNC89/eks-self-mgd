output "endpoint" {
  value = aws_eks_cluster.fp_eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.fp_eks_cluster.certificate_authority[0].data
}

output "eks_sg" {
  value = aws_eks_cluster.fp_eks_cluster.vpc_config[0].cluster_security_group_id
}

output "eks_id" {
  value = element(split(".", replace(aws_eks_cluster.fp-cluster.endpoint, "https://", "")), 0)
}