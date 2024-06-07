variable "greeting" {
  description = "A greeting phrase"
}

### VPC variables ###

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "final-project-vpc"
}

### Internet Gateway variables ###

variable "igw_name" {
  type    = string
  default = "final-project-internet-gateway"
}

### Public Route Table variables ###

variable "pub_rt_name" {
  type    = string
  default = "final-project-public-route-table"
}

### Private Route Table variables ###

variable "priv_rt_name" {
  type    = string
  default = "final-project-private-route-table"
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
