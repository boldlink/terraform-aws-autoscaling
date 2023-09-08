module "minimal" {
  #checkov:skip=CKV_AWS_290
  #checkov:skip=CKV_AWS_355
  source = "../../"

  ## Autoscaling group
  name                = var.name
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = local.subnet_id
  vpc_id              = local.vpc_id

  # Launch template
  launch_template_description = var.description
  create_launch_template      = var.create_launch_template
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  security_group_egress       = var.security_group_egress
  tags                        = local.tags

  tag_specifications = [
    {
      resource_type = "volume"
      tags          = local.tags
    },
    {
      resource_type = "instance"
      tags          = local.tags
    }
  ]
}
