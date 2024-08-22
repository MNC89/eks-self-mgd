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
eks_cluster_name  = "final-project-eks-cluster-staging" #change this per environment!
k8_version        = "1.29"
environment       = "staging" #change this per environment!
eks_iam_role_name = "fp-eks-cluster-role"
eks_policy = [
  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
]
### EKS add_on variables ###
vpc_cni_addon_name     = "vpc-cni"
vpc_cni_version        = "v1.18.2-eksbuild.1"
vpc_cni_update_resolve = "PRESERVE"
vpc_cni_role_name      = "fp-eks-vpc-cni-role"
ebs_csi_addon_name     = "aws-ebs-csi-driver"
ebs_csi_role_name      = "fp-eks-ebs-csi-role"
### EKS security group variables ###
eks_sg_name = "eks-sg"
### EKS ASG variables
asg_name                = "final-project-asg"
asg_max_size            = 5
asg_min_size            = 1
asg_desired_size        = 3
asg_health_grace_period = 300
asg_health_type         = "EC2"
asg_cap_rebalance       = true
on_dem_base             = 0
on_dem_percent_over     = 20
spot_strategy           = "capacity-optimized"
spot_inst_type = [
  "t3.medium",
  "t3a.medium",
  "t3.large"
]
### EKS ASG launch template variables ###
asg_lt_name          = "final-project-asg-lt"
asg_lt_inst_shutdown = "terminate"
asg_lt_keypair       = "fp-eks-worker-node-key-pair"
asg_lt_mem           = 4096
asg_lt_vcpu          = 2
lt_ebs_name          = "/dev/xvda"
lt_ebs_size          = 80
lt_ebs_type          = "gp3"
lt_ebs_iops          = 3000
lt_ebs_throughput    = 125
wk_name              = "fp-eks-worker-node"
worker_policy = [
  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
]
