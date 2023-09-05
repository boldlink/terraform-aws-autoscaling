module "complete" {
  #checkov:skip=CKV_AWS_260
  #checkov:skip=CKV_AWS_290
  #checkov:skip=CKV_AWS_355
  source                    = "../../"
  name                      = var.name
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  health_check_type         = var.health_check_type
  vpc_zone_identifier       = local.subnet_id

  initial_lifecycle_hooks = [
    {
      name                 = "LaunchHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 90
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode(
        {
          Launching = "Dev"
        }
      )
    },
    {
      name                 = "TermHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 180
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_metadata = jsonencode(
        {
          Terminating = "Dev"
        }
      )
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 3600
      checkpoint_percentages = [25, 50, 100]
      instance_warmup        = 180
      min_healthy_percentage = 100
    }
    triggers = ["tag"]
  }

  ### vpc for security group
  vpc_id = local.vpc_id

  ## security group: Additional rules.
  ## Note ports 80 and 443 need to be open to allow downloading packages
  security_group_ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
    }
  ]

  security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Launch template
  launch_template_description = var.description
  update_default_version      = var.update_default_version
  create_launch_template      = var.create_launch_template
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  install_cloudwatch_agent    = var.install_cloudwatch_agent
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
    },
    {
      device_name = "/dev/sda1"
      no_device   = 1
      ebs = {
        delete_on_termination = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]
  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      subnet_id             = local.private_subnets
    }
  ]

  placement = {
    availability_zone = local.azs
  }

  tags = local.tags

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

  # Autoscaling Schedule
  schedules = {
    night = {
      min_size         = 0
      max_size         = 0
      desired_capacity = 0
      recurrence       = "0 18 * * 1-5" # Mon-Fri in the evening
      time_zone        = "GMT"
    }

    morning = {
      min_size         = 0
      max_size         = 1
      desired_capacity = 1
      recurrence       = "0 7 * * 1-5" # Mon-Fri in the morning
      time_zone        = "GMT"
    }
  }
  # Target scaling policy schedule based on average CPU load
  autoscaling_policy = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 180
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    },
    predictive-scaling = {
      policy_type = "PredictiveScaling"
      predictive_scaling_configuration = {
        mode                         = "ForecastAndScale"
        scheduling_buffer_time       = 10
        max_capacity_breach_behavior = "IncreaseMaxCapacity"
        max_capacity_buffer          = 10
        metric_specification = {
          target_value = 32
          predefined_scaling_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
            resource_label         = "testLabel"
          }
          predefined_load_metric_specification = {
            predefined_metric_type = "ASGTotalCPUUtilization"
            resource_label         = "testLabel"
          }
        }
      }
    }
  }
}
