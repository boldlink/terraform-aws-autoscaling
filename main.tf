locals {
  launch_template_name    = coalesce(var.launch_template_name, var.name)
  launch_template         = var.launch_template_name == null ? join("", aws_launch_template.main.*.name) : var.launch_template_name
  launch_template_version = var.launch_template_version == null ? join("", aws_launch_template.main.*.latest_version) : var.launch_template_version
}
############################
### Cloudwatch resources
############################
resource "aws_cloudwatch_log_group" "main" {
  count = var.enable_monitoring ? 1 : 0
  name  = "/aws/asg/${var.name}"
  tags = merge(
    {
      "Name"        = var.name
      "Environment" = var.tag_env
    },
    var.other_tags,
  )
}

resource "tls_private_key" "main" {
  count     = var.create_key_pair ? 1 : 0
  algorithm = var.ssh_key_algorithm
  rsa_bits  = var.rsa_bits
}

resource "aws_key_pair" "main" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.name
  public_key = join("", tls_private_key.main.*.public_key_openssh)
}

############################
### IAM Resources
############################
resource "aws_iam_instance_profile" "main" {
  name = "${var.name}_iam_role"
  path = var.iam_role_path
  role = aws_iam_role.main.name
}

resource "aws_iam_role" "main" {
  description        = "${var.name} ASG Group IAM Role"
  name               = "${var.name}.iam_role"
  path               = var.iam_role_path
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "main" {
  name        = "${var.name}.iam_pol"
  description = "${var.name} ASG Group IAM policy"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.asg.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

############################
### Security Group
############################
resource "aws_security_group" "main" {
  name        = var.name
  description = "${var.name} ASG Group Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    {
      "Name"        = var.name
      "Environment" = var.tag_env
    },
    var.other_tags,
  )
}

resource "aws_security_group_rule" "main" {
  for_each                 = var.security_group_rules
  security_group_id        = aws_security_group.main.id
  description              = "Additional rules to add to the security group"
  from_port                = lookup(each.value, "from_port", null)
  to_port                  = lookup(each.value, "to_port", null)
  protocol                 = lookup(each.value, "protocol", "tcp")
  type                     = lookup(each.value, "type", null)
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

############################
### ASG resources
############################
resource "aws_autoscaling_group" "main" {
  name                 = var.name
  name_prefix          = var.name_prefix
  max_size             = var.max_size
  min_size             = var.min_size
  availability_zones   = var.availability_zones
  capacity_rebalance   = var.capacity_rebalance
  default_cooldown     = var.default_cooldown
  launch_configuration = var.launch_configuration

  dynamic "launch_template" {
    for_each = var.use_mixed_instances_policy ? [] : [1]

    content {
      name    = local.launch_template
      version = local.launch_template_version
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = var.use_mixed_instances_policy ? [var.mixed_instances_policy] : []
    content {
      dynamic "instances_distribution" {
        for_each = lookup(mixed_instances_policy.value, "instances_distribution", [])
        content {
          on_demand_allocation_strategy            = lookup(instances_distribution.value, "on_demand_allocation_strategy", null)
          on_demand_base_capacity                  = lookup(instances_distribution.value, "on_demand_base_capacity", null)
          on_demand_percentage_above_base_capacity = lookup(instances_distribution.value, "on_demand_percentage_above_base_capacity", null)
          spot_allocation_strategy                 = lookup(instances_distribution.value, "spot_allocation_strategy", null)
          spot_instance_pools                      = lookup(instances_distribution.value, "spot_instance_pools", null)
          spot_max_price                           = lookup(instances_distribution.value, "spot_max_price", null)
        }
      }

      launch_template {
        launch_template_specification {
          launch_template_name = local.launch_template
          version              = local.launch_template_version
        }

        dynamic "override" {
          for_each = lookup(mixed_instances_policy.value, "override", [])
          content {
            instance_type     = lookup(override.value, "instance_type", null)
            weighted_capacity = lookup(override.value, "weighted_capacity", null)

            dynamic "launch_template_specification" {
              for_each = lookup(override.value, "launch_template_specification", [])
              content {
                launch_template_id = lookup(launch_template_specification.value, "launch_template_id", null)
              }
            }
          }
        }
      }
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.initial_lifecycle_hooks
    content {
      name                    = initial_lifecycle_hook.value.name
      default_result          = lookup(initial_lifecycle_hook.value, "default_result", null)
      heartbeat_timeout       = lookup(initial_lifecycle_hook.value, "heartbeat_timeout", null)
      lifecycle_transition    = initial_lifecycle_hook.value.lifecycle_transition
      notification_metadata   = lookup(initial_lifecycle_hook.value, "notification_metadata", null)
      notification_target_arn = lookup(initial_lifecycle_hook.value, "notification_target_arn", null)
      role_arn                = lookup(initial_lifecycle_hook.value, "role_arn", null)
    }
  }

  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  desired_capacity          = var.desired_capacity
  force_delete              = var.force_delete
  load_balancers            = var.load_balancers
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = var.target_group_arns
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group           = var.placement_group
  metrics_granularity       = var.metrics_granularity
  enabled_metrics           = var.enabled_metrics
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  min_elb_capacity          = var.min_elb_capacity
  wait_for_elb_capacity     = var.wait_for_elb_capacity
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn
  max_instance_lifetime     = var.max_instance_lifetime

  dynamic "instance_refresh" {
    for_each = length(var.instance_refresh) > 0 ? [var.instance_refresh] : []
    content {
      strategy = instance_refresh.value.strategy
      dynamic "preferences" {
        for_each = try([instance_refresh.value.preferences], [])
        content {
          checkpoint_delay       = try(preferences.value.checkpoint_delay, null)
          checkpoint_percentages = try(preferences.value.checkpoint_percentages, null)
          instance_warmup        = try(preferences.value.instance_warmup, null)
          min_healthy_percentage = try(preferences.value.min_healthy_percentage, null)
        }
      }
      triggers = try(instance_refresh.value.triggers, null)
    }
  }

  dynamic "warm_pool" {
    for_each = length(var.warm_pool) > 0 ? [var.warm_pool] : []
    content {
      pool_state = lookup(warm_pool.value, "pool_state", null)
      min_size   = lookup(warm_pool.value, "min_size", null)
      dynamic "instance_reuse_policy" {
        for_each = lookup(warm_pool.value, "instance_reuse_policy", [])
        content {
          reuse_on_scale_in = lookup(instance_reuse_policy.value, "reuse_on_scale_in", null)
        }
      }
    }
  }

  timeouts {
    delete = lookup(var.timeouts, "delete", "10m")
  }

  dynamic "tag" {
    for_each = var.tag
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

#####################################
### Launch Template
#####################################
resource "aws_launch_template" "main" {
  count                                = var.create_launch_template ? 1 : 0
  name                                 = var.launch_template_name
  name_prefix                          = var.launch_template_name_prefix
  description                          = var.launch_template_description
  ebs_optimized                        = var.ebs_optimized
  image_id                             = var.image_id
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  user_data                            = var.enable_monitoring ? base64encode(data.template_cloudinit_config.config.rendered) : var.user_data
  vpc_security_group_ids               = length(var.network_interfaces) > 0 ? [] : var.security_group_ids
  default_version                      = var.default_version
  update_default_version               = var.update_default_version
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  kernel_id                            = var.kernel_id
  ram_disk_id                          = var.ram_disk_id

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = try(block_device_mappings.value.no_device, null)
      virtual_name = try(block_device_mappings.value.virtual_name, null)

      dynamic "ebs" {
        for_each = flatten([try(block_device_mappings.value.ebs, [])])
        content {
          delete_on_termination = try(ebs.value.delete_on_termination, null)
          encrypted             = try(ebs.value.encrypted, null)
          kms_key_id            = try(ebs.value.kms_key_id, null)
          iops                  = try(ebs.value.iops, null)
          throughput            = try(ebs.value.throughput, null)
          snapshot_id           = try(ebs.value.snapshot_id, null)
          volume_size           = try(ebs.value.volume_size, null)
          volume_type           = try(ebs.value.volume_type, null)
        }
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = length(var.capacity_reservation_specification) > 0 ? [var.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = try(capacity_reservation_specification.value.capacity_reservation_preference, null)

      dynamic "capacity_reservation_target" {
        for_each = try([capacity_reservation_specification.value.capacity_reservation_target], [])
        content {
          capacity_reservation_id                 = try(capacity_reservation_target.value.capacity_reservation_id, null)
          capacity_reservation_resource_group_arn = try(capacity_reservation_target.value.capacity_reservation_resource_group_arn, null)
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = length(var.cpu_options) > 0 ? [var.cpu_options] : []
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = length(var.credit_specification) > 0 ? [var.credit_specification] : []
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  dynamic "elastic_gpu_specifications" {
    for_each = length(var.elastic_gpu_specifications) > 0 ? [var.elastic_gpu_specifications] : []
    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = length(var.elastic_inference_accelerator) > 0 ? [var.elastic_inference_accelerator] : []
    content {
      type = elastic_inference_accelerator.value.type
    }
  }

  dynamic "enclave_options" {
    for_each = length(var.enclave_options) > 0 ? [var.enclave_options] : []
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = length(var.hibernation_options) > 0 ? [var.hibernation_options] : []
    content {
      configured = hibernation_options.value.configured
    }
  }

  dynamic "instance_market_options" {
    for_each = length(var.instance_market_options) > 0 ? [var.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = try([instance_market_options.value.spot_options], [])
        content {
          block_duration_minutes         = try(spot_options.value.block_duration_minutes, null)
          instance_interruption_behavior = try(spot_options.value.instance_interruption_behavior, null)
          max_price                      = try(spot_options.value.max_price, null)
          spot_instance_type             = try(spot_options.value.spot_instance_type, null)
          valid_until                    = try(spot_options.value.valid_until, null)
        }
      }
    }
  }

  dynamic "license_specification" {
    for_each = length(var.license_specifications) > 0 ? [var.license_specifications] : []
    content {
      license_configuration_arn = license_specifications.value.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", null)
      http_tokens                 = lookup(metadata_options.value, "http_tokens", null)
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
      http_protocol_ipv6          = lookup(metadata_options.value, "http_protocol_ipv6", null)
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_carrier_ip_address = lookup(network_interfaces.value, "associate_carrier_ip_address", null)
      associate_public_ip_address  = lookup(network_interfaces.value, "associate_public_ip_address", null)
      delete_on_termination        = lookup(network_interfaces.value, "delete_on_termination", null)
      description                  = lookup(network_interfaces.value, "description", null)
      device_index                 = lookup(network_interfaces.value, "device_index", null)
      interface_type               = lookup(network_interfaces.value, "interface_type", null)
      ipv4_prefix_count            = lookup(network_interfaces.value, "ipv4_prefix_count", null)
      ipv4_prefixes                = lookup(network_interfaces.value, "ipv4_prefixes", null)
      ipv4_addresses               = lookup(network_interfaces.value, "ipv4_addresses", null) != null ? network_interfaces.value.ipv4_addresses : []
      ipv4_address_count           = lookup(network_interfaces.value, "ipv4_address_count", null)
      ipv6_prefix_count            = lookup(network_interfaces.value, "ipv6_prefix_count", null)
      ipv6_prefixes                = lookup(network_interfaces.value, "ipv6_prefixes", [])
      ipv6_addresses               = lookup(network_interfaces.value, "ipv6_addresses", null) != null ? network_interfaces.value.ipv6_addresses : []
      ipv6_address_count           = lookup(network_interfaces.value, "ipv6_address_count", null)
      network_interface_id         = lookup(network_interfaces.value, "network_interface_id", null)
      network_card_index           = lookup(network_interfaces.value, "network_card_index", null)
      private_ip_address           = lookup(network_interfaces.value, "private_ip_address", null)
      security_groups              = lookup(network_interfaces.value, "security_groups", null) != null ? network_interfaces.value.security_groups : []
      subnet_id                    = lookup(network_interfaces.value, "subnet_id", null)
    }
  }

  dynamic "placement" {
    for_each = length(var.placement) > 0 ? [var.placement] : []
    content {
      affinity                = lookup(placement.value, "affinity", null)
      availability_zone       = lookup(placement.value, "availability_zone", null)
      group_name              = lookup(placement.value, "group_name", null)
      host_id                 = lookup(placement.value, "host_id", null)
      host_resource_group_arn = lookup(placement.value, "host_resource_group_arn", null)
      spread_domain           = lookup(placement.value, "spread_domain", null)
      tenancy                 = lookup(placement.value, "tenancy", null)
      partition_number        = lookup(placement.value, "partition_number", null)
    }
  }

  dynamic "private_dns_name_options" {
    for_each = length(var.private_dns_name_options) > 0 ? [var.private_dns_name_options] : []
    content {
      enable_resource_name_dns_aaaa_record = lookup(private_dns_name_options.value, "enable_resource_name_dns_aaaa_record", null)
      enable_resource_name_dns_a_record    = lookup(private_dns_name_options.value, "enable_resource_name_dns_a_record", null)
      hostname_type                        = private_dns_name_options.value.hostname_type
    }
  }

  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags = merge(
        {
          "Name"        = var.name
          "Environment" = var.tag_env
        },
      )
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_schedule" "main" {
  for_each               = var.schedules
  scheduled_action_name  = each.key
  autoscaling_group_name = aws_autoscaling_group.main.name
  min_size               = lookup(each.value, "min_size", null)
  max_size               = lookup(each.value, "max_size", null)
  desired_capacity       = lookup(each.value, "desired_capacity", null)
  start_time             = lookup(each.value, "start_time", null)
  end_time               = lookup(each.value, "end_time", null)
  time_zone              = lookup(each.value, "time_zone", null)
  recurrence             = lookup(each.value, "recurrence", null)
  # Syntax=>>[Minute] [Hour] [Day_of_Month] [Month_of_Year] [Day_of_Week]
}

########################################
## Autoscaling Policies Resources
## Bellow are the resources to trigger autoscaling events and report to an email address (default)
########################################
resource "aws_autoscaling_policy" "main" {
  for_each                  = var.autoscaling_policy
  name                      = try(each.value.name, each.key)
  autoscaling_group_name    = aws_autoscaling_group.main.name
  adjustment_type           = lookup(each.value, "adjustment_type", null)
  policy_type               = lookup(each.value, "policy_type", null)
  estimated_instance_warmup = lookup(each.value, "estimated_instance_warmup", null)
  min_adjustment_magnitude  = lookup(each.value, "min_adjustment_magnitude", null)
  cooldown                  = lookup(each.value, "cooldown", null)
  scaling_adjustment        = lookup(each.value, "scaling_adjustment", null)
  metric_aggregation_type   = lookup(each.value, "metric_aggregation_type", null)

  dynamic "step_adjustment" {
    for_each = lookup(each.value, "step_adjustment", [])
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = lookup(step_adjustment.value, "metric_interval_lower_bound", null)
      metric_interval_upper_bound = lookup(step_adjustment.value, "metric_interval_upper_bound", null)
    }
  }

  dynamic "target_tracking_configuration" {
    for_each = try([each.value.target_tracking_configuration], [])
    content {
      target_value     = target_tracking_configuration.value.target_value
      disable_scale_in = try(target_tracking_configuration.value.disable_scale_in, null)

      dynamic "predefined_metric_specification" {
        for_each = try([target_tracking_configuration.value.predefined_metric_specification], [])
        content {
          predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
        }
      }

      dynamic "customized_metric_specification" {
        for_each = try([target_tracking_configuration.value.customized_metric_specification], [])
        content {

          dynamic "metric_dimension" {
            for_each = try([customized_metric_specification.value.metric_dimension], [])
            content {
              name  = try(metric_dimension.value.name, null)
              value = try(metric_dimension.value.value, null)
            }
          }

          metric_name = customized_metric_specification.value.metric_name
          namespace   = customized_metric_specification.value.namespace
          statistic   = customized_metric_specification.value.statistic
          unit        = try(customized_metric_specification.value.unit, null)
        }
      }
    }
  }

  dynamic "predictive_scaling_configuration" {
    for_each = try([each.value.predictive_scaling_configuration], [])
    content {
      max_capacity_breach_behavior = try(predictive_scaling_configuration.value.max_capacity_breach_behavior, null)
      max_capacity_buffer          = try(predictive_scaling_configuration.value.max_capacity_buffer, null)
      mode                         = try(predictive_scaling_configuration.value.mode, null)
      scheduling_buffer_time       = try(predictive_scaling_configuration.value.scheduling_buffer_time, null)

      dynamic "metric_specification" {
        for_each = try([predictive_scaling_configuration.value.metric_specification], [])
        content {
          target_value = metric_specification.value.target_value

          dynamic "predefined_load_metric_specification" {
            for_each = try([metric_specification.value.predefined_load_metric_specification], [])
            content {
              predefined_metric_type = predefined_load_metric_specification.value.predefined_metric_type
              resource_label         = predefined_load_metric_specification.value.resource_label
            }
          }

          dynamic "predefined_metric_pair_specification" {
            for_each = try([metric_specification.value.predefined_metric_pair_specification], [])
            content {
              predefined_metric_type = predefined_metric_pair_specification.value.predefined_metric_type
              resource_label         = predefined_metric_pair_specification.value.resource_label
            }
          }

          dynamic "predefined_scaling_metric_specification" {
            for_each = try([metric_specification.value.predefined_scaling_metric_specification], [])
            content {
              predefined_metric_type = predefined_scaling_metric_specification.value.predefined_metric_type
              resource_label         = predefined_scaling_metric_specification.value.resource_label
            }
          }
        }
      }
    }
  }
}

resource "aws_autoscaling_notification" "main" {
  group_names = [
    aws_autoscaling_group.main.name,
  ]

  notifications = var.sns_notifications
  topic_arn     = aws_sns_topic.main.arn
}

resource "aws_sns_topic" "main" {
  name              = var.sns_topic_name
  kms_master_key_id = var.sns_kms_master_key_id
}
