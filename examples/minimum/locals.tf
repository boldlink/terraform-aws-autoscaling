locals {
  name = "minimal-autoscaling-example"

  subnet_id = [
    for i in data.aws_subnet.private : i.id
  ]

  supporting_resources_name = "terraform-aws-autoscaling"
  vpc_id                    = data.aws_vpc.supporting.id
  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
    Department         = "DevOps"
    InstanceScheduler  = true
    Project            = "Examples"
    Owner              = "Boldlink"
    LayerName          = "cExample"
    LayerId            = "cExample"
  }
}
