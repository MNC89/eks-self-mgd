### VPC variables ###

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type = string
}

### Internet Gateway variables ###

variable "igw_name" {
  type = string
}

### Public Route Table variables ###

variable "pub_rt_name" {
  type = string
}

### Private Route Table variables ###

variable "priv_rt_name" {
  type = string
}

### Public Subnet variables ###

variable "public_subnet_object" {
  type = map(object({
    cidr = string,
    az   = string,
    name = string

  }))
  default = {
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
}

### Private subnet variables ###

variable "private_subnet_object" {
  type = map(object({
    cidr = string,
    az   = string,
    name = string

  }))
  default = {
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
}

### eks.tf variables ###

### EKS cluster variables ###
variable "eks_cluster_name" {
  type = string
}

variable "k8_version" {
  type    = string
  default = "1.29"
}

variable "environment" {
  type = string
}

variable "eks_iam_role_name" {
  type = string
}

variable "eks_policy" {
  type = set(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]
}

### EKS add_on variables ###

variable "vpc_cni_addon_name" {
  type = string
}

variable "vpc_cni_version" {
  type = string
}

variable "vpc_cni_update_resolve" {
  type = string
}

variable "vpc_cni_role_name" {
  type = string
}

variable "ebs_csi_addon_name" {
  type = string
}

variable "ebs_csi_role_name" {
  type = string
}

### EKS security group variables ###

variable "eks_sg_name" {
  type = string
}

### workers.tf variables ###

### ASG variables ###

variable "asg_name" {
  type = string
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

variable "on_dem_base" {
  type    = number
  default = 0
}

variable "on_dem_percent_over" {
  type    = number
  default = 20
}

variable "spot_strategy" {
  type    = string
  default = "capacity-optimized"
}

variable "spot_inst_type" {
  type = list(string)
  default = [
    "t3.medium",
    "t3a.medium",
    "t2.medium"
  ]
}

### ASG lt variables ###

variable "asg_lt_name" {
  type = string
}

variable "asg_lt_inst_shutdown" {
  type = string
}

variable "asg_lt_keypair" {
  type    = string
  default = "fp-eks-worker-node-key-pair"
}

variable "asg_lt_mem" {
  type    = number
  default = 4096
}

variable "asg_lt_vcpu" {
  type    = number
  default = 2
}
variable "lt_ebs_name" {
  type = string
}

variable "lt_ebs_size" {
  type    = number
  default = 80
}

variable "lt_ebs_type" {
  type    = string
  default = "gp3"
}

variable "lt_ebs_iops" {
  type    = number
  default = 3000
}

variable "lt_ebs_throughput" {
  type    = number
  default = 125
}

variable "wk_name" {
  type = string
}

variable "worker_policy" {
  type = set(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

### Cluster AutoScaler Variables ###

variable "eks_cluster_id" {
  description = "EKS cluster's id"
  type        = string
}