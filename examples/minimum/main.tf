locals {
  name = "minimal-example"
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
  instance_type               = "t3.nano"

  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}
