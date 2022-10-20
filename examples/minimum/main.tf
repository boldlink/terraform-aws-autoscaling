module "minimal" {
  source = "../../"

  ## Autoscaling group
  name                = local.name
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = local.subnet_id
  vpc_id              = local.vpc_id

  # Launch template
  launch_template_description = "minimal launch template example"
  create_launch_template      = true
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "t2.medium"
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
