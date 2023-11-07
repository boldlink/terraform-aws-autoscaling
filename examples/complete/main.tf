module "ebs_kms" {
  source           = "boldlink/kms/aws"
  version          = "1.1.0"
  description      = "AWS CMK for encrypting eks ebs volumes"
  create_kms_alias = true
  kms_policy       = local.kms_policy
  alias_name       = "alias/${var.name}-key-alias"
  tags             = var.tags
}
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
  install_ssm_agent           = var.install_ssm_agent
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
        volume_type           = "gp3"
        encrypted             = true
        iops                  = 300
        throughput            = 200
        kms_key_arn           = module.ebs_kms.arn
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

  metadata_options = {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

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
#mixed
module "mixed_instances" {
  #checkov:skip=CKV_AWS_290 "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355 "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source              = "../../"
  name                = "mixed-instances${var.name}"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_id              = local.vpc_id
  vpc_zone_identifier = local.subnet_id
  tags                = var.tags

  # New block for setting up mixed instances policy
  mixed_instances_policy = {
    overrides = [
      {
        instance_type     = "t2.micro"
        weighted_capacity = "1"
      },
      {
        instance_type     = "t2.small"
        weighted_capacity = "2"
      }
    ]

    instances_distribution = {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 50
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 2
    }
  }

  instance_refresh = {
    strategy = "Rolling"
    triggers = ["tag"]

    preferences = {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }

  # Launch template
  launch_template_description = "Mixed lt"
  update_default_version      = true
  create_launch_template      = true
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  install_ssm_agent           = true

  # Timeouts
  timeouts = {
    create = "10m"
    delete = "10m"
  }

  ebs_optimized = true
}

## Auto Scaling only supports the 'one-time' Spot instance type with no duration
module "spot_one_time" {
  #checkov:skip=CKV_AWS_290 "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355 "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                               = "../../"
  name                                 = "spot-one-time-${var.name}"
  min_size                             = var.min_size
  max_size                             = var.max_size
  desired_capacity                     = var.desired_capacity
  vpc_id                               = local.vpc_id
  vpc_zone_identifier                  = local.subnet_id
  instance_initiated_shutdown_behavior = "terminate"

  instance_refresh = {
    strategy = "Rolling"
    triggers = ["tag"]

    preferences = {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }

  # Launch template
  launch_template_description = "Spot instances lt"
  update_default_version      = true
  create_launch_template      = true
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  install_ssm_agent           = true

  # Timeouts
  timeouts = {
    create = "10m"
    delete = "10m"
  }

  ebs_optimized = true

  instance_market_options = {
    market_type = "spot"
    spot_options = {
      max_price          = "0.04"
      spot_instance_type = "one-time"
    }
  }
}


###complere
resource "aws_placement_group" "main" {
  name     = "${var.name}-pg"
  strategy = "partition"
  tags     = var.tags
}

resource "aws_security_group" "network_interface" {
  name        = "${var.name}-sg"
  description = "${var.name} security group"
  vpc_id      = local.vpc_id
  tags        = var.tags


  egress {
    description      = "Allow egress traffic rule"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#resource "aws_launch_template" "external" {
#  name          = "${var.name}-external-lt"
#  image_id      = "ami-1a2b3c"
#  instance_type = "t3.medium"
#}

resource "aws_ec2_capacity_reservation" "main" {
  instance_type     = "c4.large"
  instance_platform = "Linux/UNIX"
  availability_zone = local.azs
  instance_count    = 1
}

module "enhanced_complete" {
  #checkov:skip=CKV_AWS_88 "EC2 instance should not have public IP."
  source           = "../../"
  name             = "enhanced-${var.name}"
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Role and instance profile configurations
  additional_role_policy_document = data.aws_iam_policy_document.additional_role_policy_document.json

  create_instance_profile = true

  # ASG configurations
  vpc_id                     = local.vpc_id
  capacity_rebalance         = true
  default_cooldown           = 300
  use_mixed_instances_policy = true
  force_delete               = true
  termination_policies       = ["OldestInstance", "ClosestToNextInstanceHour"]
  suspended_processes        = ["HealthCheck"]
  placement_group            = aws_placement_group.main.id
  protect_from_scale_in      = true
  max_instance_lifetime      = 86400

  launch_template_description = "enhanced example launch template"
  update_default_version      = true
  create_launch_template      = true
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "c4.large"
  install_ssm_agent           = true

  # Instance refresh configurations
  instance_refresh = {
    strategy = "Rolling"
    triggers = ["tag"]

    preferences = {
      min_healthy_percentage       = 50
      instance_warmup              = 300
      scale_in_protected_instances = "Ignore"
      skip_matching                = false
      standby_instances            = "Ignore"
    }
  }

  # Timeouts
  timeouts = {
    create = "10m"
    delete = "10m"
  }

  # Launch template configurations
  ebs_optimized = true

  network_interfaces = [
    {
      associate_public_ip_address = true
      delete_on_termination       = true
      description                 = "Primary network interface"
      device_index                = 0
      security_groups             = [aws_security_group.network_interface.id]
      subnet_id                   = local.private_subnets
    }
  ]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
    instance_metadata_tags      = "enabled"
  }

  disable_api_termination = false

  capacity_reservation_specification = {

    capacity_reservation_target = {
      capacity_reservation_id = aws_ec2_capacity_reservation.main.id
    }
  }

  cpu_options = {
    core_count       = 1
    threads_per_core = 2
  }

  enclave_options = {
    enabled = false
  }

  hibernation_options = {
    configured = false
  }

  # Error: creating License Manager License Configuration (Example): AccessDeniedException: Service role not found. Consult setup procedures in License Manager User Guide and create the required role for the service.
  #license_specifications = [
  #  {
  #    license_configuration_arn = aws_licensemanager_license_configuration.main.arn
  #  }
  #]

  placement = {
    #affinity          = "default" #tenancy must be host for one to use this
    availability_zone = local.azs
    group_name        = aws_placement_group.main.name
    #host_id           = "h-0123456789abcdef0"
    #spread_domain     = "d-0123456789abcdef0"
    tenancy = "default"
  }

  schedules = {
    night = {
      start_time = "2024-12-15T18:00:00Z"
      end_time   = "2024-12-20T06:00:00Z"
    }
  }

  # SNS notifications
  sns_notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
  ]
}
