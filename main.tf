#---root/main.tf


module "networking" {
  source = "./networking"
  vpc_cidr = "10.10.0.0/16"
  private_sn_count = 3
  public_sn_count = 2
  max_subnets = 20
  security_groups = local.security_groups
  access_ip = var.access_ip
  public_cidrs = [for i in range(2,255,2): cidrsubnet(local.vpc_cidr, 8,i )]
  private_cidrs = [for i in range(1,255,2): cidrsubnet(local.vpc_cidr, 8,i )]
}