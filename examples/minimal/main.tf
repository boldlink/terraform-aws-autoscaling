locals {
  name = "boldlink-auto-scaling"
}

resource "random_pet" "main" {
  length = 2
}

module "minimal" {
  #source = "boldlink/autoscaling/aws"
  source = "../../"

  ## Autoscaling group
  name                      = "${local.name}-${random_pet.main.id}"
  launch_template_name      = "${local.name}-${random_pet.main.id}"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  availability_zones        = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  ## security group: Additional rules
  security_group_rules = {
    ingress_http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    custom = {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
  }

  # Launch template
  launch_template_description = "minimal launch template example"
  update_default_version      = true
  create_launch_template      = true
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  ebs_optimized               = true

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        volume_size           = 20
        volume_type           = "gp2"
      }
      }, {
      device_name = "/dev/sda1"
      no_device   = 1
      ebs = {
        delete_on_termination = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]

  tag = {
    Name        = "${local.name}-${random_pet.main.id}"
    Environment = "dev"
  }
}
