module "mixed_instances" {
  #checkov:skip=CKV_AWS_290 "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355 "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source              = "../../"
  name                = var.name
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_id              = local.vpc_id
  vpc_zone_identifier = local.subnet_id
  tags                = var.tags

  # New block for setting up mixed instances policy
  use_mixed_instances_policy = true
  mixed_instances_policy = {
    overrides = [
      {
        instance_type     = "t2.medium"
        weighted_capacity = "2"
      },
      {
        instance_type     = "t2.small"
        weighted_capacity = "1"
      }
    ]

    instances_distribution = {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "capacity-optimized"
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
  launch_template_description = var.description
  update_default_version      = var.update_default_version
  create_launch_template      = var.create_launch_template
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  install_ssm_agent           = var.install_ssm_agent

  # Timeouts
  timeouts = {
    delete = "10m"
  }

#   ebs_optimized = true
}
