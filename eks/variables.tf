### eks.tf Variables ###
variable "eks_cluster_name" {
  type    = string
  default = "final-project-eks-cluster-dev"
}

variable "k8_version" {
  type    = string
  default = "1.29"
}

variable "eks_pub_sub_ids" {
  type = list(string)
}

variable "eks_iam_role_name" {
  type    = string
  default = "fp-eks-cluster-role"
}

variable "eks_policy" {
  type = set(string)
  default = [ 
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController" 
  ]
}

### workers.tf Variables ###

variable "asg_pub_sub_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}