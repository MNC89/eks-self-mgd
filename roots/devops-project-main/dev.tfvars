greeting = "Hi"
### VPC variables ###
vpc_cidr = "10.0.0.0/16"
vpc_name = "final-project-vpc"
### Internet Gateway variables ###
igw_name = "final-project-internet-gateway"
### Public Route Table variables ###
pub_rt_name = "final-project-public-route-table"
### Private Route Table variables ###
priv_rt_name = "final-project-private-route-table"
### Public Subnet variables ###
public_subnet_object = {
  "pub_sub_1" = {
    cidr = "10.0.0.0/20",
    az   = "us-east-1a",
    name = "public-subnet-1"
  },
  "pub_sub_2" = {
    cidr = "10.0.16.0/20",
    az   = "us-east-1b",
    name = "public-subnet-2"
  },
  "pub_sub_3" = {
    cidr = "10.0.32.0/20",
    az   = "us-east-1c",
    name = "public-subnet-3"
  }
}
### Private subnet variables ###
private_subnet_object = {
  "priv_sub_1" = {
    cidr = "10.0.128.0/20"
    az   = "us-east-1a",
    name = "private-subnet-1"
  },
  "priv_sub_2" = {
    cidr = "10.0.144.0/20",
    az   = "us-east-1b",
    name = "private-subnet-2"
  },
  "priv_sub_3" = {
    cidr = "10.0.160.0/20",
    az   = "us-east-1c",
    name = "private-subnet-3"
  }
}
### EKS cluster variables ###
eks_cluster_name  = "final-project-eks-cluster-dev"
k8_version        = "1.29"
eks_iam_role_name = "fp-eks-cluster-role"
eks_policy = [
  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
]
### EKS add_on variables ###
vpc_cni_addon_name = "vpc-cni"
vpc_cni_role_name  = "fp-eks-vpc-cni-role"
ebs_csi_addon_name = "aws-ebs-csi-driver"
ebs_csi_role_name  = "fp-eks-ebs-csi-role"
### EKS security group variables ###
eks_sg_name = "eks-sg"
