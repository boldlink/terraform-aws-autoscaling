[![License](https://img.shields.io/badge/License-Apache-blue.svg)](https://github.com/boldlink/terraform-aws-autoscaling/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/release/boldlink/terraform-aws-autoscaling.svg)](https://github.com/boldlink/terraform-aws-autoscaling/releases/latest)
[![Build Status](https://github.com/boldlink/terraform-aws-autoscaling/actions/workflows/update.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-autoscaling/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-autoscaling/actions/workflows/release.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-autoscaling/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-autoscaling/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-autoscaling/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-autoscaling/actions/workflows/pr-labeler.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-autoscaling/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-autoscaling/actions/workflows/module-examples-tests.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-autoscaling/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-autoscaling/actions/workflows/checkov.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-autoscaling/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-autoscaling/actions/workflows/auto-merge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-autoscaling/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-autoscaling/actions/workflows/auto-badge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-autoscaling/actions)

[<img src="https://avatars.githubusercontent.com/u/25388280?s=200&v=4" width="96"/>](https://boldlink.io)

# AWS Autoscaling Terraform module

## Description
This module creates the resources needed to deploy and monitor autoscaled EC2 instances in AWS.

### Why choose this module over the standard resources
- Follows aws security best practices and uses checkov to ensure compliance.
- Has elaborate examples that you can use to setup your ec2 instance within a very short time.
- This module includes a feature to install ssm agent and gives the necessary permissions for the instances to communicate with SSM manager.
- As of [2.0.0] we no longer support or enable SSH keys on the instances, this is aligned with AWS best practices. As an alternative you should use Session Mananger which providers support to login to the Ec2 Linux and Windows (read below for instructions)
- This module has full support for Linux instances. Windows support will be added in a future release

Examples available [here](./examples)

## Connecting to Instances
- Use SSM Manager CLI to connect to instance Linux and Windows ec2 instances.
- **NOTE:** It's crucial to configure the security group outbound rules to allow all traffic to any destination (`0.0.0.0/0`). This is necessary because the instance requires the capability to send requests for downloading packages.

### Using AWS CLI to start Systems Manager Session
- Make sure you have the Session Manager plugin installed on your system. For installation instructions, refer to the guide [here](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
- Run the following command to start session from your terminal
```console
aws ssm start-session \
    --target "<instance_id>"
```
Replace `<instance_id>` with the ID of the instance you want to connect to

## Launching in Private Subnets without NAT Gateways or internet connection
To manage instances in isolated subnets without internet connectivity, it is necessary to enable VPC endpoints for specific services, including:
- `com.amazonaws.[region].ssm`
- `com.amazonaws.[region].ec2messages`
- `com.amazonaws.[region].ssmmessages`
- `(optional) com.amazonaws.[region].kms for KMS encryption in Session Manager`

You can use Boldlink VPC Endpoints Terraform module [here](https://github.com/boldlink/terraform-aws-vpc-endpoints/tree/main/examples)

## Usage
*NOTE*: These examples use the latest version of this module

```hcl
module "minimal" {
  source              = "boldlink/autoscaling/aws"

  ## Autoscaling group
  name                = local.name
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = local.subnet_id
  vpc_id              = local.vpc_id

  # Launch template
  launch_template_description = "minimal launch template example"
  create_launch_template      = true
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "t2.medium"
  tags                        = local.tags

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
}
```
## Documentation

[AWS EC2 Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)

[Terraform provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#with-latest-version-of-launch-template)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.15.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_notification.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_notification) | resource |
| [aws_autoscaling_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_schedule.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_instance_profile.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatchagentserverpolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_launch_template.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sns_topic.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_role_policy_document"></a> [additional\_role\_policy\_document](#input\_additional\_role\_policy\_document) | Additional policy document to add to the created IAM role. | `string` | `null` | no |
| <a name="input_autoscaling_policy"></a> [autoscaling\_policy](#input\_autoscaling\_policy) | The configuration block for various autoscaling policies | `any` | `{}` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | (Optional) A list of one or more availability zones for the group. Used for EC2-Classic, attaching a network interface via id from a launch template and default subnets when not specified with `vpc_zone_identifier` argument. Conflicts with `vpc_zone_identifier`. | `list(string)` | `null` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | The storage device mapping block | `list(any)` | `[]` | no |
| <a name="input_capacity_rebalance"></a> [capacity\_rebalance](#input\_capacity\_rebalance) | (Optional) Indicates whether capacity rebalance is enabled. Otherwise, capacity rebalance is disabled. | `bool` | `false` | no |
| <a name="input_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#input\_capacity\_reservation\_specification) | (Optional) Targeting for EC2 capacity reservations. | `map(string)` | `{}` | no |
| <a name="input_cpu_options"></a> [cpu\_options](#input\_cpu\_options) | (Optional) The CPU options for the instance. | `map(string)` | `{}` | no |
| <a name="input_create_instance_profile"></a> [create\_instance\_profile](#input\_create\_instance\_profile) | Specify whether to create instance profile using the module. | `bool` | `true` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Specify whether to create launch template | `bool` | `false` | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | (Optional) Customize the credit specification of the instance. | `map(string)` | `{}` | no |
| <a name="input_default_cooldown"></a> [default\_cooldown](#input\_default\_cooldown) | (Optional) The amount of time, in seconds, after a scaling activity completes before another scaling activity can start. | `number` | `null` | no |
| <a name="input_default_version"></a> [default\_version](#input\_default\_version) | (Optional) Default Version of the launch template. | `number` | `null` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | (Optional) The number of Amazon EC2 instances that should be running in the group. | `number` | `null` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | (Optional) If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | (Optional) If true, the launched EC2 instance will be EBS-optimized. | `bool` | `false` | no |
| <a name="input_elastic_gpu_specifications"></a> [elastic\_gpu\_specifications](#input\_elastic\_gpu\_specifications) | (Optional) The elastic GPU to attach to the instance. | `map(string)` | `{}` | no |
| <a name="input_elastic_inference_accelerator"></a> [elastic\_inference\_accelerator](#input\_elastic\_inference\_accelerator) | (Optional) Configuration block containing an Elastic Inference Accelerator to attach to the instance. | `map(string)` | `{}` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Choose whether to enable key rotation | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Choose whether to enable monotoring | `bool` | `false` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | A list of metrics to collect. | `list(string)` | <pre>[<br>  "GroupMinSize",<br>  "GroupMaxSize",<br>  "GroupDesiredCapacity",<br>  "GroupInServiceInstances",<br>  "GroupPendingInstances",<br>  "GroupStandbyInstances",<br>  "GroupTerminatingInstances",<br>  "GroupTotalInstances"<br>]</pre> | no |
| <a name="input_enclave_options"></a> [enclave\_options](#input\_enclave\_options) | (Optional) Enable Nitro Enclaves on launched instances. | `map(string)` | `{}` | no |
| <a name="input_external_launch_template_name"></a> [external\_launch\_template\_name](#input\_external\_launch\_template\_name) | The name of the external launch template | `string` | `null` | no |
| <a name="input_external_launch_template_version"></a> [external\_launch\_template\_version](#input\_external\_launch\_template\_version) | The version of the external launch template | `string` | `null` | no |
| <a name="input_extra_script"></a> [extra\_script](#input\_extra\_script) | The name of the extra script | `string` | `""` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | (Optional) Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate. You can force an Auto Scaling Group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling. | `bool` | `null` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | (Optional, Default: 300) Time (in seconds) after instance comes into service before checking health. | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | (Optional) "EC2" or "ELB". Controls how health checking is done. | `string` | `null` | no |
| <a name="input_hibernation_options"></a> [hibernation\_options](#input\_hibernation\_options) | The hibernation options for the instance | `map(string)` | `{}` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | Provide an iam\_instance\_profile for the instances to be created. | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | The path for the iam role | `string` | `"/"` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | (Optional) The AMI from which to launch the instance. | `string` | `null` | no |
| <a name="input_initial_lifecycle_hooks"></a> [initial\_lifecycle\_hooks](#input\_initial\_lifecycle\_hooks) | (Optional) One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched. | `list(map(string))` | `[]` | no |
| <a name="input_install_cloudwatch_agent"></a> [install\_cloudwatch\_agent](#input\_install\_cloudwatch\_agent) | Specify whether to have cloudwatch agent installed in created instances | `bool` | `false` | no |
| <a name="input_install_ssm_agent"></a> [install\_ssm\_agent](#input\_install\_ssm\_agent) | Whether to install ssm agent | `bool` | `true` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | (Optional) Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`). | `string` | `"stop"` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | (Optional) The market (purchasing) option for the instance. | `map(string)` | `{}` | no |
| <a name="input_instance_refresh"></a> [instance\_refresh](#input\_instance\_refresh) | (Optional) If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated. | `any` | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | (Optional) The type of the instance. | `string` | `null` | no |
| <a name="input_kernel_id"></a> [kernel\_id](#input\_kernel\_id) | (Optional) The kernel ID. | `string` | `null` | no |
| <a name="input_key_deletion_window_in_days"></a> [key\_deletion\_window\_in\_days](#input\_key\_deletion\_window\_in\_days) | The number of days before the key is deleted | `number` | `7` | no |
| <a name="input_launch_configuration"></a> [launch\_configuration](#input\_launch\_configuration) | (Optional) The name of the launch configuration to use. | `string` | `null` | no |
| <a name="input_launch_template_description"></a> [launch\_template\_description](#input\_launch\_template\_description) | (Optional) Description of the launch template. | `string` | `null` | no |
| <a name="input_launch_template_name_prefix"></a> [launch\_template\_name\_prefix](#input\_launch\_template\_name\_prefix) | (Optional) Creates a unique name beginning with the specified prefix. Conflicts with name | `string` | `null` | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | The version of the launch template | `string` | `"$Latest"` | no |
| <a name="input_license_specifications"></a> [license\_specifications](#input\_license\_specifications) | (Optional) A list of license specifications to associate with. | `map(string)` | `{}` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | (Optional) A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead. | `list(string)` | `[]` | no |
| <a name="input_max_instance_lifetime"></a> [max\_instance\_lifetime](#input\_max\_instance\_lifetime) | (Optional) The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 86400 and 31536000 seconds. | `number` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | (Required) The maximum size of the Auto Scaling Group. | `number` | n/a | yes |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | (Optional) Customize the metadata options for the instance. | `map(string)` | `{}` | no |
| <a name="input_metrics_granularity"></a> [metrics\_granularity](#input\_metrics\_granularity) | (Optional) The granularity to associate with the metrics to collect. The only valid value is `1Minute`. Default is `1Minute`. | `string` | `"1Minute"` | no |
| <a name="input_min_elb_capacity"></a> [min\_elb\_capacity](#input\_min\_elb\_capacity) | (Optional) Setting this causes Terraform to wait for this number of instances from this Auto Scaling Group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes. | `number` | `null` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | (Required) The minimum size of the Auto Scaling Group. | `number` | n/a | yes |
| <a name="input_mixed_instances_policy"></a> [mixed\_instances\_policy](#input\_mixed\_instances\_policy) | (Optional) Configuration block containing settings to define launch targets for Auto Scaling groups. | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) The name of the Auto Scaling Group. By default generated by Terraform. Conflicts with `name_prefix` | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Creates a unique name beginning with the specified prefix. Conflicts with `name`. | `string` | `null` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | (Optional) Customize network interfaces to be attached at instance boot time. | `any` | `[]` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | (Optional) The placement of the instance. | `map(string)` | `{}` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | (Optional) The name of the placement group into which you'll launch your instances, if any. | `string` | `null` | no |
| <a name="input_private_dns_name_options"></a> [private\_dns\_name\_options](#input\_private\_dns\_name\_options) | (Optional) The options for the instance hostname. The default values are inherited from the subnet. | `map(string)` | `{}` | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | (Optional) Allows setting instance protection. The Auto Scaling Group will not select instances with this setting for termination during scale in events. | `bool` | `null` | no |
| <a name="input_ram_disk_id"></a> [ram\_disk\_id](#input\_ram\_disk\_id) | (Optional) The ID of the RAM disk. | `string` | `null` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `1827` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | Schedules configuration block | `map(any)` | `{}` | no |
| <a name="input_security_group_egress"></a> [security\_group\_egress](#input\_security\_group\_egress) | The rules block for defining additional egress rules | `any` | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of security group IDs to associate. | `list(string)` | `[]` | no |
| <a name="input_security_group_ingress"></a> [security\_group\_ingress](#input\_security\_group\_ingress) | The rules block for defining additional ingress rules | `any` | `[]` | no |
| <a name="input_service_linked_role_arn"></a> [service\_linked\_role\_arn](#input\_service\_linked\_role\_arn) | (Optional) The ARN of the service-linked role that the ASG will use to call other AWS services | `string` | `null` | no |
| <a name="input_sns_kms_master_key_id"></a> [sns\_kms\_master\_key\_id](#input\_sns\_kms\_master\_key\_id) | The kms key to use for encrypting sns topic | `string` | `"alias/aws/sns"` | no |
| <a name="input_sns_notifications"></a> [sns\_notifications](#input\_sns\_notifications) | (Required) A list of Notification Types that trigger notifications. | `list(string)` | <pre>[<br>  "autoscaling:EC2_INSTANCE_LAUNCH",<br>  "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",<br>  "autoscaling:EC2_INSTANCE_TERMINATE",<br>  "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"<br>]</pre> | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | The name of the sns topic | `string` | `null` | no |
| <a name="input_suspended_processes"></a> [suspended\_processes](#input\_suspended\_processes) | (Optional) A list of processes to suspend for the Auto Scaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the Launch or Terminate process types, it can prevent your Auto Scaling Group from functioning properly. | `list(string)` | `[]` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | (Optional) Configuration block(s) containing resource tags. | `map(string)` | `{}` | no |
| <a name="input_tag_specifications"></a> [tag\_specifications](#input\_tag\_specifications) | (Optional) The tags to apply to the resources during launch. | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Provide the tags for the resources | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | (Optional) A set of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancing. | `list(string)` | `[]` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | (Optional) A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default`. | `list(string)` | <pre>[<br>  "Default"<br>]</pre> | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Configuration block for autoscaling delete time | `map(string)` | `{}` | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | (Optional) Whether to update Default Version each update. Conflicts with `default_version`. | `bool` | `null` | no |
| <a name="input_use_mixed_instances_policy"></a> [use\_mixed\_instances\_policy](#input\_use\_mixed\_instances\_policy) | Choose whether to use mixed instances policy block | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to use when creating instances | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to launch resources in | `string` | `null` | no |
| <a name="input_vpc_zone_identifier"></a> [vpc\_zone\_identifier](#input\_vpc\_zone\_identifier) | (Optional) A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`. | `list(string)` | `null` | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | (Default: "10m") A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. | `string` | `"1m"` | no |
| <a name="input_wait_for_elb_capacity"></a> [wait\_for\_elb\_capacity](#input\_wait\_for\_elb\_capacity) | (Optional) Setting this will cause Terraform to wait for exactly this number of healthy instances from this Auto Scaling Group in all attached load balancers on both create and update operations. (Takes precedence over `min_elb_capacity` behavior.) | `number` | `null` | no |
| <a name="input_warm_pool"></a> [warm\_pool](#input\_warm\_pool) | (Optional) If this block is configured, add a Warm Pool to the specified Auto Scaling group. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN for this Auto Scaling Group |
| <a name="output_as_name"></a> [as\_name](#output\_as\_name) | The name of the Auto Scaling Group |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the role. |
| <a name="output_id"></a> [id](#output\_id) | The Auto Scaling Group id. |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The Amazon Resource Name (ARN) specifying the log group. Any `:*` suffix added by the API, denoting all CloudWatch Log Streams under the CloudWatch Log Group, is removed for greater compatibility with other AWS services that do not accept the suffix. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | The name of the log group. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group. |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the security group |
| <a name="output_template_arn"></a> [template\_arn](#output\_template\_arn) | Amazon Resource Name (ARN) of the launch template. |
| <a name="output_template_id"></a> [template\_id](#output\_template\_id) | The ID of the launch template. |
| <a name="output_template_latest_version"></a> [template\_latest\_version](#output\_template\_latest\_version) | The latest version of the launch template. |
| <a name="output_template_name"></a> [template\_name](#output\_template\_name) | The name of the launch template |
| <a name="output_template_tags_all"></a> [template\_tags\_all](#output\_template\_tags\_all) | A map of tags assigned to the resource |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Third party software
This repository uses third party software:
* [pre-commit](https://pre-commit.com/) - Used to help ensure code and documentation consistency
  * Install with `brew install pre-commit`
  * Manually use with `pre-commit run`
* [terraform 0.14.11](https://releases.hashicorp.com/terraform/0.14.11/) For backwards compatibility we are using version 0.14.11 for testing making this the min version tested and without issues with terraform-docs.
* [terraform-docs](https://github.com/segmentio/terraform-docs) - Used to generate the [Inputs](#Inputs) and [Outputs](#Outputs) sections
  * Install with `brew install terraform-docs`
  * Manually use via pre-commit
* [tflint](https://github.com/terraform-linters/tflint) - Used to lint the Terraform code
  * Install with `brew install tflint`
  * Manually use via pre-commit

### Supporting resources:

The example stacks are used by BOLDLink developers to validate the modules by building an actual stack on AWS.

Some of the modules have dependencies on other modules (ex. Ec2 instance depends on the VPC module) so we create them
first and use data sources on the examples to use the stacks.

Any supporting resources will be available on the `tests/supportingResources` and the lifecycle is managed by the `Makefile` targets.

Resources on the `tests/supportingResources` folder are not intended for demo or actual implementation purposes, and can be used for reference.

### Makefile
The makefile contained in this repo is optimized for linux paths and the main purpose is to execute testing for now.
* Create all tests stacks including any supporting resources:
```console
make tests
```
* Clean all tests *except* existing supporting resources:
```console
make clean
```
* Clean supporting resources - this is done separately so you can test your module build/modify/destroy independently.
```console
make cleansupporting
```
* !!!DANGER!!! Clean the state files from examples and test/supportingResources - use with CAUTION!!!
```console
make cleanstatefiles
```

#### BOLDLink-SIG 2023
