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

output "public_ids" {
  value = module.vpc.public_subnet_ids
}
