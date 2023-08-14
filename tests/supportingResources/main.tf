module "autoscaling_vpc" {
  #checkov:skip=CKV_TF_1
  source                 = "boldlink/vpc/aws"
  version                = "3.0.4"
  name                   = var.name
  cidr_block             = var.cidr_block
  enable_dns_support     = var.enable_dns_support
  enable_dns_hostnames   = var.enable_dns_hostnames
  enable_public_subnets  = var.enable_public_subnets
  enable_private_subnets = var.enable_private_subnets
  tags                   = local.tags

  public_subnets = {
    public = {
      cidrs = local.public_subnets
      nat   = var.nat
    }
  }

  private_subnets = {
    private = {
      cidrs = local.private_subnets
    }
  }
}
