variable "eks_cluster_name" {
  type    = string
  default = "final-project-eks-cluster-dev"
}

variable "k8_version" {
  type = string
  default = "1.29"
}

variable "eks_pub_sub_ids" {
  type = list(string)
}

### Workers.tf Variables ###

variable "asg_pub_sub_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}