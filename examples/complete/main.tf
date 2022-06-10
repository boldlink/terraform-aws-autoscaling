locals {
  name = "complete-example"
}

module "complete" {
  source = "../../"

  ## Autoscaling group
  name                      = local.name
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  availability_zones        = [data.aws_availability_zones.available.names[0]]

  initial_lifecycle_hooks = [
    {
      name                 = "LaunchHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 90
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode(
        {
          Greetings = "Dev"
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
          Terminating = "Env"
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
  launch_template_description = "Complete launch template example"
  launch_template_name        = local.name
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
      subnet_id             = data.aws_subnet.default.id
    },
    {
      delete_on_termination = true
      description           = "eth1"
      device_index          = 1
      subnet_id             = data.aws_subnet.default.id
    }
  ]

  cpu_options = {
    core_count       = 1
    threads_per_core = 1
  }

  credit_specification = {
    cpu_credits = "standard"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
    instance_metadata_tags      = "enabled"
  }

  placement = {
    availability_zone = data.aws_availability_zones.available.names[0]
  }

  tag = {
    Name        = "complete-example"
    Environment = "dev"
  }

  # Autoscaling Schedule
  schedules = {
    night = {
      min_size         = 0
      max_size         = 0
      desired_capacity = 0
      recurrence       = "0 18 * * 1-5" # Mon-Fri in the evening
      time_zone        = "Africa/Nairobi"
    }

    morning = {
      min_size         = 0
      max_size         = 1
      desired_capacity = 1
      recurrence       = "0 7 * * 1-5" # Mon-Fri in the morning
      time_zone        = "Africa/Nairobi"
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
