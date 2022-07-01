locals {
  name = "minimal-autoscaling-example"
}

module "minimal" {
  source = "../../"

  ## Autoscaling group
  name               = local.name
  min_size           = 1
  max_size           = 2
  availability_zones = data.aws_availability_zones.available.names

  # Launch template
  launch_template_description = "minimal launch template example"
  create_launch_template      = true
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "t2.medium"

  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}
