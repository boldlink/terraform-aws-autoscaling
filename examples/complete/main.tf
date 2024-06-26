## Autoscaling Group with External Launch Template & External sns
resource "aws_launch_template" "external" {
  #checkov:skip=CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
  name          = "${var.name}-external-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
}

module "sns_topic" {
  source  = "boldlink/sns/aws"
  version = "1.1.2"
  name    = "${var.name}-external-sns"
  tags    = local.tags
}

module "asg_with_external_lt" {
  #checkov:skip=CKV_AWS_260
  #checkov:skip=CKV_AWS_290
  #checkov:skip=CKV_AWS_355
  source                   = "../../"
  name                     = "${var.name}-external-lt"
  min_size                 = 0
  max_size                 = 2
  desired_capacity         = 1
  vpc_zone_identifier      = [local.private_subnets]
  launch_template_id       = aws_launch_template.external.id
  tags                     = var.tags
  depends_on               = [aws_launch_template.external]
  enable_asg_events_notify = true
  topic_arn                = module.sns_topic.arn
}

## Complete Autoscaling Group Example

module "ebs_kms" {
  source           = "boldlink/kms/aws"
  version          = "1.2.0"
  description      = "AWS CMK for encrypting EC2 ebs volumes"
  create_kms_alias = true
  kms_policy       = local.kms_policy
  alias_name       = "alias/${var.name}-key-alias"
  tags             = var.tags
}

resource "aws_placement_group" "main" {
  name     = "${var.name}-pg"
  strategy = "partition"
  tags     = var.tags
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
  force_delete              = true
  default_cooldown          = 300
  termination_policies      = ["OldestInstance", "ClosestToNextInstanceHour"]
  suspended_processes       = ["HealthCheck"]
  placement_group           = aws_placement_group.main.id
  max_instance_lifetime     = 86400
  protect_from_scale_in     = false
  capacity_rebalance        = true
  enable_asg_events_notify  = true
  create_asg_sns_topic      = true
  sns_topic_name            = "${var.name}-topic"
  create_kms_key            = false
  kms_key_id                = module.ebs_kms.arn

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
  launch_template_description     = var.description
  update_default_version          = var.update_default_version
  create_launch_template          = var.create_launch_template
  image_id                        = data.aws_ami.amazon_linux.id
  instance_type                   = var.instance_type
  install_ssm_agent               = var.install_ssm_agent
  additional_role_policy_document = data.aws_iam_policy_document.additional_role_policy_document.json
  create_instance_profile         = true
  install_cloudwatch_agent        = var.install_cloudwatch_agent
  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        volume_size           = 20
        volume_type           = "gp2"
        encrypted             = true
        kms_key_arn           = module.ebs_kms.arn
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

  #tenancy must be host for one to use this
  placement = {
    availability_zone = local.azs
    group_name        = aws_placement_group.main.name
    tenancy           = "default"
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

## Autoscaling Group with custom metrics example
module "custom_metrics" {
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                 = "../../"
  name                   = "${var.name}-custom-metrics"
  min_size               = 1
  max_size               = 3
  desired_capacity       = 1
  vpc_zone_identifier    = [local.private_subnets]
  create_launch_template = true
  instance_type          = "t3.micro"
  image_id               = data.aws_ami.amazon_linux.id
  vpc_id                 = local.vpc_id
  tags                   = merge({ "Name" = "${var.name}-custom-metrics" }, var.tags)

  schedules = {
    night = {
      start_time = "2024-12-15T18:00:00Z"
      end_time   = "2024-12-20T06:00:00Z"
    }
  }

  autoscaling_policy = {

    custom_metrics = {

      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 180

      target_tracking_configuration = {
        target_value = 50.0

        customized_metric_specification = {
          #metric_name = "CustomMetrics" # Conflicts with metrics
          #namespace   = "EC2Custom"
          #statistic   = "Average"
          #unit        = "Count"

          metrics = [
            {
              label = "Get the queue size (the number of messages waiting to be processed)"
              id    = "m1"
              metric_stat = {
                metric = {
                  metric_name = "ApproximateNumberOfMessagesVisible"
                  namespace   = "AWS/SQS"
                  dimensions = [
                    {
                      name  = "QueueName"
                      value = "my-queue"
                    }
                  ]
                }
                stat = "Sum"
              }
              return_data = false
            },
            {
              label = "Get the group size (the number of InService instances)"
              id    = "m2"
              metric_stat = {
                metric = {
                  metric_name = "GroupInServiceInstances"
                  namespace   = "AWS/AutoScaling"
                  dimensions = [
                    {
                      name  = "${var.name}-custom-metrics"
                      value = "my-asg"
                    }
                  ]
                }
                stat = "Average"
              }
              return_data = false #Exactly one element of the metrics list should return data
            },
            {
              label       = "Calculate the backlog per instance"
              id          = "e1"
              expression  = "m1 / m2"
              return_data = true
            }
          ]
        }
      }
    }
  }
}

module "requirements" {
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                     = "../../"
  name                       = "${var.name}-requirements"
  min_size                   = 1
  max_size                   = 3
  desired_capacity           = 1
  desired_capacity_type      = "units"
  vpc_zone_identifier        = [local.private_subnets]
  create_launch_template     = true
  image_id                   = data.aws_ami.amazon_linux.id
  vpc_id                     = local.vpc_id
  use_mixed_instances_policy = true

  mixed_instances_policy = {
    instances_distribution = {
      on_demand_allocation_strategy            = "lowest-price"
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 50
    }

    override = [
      {
        instance_requirements = {
          bare_metal            = "excluded"
          burstable_performance = "excluded"
          cpu_manufacturers     = ["amazon-web-services", "amd", "intel"]
          instance_generations  = ["current"]
          local_storage         = "excluded"

          memory_mib = {
            min = 1024
            max = 8192
          }

          network_interface_count = {
            min = 1
            max = 2
          }

          on_demand_max_price_percentage_over_lowest_price = 10
          require_hibernate_support                        = false
          spot_max_price_percentage_over_lowest_price      = 10

          vcpu_count = {
            min = 1
            max = 5
          }
        }
      }
    ]
  }
}

## Autoscaling Group with Warm Pool example
module "warm_pool" {
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                 = "../../"
  name                   = "${var.name}-warm-pool"
  min_size               = 0
  max_size               = 2
  desired_capacity       = 1
  vpc_zone_identifier    = [local.private_subnets]
  create_launch_template = true
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = "t3.nano"
  vpc_id                 = local.vpc_id

  warm_pool = {
    pool_state                  = "Stopped"
    min_size                    = 2
    max_group_prepared_capacity = 3

    instance_reuse_policy = {
      reuse_on_scale_in = true
    }
  }

  tags = var.tags
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
      max_price          = "0.05"
      spot_instance_type = "one-time"
    }
  }
}

## Autoscaling Group with Accelerators example
module "accelarators" {
  #checkov:skip=CKV_AWS_290 "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355 "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                     = "../../"
  name                       = "${var.name}-accelarators"
  min_size                   = 1
  max_size                   = 3
  desired_capacity           = 1
  desired_capacity_type      = "units"
  vpc_zone_identifier        = [local.private_subnets]
  create_launch_template     = true
  image_id                   = data.aws_ami.amazon_linux.id
  vpc_id                     = local.vpc_id
  use_mixed_instances_policy = true

  mixed_instances_policy = {
    override = [
      {
        instance_requirements = {
          accelerator_count = {
            min = 1
            max = 8
          }

          accelerator_manufacturers = ["amazon-web-services", "amd", "nvidia"]

          accelerator_total_memory_mib = {
            min = 8192
            max = 20480
          }

          accelerator_types = ["gpu", "inference"]
          bare_metal        = "excluded"

          burstable_performance = "excluded"
          cpu_manufacturers     = ["amazon-web-services", "amd", "intel"]

          vcpu_count = {
            min = 4
            max = 8
          }

          memory_mib = {
            min = 8192
            max = 20480
          }
        }
      }
    ]
  }
}
