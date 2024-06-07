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

variable "vpc_cni_addon_name" {
  type    = string
  default = "vpc-cni"
}

variable "vpc_cni_role_name" {
  type    = string
  default = "fp-eks-vpc-cni-role"
}

variable "ebs_csi_addon_name" {
  type    = string
  default = "aws-ebs-csi-driver"
}

variable "ebs_csi_role_name" {
  type    = string
  default = "fp-eks-ebs-csi-role"
}

variable "eks_sg_name" {
  type    = string
  default = "eks-sg"
}

# variable "eks_addon_object" {
#   type = map(object({
#     addon_name      = string,
#     addon_role_name = string,
#     addon_policy    = string
#   }))
#   default = {
#     "vpc_cni" = {
#       addon_name      = "vpc-cni",
#       addon_role_name = "fp-eks-vpc-cni-role",
#       addon_policy    = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#     },
#     "ebs_csi" = {
#       addon_name      = "aws-ebs-csi-driver",
#       addon_role_name = "fp-eks-ebs-csi-role",
#       addon_policy    = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#     }
#   }
# }

### workers.tf Variables ###

variable "asg_name" {
  type    = string
  default = "final-project-asg"
}

variable "asg_max_size" {
  type    = number
  default = 5
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_desired_size" {
  type    = number
  default = 3
}

variable "asg_health_grace_period" {
  type    = number
  default = 300
}

variable "asg_health_type" {
  type    = string
  default = "EC2"
}

variable "asg_cap_rebalance" {
  type    = bool
  default = true
}

#not for main variables
variable "asg_pub_sub_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}