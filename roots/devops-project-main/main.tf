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
  eks_cluster_name      = var.eks_cluster_name
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
  source                  = "../../eks"
  eks_cluster_name        = var.eks_cluster_name
  k8_version              = var.k8_version
  eks_pub_sub_ids         = module.vpc.public_subnet_ids
  asg_pub_sub_ids         = module.vpc.public_subnet_ids
  vpc_id                  = module.vpc.fp_vpc_id
  eks_iam_role_name       = var.eks_iam_role_name
  eks_policy              = var.eks_policy
  vpc_cni_addon_name      = var.vpc_cni_addon_name
  vpc_cni_version         = var.vpc_cni_version
  vpc_cni_update_resolve  = var.vpc_cni_update_resolve
  vpc_cni_role_name       = var.vpc_cni_role_name
  ebs_csi_addon_name      = var.ebs_csi_addon_name
  ebs_csi_role_name       = var.ebs_csi_role_name
  eks_sg_name             = var.eks_sg_name
  asg_name                = var.asg_name
  asg_max_size            = var.asg_max_size
  asg_min_size            = var.asg_min_size
  asg_desired_size        = var.asg_desired_size
  asg_health_grace_period = var.asg_health_grace_period
  asg_health_type         = var.asg_health_type
  asg_cap_rebalance       = var.asg_cap_rebalance
  on_dem_base             = var.on_dem_base
  on_dem_percent_over     = var.on_dem_percent_over
  spot_strategy           = var.spot_strategy
  spot_inst_type          = var.spot_inst_type
  asg_lt_name             = var.asg_lt_name
  asg_lt_inst_shutdown    = var.asg_lt_inst_shutdown
  asg_lt_keypair          = var.asg_lt_keypair
  asg_lt_mem              = var.asg_lt_mem
  asg_lt_vcpu             = var.asg_lt_vcpu
  lt_ebs_name             = var.lt_ebs_name
  lt_ebs_size             = var.lt_ebs_size
  lt_ebs_type             = var.lt_ebs_type
  lt_ebs_iops             = var.lt_ebs_iops
  lt_ebs_throughput       = var.lt_ebs_throughput
  wk_name                 = var.wk_name
  worker_policy           = var.worker_policy
}

### EKS Outputs###

output "eks_sg" {
  value = module.eks_cluster.eks_sg
}
