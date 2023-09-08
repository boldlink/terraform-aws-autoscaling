variable "name" {
  type        = string
  description = "(Optional) The name of the Auto Scaling Group. By default generated by Terraform. Conflicts with `name_prefix`"
  default     = null
}

variable "name_prefix" {
  type        = string
  description = "(Optional) Creates a unique name beginning with the specified prefix. Conflicts with `name`."
  default     = null
}

variable "max_size" {
  type        = number
  description = "(Required) The maximum size of the Auto Scaling Group."
}

variable "min_size" {
  type        = number
  description = "(Required) The minimum size of the Auto Scaling Group."
}

variable "user_data" {
  type        = string
  description = "The user data to use when creating instances"
  default     = null
}

variable "install_ssm_agent" {
  type        = bool
  description = "Whether to install ssm agent"
  default     = false
}

## For external launch template, i.e launch template not created by this module
variable "external_launch_template_name" {
  type        = string
  description = "The name of the external launch template"
  default     = null
}

variable "external_launch_template_version" {
  type        = string
  description = "The version of the external launch template"
  default     = null
}

variable "availability_zones" {
  type        = list(string)
  description = "(Optional) A list of one or more availability zones for the group. Used for EC2-Classic, attaching a network interface via id from a launch template and default subnets when not specified with `vpc_zone_identifier` argument. Conflicts with `vpc_zone_identifier`."
  default     = null
}

variable "capacity_rebalance" {
  type        = bool
  description = "(Optional) Indicates whether capacity rebalance is enabled. Otherwise, capacity rebalance is disabled."
  default     = false
}

variable "default_cooldown" {
  type        = number
  description = "(Optional) The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
  default     = null
}

variable "use_mixed_instances_policy" {
  type        = bool
  description = "Choose whether to use mixed instances policy block"
  default     = false
}

variable "launch_configuration" {
  type        = string
  description = "(Optional) The name of the launch configuration to use."
  default     = null
}

variable "mixed_instances_policy" {
  type        = any
  description = "(Optional) Configuration block containing settings to define launch targets for Auto Scaling groups."
  default     = {}
}

variable "initial_lifecycle_hooks" {
  type        = list(map(string))
  description = "(Optional) One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched."
  default     = []
}

variable "health_check_grace_period" {
  type        = number
  description = "(Optional, Default: 300) Time (in seconds) after instance comes into service before checking health."
  default     = 300
}

variable "health_check_type" {
  type        = string
  description = "(Optional) \"EC2\" or \"ELB\". Controls how health checking is done."
  default     = null
}

variable "desired_capacity" {
  type        = number
  description = "(Optional) The number of Amazon EC2 instances that should be running in the group."
  default     = null
}

variable "force_delete" {
  type        = bool
  description = "(Optional) Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate. You can force an Auto Scaling Group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling."
  default     = null
}

variable "load_balancers" {
  type        = list(string)
  description = "(Optional) A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead."
  default     = []
}

variable "vpc_zone_identifier" {
  type        = list(string)
  description = "(Optional) A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`."
  default     = null
}

variable "target_group_arns" {
  type        = list(string)
  description = "(Optional) A set of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancing."
  default     = []
}

variable "termination_policies" {
  type        = list(string)
  description = "(Optional) A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default`."
  default     = ["Default"]
}

variable "suspended_processes" {
  type        = list(string)
  description = "(Optional) A list of processes to suspend for the Auto Scaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the Launch or Terminate process types, it can prevent your Auto Scaling Group from functioning properly."
  default     = []
}

variable "placement_group" {
  type        = string
  description = "(Optional) The name of the placement group into which you'll launch your instances, if any."
  default     = null
}

variable "metrics_granularity" {
  type        = string
  description = "(Optional) The granularity to associate with the metrics to collect. The only valid value is `1Minute`. Default is `1Minute`."
  default     = "1Minute"
}

variable "enabled_metrics" {
  type        = list(string)
  description = "A list of metrics to collect."
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "wait_for_capacity_timeout" {
  type        = string
  description = "(Default: \"10m\") A maximum duration that Terraform should wait for ASG instances to be healthy before timing out."
  default     = "1m"
}

variable "min_elb_capacity" {
  type        = number
  description = "(Optional) Setting this causes Terraform to wait for this number of instances from this Auto Scaling Group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes."
  default     = null
}

variable "wait_for_elb_capacity" {
  type        = number
  description = "(Optional) Setting this will cause Terraform to wait for exactly this number of healthy instances from this Auto Scaling Group in all attached load balancers on both create and update operations. (Takes precedence over `min_elb_capacity` behavior.) "
  default     = null
}

variable "protect_from_scale_in" {
  type        = bool
  description = "(Optional) Allows setting instance protection. The Auto Scaling Group will not select instances with this setting for termination during scale in events."
  default     = null
}

variable "service_linked_role_arn" {
  type        = string
  description = "(Optional) The ARN of the service-linked role that the ASG will use to call other AWS services"
  default     = null
}

variable "max_instance_lifetime" {
  type        = number
  description = "(Optional) The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 86400 and 31536000 seconds."
  default     = null
}

variable "launch_template_version" {
  type        = string
  description = "The version of the launch template"
  default     = "$Latest"
}

variable "instance_refresh" {
  type        = any
  description = "(Optional) If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated."
  default     = {}
}

variable "warm_pool" {
  type        = map(string)
  description = "(Optional) If this block is configured, add a Warm Pool to the specified Auto Scaling group."
  default     = {}
}

variable "tag" {
  type        = map(string)
  description = "(Optional) Configuration block(s) containing resource tags."
  default     = {}
}

variable "schedules" {
  type        = map(any)
  description = "Schedules configuration block"
  default     = {}
}

variable "timeouts" {
  type        = map(string)
  description = "Configuration block for autoscaling delete time"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to launch resources in"
  default     = null
}

variable "enable_monitoring" {
  type        = bool
  description = "Choose whether to enable monotoring"
  default     = false
}

variable "create_launch_template" {
  type        = bool
  description = "Specify whether to create launch template"
  default     = false
}

variable "launch_template_name_prefix" {
  type        = string
  description = "(Optional) Creates a unique name beginning with the specified prefix. Conflicts with name"
  default     = null
}

variable "launch_template_description" {
  type        = string
  description = "(Optional) Description of the launch template."
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs to associate."
  default     = []
}

variable "ebs_optimized" {
  type        = bool
  description = "(Optional) If true, the launched EC2 instance will be EBS-optimized."
  default     = false
}

variable "image_id" {
  type        = string
  description = "(Optional) The AMI from which to launch the instance."
  default     = null
}

variable "instance_type" {
  type        = string
  description = "(Optional) The type of the instance."
  default     = null
}

variable "default_version" {
  type        = number
  description = "(Optional) Default Version of the launch template."
  default     = null
}

variable "update_default_version" {
  type        = bool
  description = "(Optional) Whether to update Default Version each update. Conflicts with `default_version`."
  default     = null
}

variable "disable_api_termination" {
  type        = bool
  description = "(Optional) If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  description = "(Optional) Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`)."
  default     = "stop"
}

variable "kernel_id" {
  type        = string
  description = "(Optional) The kernel ID."
  default     = null
}

variable "ram_disk_id" {
  type        = string
  description = "(Optional) The ID of the RAM disk."
  default     = null
}

variable "block_device_mappings" {
  type        = list(any)
  description = "The storage device mapping block"
  default     = []
}

variable "capacity_reservation_specification" {
  type        = map(string)
  description = "(Optional) Targeting for EC2 capacity reservations."
  default     = {}
}

variable "cpu_options" {
  type        = map(string)
  description = "(Optional) The CPU options for the instance."
  default     = {}
}

variable "credit_specification" {
  type        = map(string)
  description = "(Optional) Customize the credit specification of the instance."
  default     = {}
}

variable "elastic_gpu_specifications" {
  type        = map(string)
  description = "(Optional) The elastic GPU to attach to the instance."
  default     = {}
}

variable "elastic_inference_accelerator" {
  type        = map(string)
  description = "(Optional) Configuration block containing an Elastic Inference Accelerator to attach to the instance."
  default     = {}
}

variable "enclave_options" {
  type        = map(string)
  description = "(Optional) Enable Nitro Enclaves on launched instances."
  default     = {}
}

variable "hibernation_options" {
  type        = map(string)
  description = "The hibernation options for the instance"
  default     = {}
}

variable "instance_market_options" {
  type        = map(string)
  description = "(Optional) The market (purchasing) option for the instance."
  default     = {}
}

variable "license_specifications" {
  type        = map(string)
  description = "(Optional) A list of license specifications to associate with."
  default     = {}
}

variable "metadata_options" {
  type        = map(string)
  description = "(Optional) Customize the metadata options for the instance."
  default     = {}
}

variable "network_interfaces" {
  type        = any
  description = "(Optional) Customize network interfaces to be attached at instance boot time."
  default     = []
}

variable "create_instance_profile" {
  type        = bool
  description = "Specify whether to create instance profile using the module."
  default     = true
}

variable "iam_instance_profile" {
  type        = string
  description = "Provide an iam_instance_profile for the instances to be created."
  default     = null
}

variable "install_cloudwatch_agent" {
  type        = bool
  description = "Specify whether to have cloudwatch agent installed in created instances"
  default     = false
}

variable "additional_role_policy_document" {
  type        = string
  description = "Additional policy document to add to the created IAM role."
  default     = null
}

variable "placement" {
  type        = map(string)
  description = "(Optional) The placement of the instance."
  default     = {}
}

variable "private_dns_name_options" {
  type        = map(string)
  description = "(Optional) The options for the instance hostname. The default values are inherited from the subnet."
  default     = {}
}

variable "tag_specifications" {
  type        = list(any)
  description = "(Optional) The tags to apply to the resources during launch."
  default     = []
}

variable "security_group_ingress" {
  type        = any
  description = "The rules block for defining additional ingress rules"
  default     = []
}

variable "security_group_egress" {
  type        = any
  description = "The rules block for defining additional egress rules"
  default     = []
}

variable "autoscaling_policy" {
  type        = any
  description = "The configuration block for various autoscaling policies"
  default     = {}
}

variable "enable_key_rotation" {
  description = "Choose whether to enable key rotation"
  type        = bool
  default     = true
}

variable "key_deletion_window_in_days" {
  description = "The number of days before the key is deleted"
  type        = number
  default     = 7
}

variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  default     = 1827
}

variable "iam_role_path" {
  type        = string
  description = "The path for the iam role"
  default     = "/"
}

variable "extra_script" {
  type        = string
  description = "The name of the extra script"
  default     = ""
}

##############
###Alarms
##############
variable "sns_notifications" {
  type        = list(string)
  description = "(Required) A list of Notification Types that trigger notifications."
  default = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
}

variable "sns_topic_name" {
  type        = string
  description = "The name of the sns topic"
  default     = null
}

variable "sns_kms_master_key_id" {
  type        = string
  description = "The kms key to use for encrypting sns topic"
  default     = "alias/aws/sns"
}

###############
#### Tags
###############
variable "tags" {
  description = "Provide the tags for the resources"
  type        = map(string)
  default     = {}
}
