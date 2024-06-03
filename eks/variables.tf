variable "eks_cluster_name" {
  type    = string
  default = "final-project-eks-cluster-dev"
}

variable "eks_pub_sub_ids" {
  type = list(string)
}