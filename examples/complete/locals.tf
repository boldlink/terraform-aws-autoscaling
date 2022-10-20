locals {
  name = "complete-autoscaling-example"

  subnet_az = [
    for az in data.aws_subnet.private : az.availability_zone
  ]

  subnet_id = [
    for i in data.aws_subnet.private : i.id
  ]

  private_subnets           = local.subnet_id[0]
  azs                       = local.subnet_az[0]
  supporting_resources_name = "terraform-aws-autoscaling"
  vpc_id                    = data.aws_vpc.supporting.id
  vpc_cidr                  = data.aws_vpc.supporting.cidr_block
  tags = {
    Environment        = "examples"
    Name               = local.name
    "user::CostCenter" = "terraform-registry"
  }
}
