module "minimal" {
  source = "../../"

  ## Autoscaling group
  name                 = "minimal-example"
  launch_template_name = "minimal-example"
  min_size             = 0
  max_size             = 1
  availability_zones   = data.aws_availability_zones.available.names

  # Launch template
  launch_template_description = "minimal launch template example"
  create_launch_template      = true
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"

  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}
