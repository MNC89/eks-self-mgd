# DO NOT REMOVE DUMMY MODULE references and their code, they should remain as examples
module "module1" {
  source = "../../dummy-module-1"
  # ... any required variables for module1
  greeting = var.greeting

}

module "module2" {
  source = "../../dummy-module-2"

  input_from_module1 = module.module1.greeting_message
  # ... any other required variables for module2
}

### VPC ###

module "vpc" {
  source                = "../../vpc"
  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  igw_name              = var.igw_name
  pub_rt_name           = var.pub_rt_name
  priv_rt_name          = var.priv_rt_name
  public_subnet_object  = var.public_subnet_object
  private_subnet_object = var.private_subnet_object
}

### VPC Outputs ###

output "public_id_1" {
  value = module.vpc.public_subnet_ids[0]
}

output "public_id_2" {
  value = module.vpc.public_subnet_ids[1]
}

output "public_id_3" {
  value = module.vpc.public_subnet_ids[2]
}

output "vpc_id" {
  value = module.vpc.fp_vpc_id
}

### EKS ###

module "eks_cluster" {
  source           = "../../eks"
  eks_cluster_name = var.eks_cluster_name
  k8_version       = var.k8_version
  eks_pub_sub_ids  = module.vpc.public_subnet_ids
  asg_pub_sub_ids  = module.vpc.public_subnet_ids
  vpc_id           = module.vpc.fp_vpc_id
  eks_iam_role_name = var.eks_iam_role_name
  eks_policy = var.eks_policy
  vpc_cni_addon_name = var.vpc_cni_addon_name
  vpc_cni_role_name = var.vpc_cni_role_name
  ebs_csi_addon_name = var.ebs_csi_addon_name
  ebs_csi_role_name = var.ebs_csi_role_name
  eks_sg_name = var.eks_sg_name
}

### EKS Outputs###

output "eks_sg" {
  value = module.eks_cluster.eks_sg
}

