[![Build Status](https://github.com/boldlink/terraform-aws-autoscaling/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/boldlink/terraform-aws-autoscaling/actions)

[<img src="https://avatars.githubusercontent.com/u/25388280?s=200&v=4" width="96"/>](https://boldlink.io)

# AWS Autoscaling Terraform module

## Description
This module creates the resources needed to deploy and monitor autoscaled infrastracture in AWS.

Examples available [here](https://github.com/boldlink/terraform-aws-autoscaling/tree/main/examples)

## Usage
*NOTE*: These examples use the latest version of this module

```hcl
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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.9.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.3.0 |

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
| [aws_iam_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_key_pair.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sns_topic.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [tls_private_key.main](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_iam_policy_document.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [template_cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_policy"></a> [autoscaling\_policy](#input\_autoscaling\_policy) | The configuration block for various autoscaling policies | `any` | `{}` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | (Optional) A list of one or more availability zones for the group. Used for EC2-Classic, attaching a network interface via id from a launch template and default subnets when not specified with `vpc_zone_identifier` argument. Conflicts with `vpc_zone_identifier`. | `list(string)` | `null` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | The storage device mapping block | `list(any)` | `[]` | no |
| <a name="input_capacity_rebalance"></a> [capacity\_rebalance](#input\_capacity\_rebalance) | (Optional) Indicates whether capacity rebalance is enabled. Otherwise, capacity rebalance is disabled. | `bool` | `false` | no |
| <a name="input_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#input\_capacity\_reservation\_specification) | (Optional) Targeting for EC2 capacity reservations. | `map(string)` | `{}` | no |
| <a name="input_cpu_options"></a> [cpu\_options](#input\_cpu\_options) | (Optional) The CPU options for the instance. | `map(string)` | `{}` | no |
| <a name="input_create_key_pair"></a> [create\_key\_pair](#input\_create\_key\_pair) | Specify whether to create key pair resources | `bool` | `false` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Specify whether to create launch template | `bool` | `false` | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | (Optional) Customize the credit specification of the instance. | `map(string)` | `{}` | no |
| <a name="input_debug_script"></a> [debug\_script](#input\_debug\_script) | Enable set -x option for userdatam use 'off' or 'on' as values | `string` | `"off"` | no |
| <a name="input_default_cooldown"></a> [default\_cooldown](#input\_default\_cooldown) | (Optional) The amount of time, in seconds, after a scaling activity completes before another scaling activity can start. | `number` | `null` | no |
| <a name="input_default_version"></a> [default\_version](#input\_default\_version) | (Optional) Default Version of the launch template. | `string` | `null` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | (Optional) The number of Amazon EC2 instances that should be running in the group. | `number` | `null` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | (Optional) If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | (Optional) If true, the launched EC2 instance will be EBS-optimized. | `bool` | `false` | no |
| <a name="input_elastic_gpu_specifications"></a> [elastic\_gpu\_specifications](#input\_elastic\_gpu\_specifications) | (Optional) The elastic GPU to attach to the instance. | `map(string)` | `{}` | no |
| <a name="input_elastic_inference_accelerator"></a> [elastic\_inference\_accelerator](#input\_elastic\_inference\_accelerator) | (Optional) Configuration block containing an Elastic Inference Accelerator to attach to the instance. | `map(string)` | `{}` | no |
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
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | The path for the iam role | `string` | `"/"` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | (Optional) The AMI from which to launch the instance. | `string` | `null` | no |
| <a name="input_initial_lifecycle_hooks"></a> [initial\_lifecycle\_hooks](#input\_initial\_lifecycle\_hooks) | (Optional) One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched. | `list(map(string))` | `[]` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | (Optional) Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`). | `string` | `"stop"` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | (Optional) The market (purchasing) option for the instance. | `map(string)` | `{}` | no |
| <a name="input_instance_refresh"></a> [instance\_refresh](#input\_instance\_refresh) | (Optional) If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated. | `any` | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | (Optional) The type of the instance. | `string` | `null` | no |
| <a name="input_kernel_id"></a> [kernel\_id](#input\_kernel\_id) | (Optional) The kernel ID. | `string` | `null` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | (Optional) The key name to use for the instance. | `string` | `null` | no |
| <a name="input_launch_configuration"></a> [launch\_configuration](#input\_launch\_configuration) | (Optional) The name of the launch configuration to use. | `string` | `null` | no |
| <a name="input_launch_template_description"></a> [launch\_template\_description](#input\_launch\_template\_description) | (Optional) Description of the launch template. | `string` | `null` | no |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | (Optional) The name of the launch template. If you leave this blank, Terraform will auto-generate a unique name. | `string` | `null` | no |
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
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | (Optional) Customize network interfaces to be attached at instance boot time. | `list(any)` | `[]` | no |
| <a name="input_other_tags"></a> [other\_tags](#input\_other\_tags) | For adding an additional values for tags | `map(string)` | `{}` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | (Optional) The placement of the instance. | `map(string)` | `{}` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | (Optional) The name of the placement group into which you'll launch your instances, if any. | `string` | `null` | no |
| <a name="input_private_dns_name_options"></a> [private\_dns\_name\_options](#input\_private\_dns\_name\_options) | (Optional) The options for the instance hostname. The default values are inherited from the subnet. | `map(string)` | `{}` | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | (Optional) Allows setting instance protection. The Auto Scaling Group will not select instances with this setting for termination during scale in events. | `bool` | `null` | no |
| <a name="input_ram_disk_id"></a> [ram\_disk\_id](#input\_ram\_disk\_id) | (Optional) The ID of the RAM disk. | `string` | `null` | no |
| <a name="input_rsa_bits"></a> [rsa\_bits](#input\_rsa\_bits) | (Optional) When algorithm is `RSA`, the size of the generated RSA key in bits. Defaults to `2048`. | `number` | `"4096"` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | Schedules configuration block | `map(any)` | `{}` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of security group IDs to associate. | `list(string)` | `[]` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | The rules block for defining additional ingress and egress rules | `any` | `{}` | no |
| <a name="input_service_linked_role_arn"></a> [service\_linked\_role\_arn](#input\_service\_linked\_role\_arn) | (Optional) The ARN of the service-linked role that the ASG will use to call other AWS services | `string` | `null` | no |
| <a name="input_sns_kms_master_key_id"></a> [sns\_kms\_master\_key\_id](#input\_sns\_kms\_master\_key\_id) | The kms key to use for encrypting sns topic | `string` | `"alias/aws/sns"` | no |
| <a name="input_sns_notifications"></a> [sns\_notifications](#input\_sns\_notifications) | (Required) A list of Notification Types that trigger notifications. | `list(string)` | <pre>[<br>  "autoscaling:EC2_INSTANCE_LAUNCH",<br>  "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",<br>  "autoscaling:EC2_INSTANCE_TERMINATE",<br>  "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"<br>]</pre> | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | The name of the sns topic | `string` | `null` | no |
| <a name="input_ssh_key_algorithm"></a> [ssh\_key\_algorithm](#input\_ssh\_key\_algorithm) | (Required) The name of the algorithm to use for the key. Currently-supported values are `RSA` and `ECDSA`. | `string` | `"RSA"` | no |
| <a name="input_suspended_processes"></a> [suspended\_processes](#input\_suspended\_processes) | (Optional) A list of processes to suspend for the Auto Scaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the Launch or Terminate process types, it can prevent your Auto Scaling Group from functioning properly. | `list(string)` | `[]` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | (Optional) Configuration block(s) containing resource tags. | `map(string)` | `{}` | no |
| <a name="input_tag_env"></a> [tag\_env](#input\_tag\_env) | The environment this resource is being deployed to | `string` | `null` | no |
| <a name="input_tag_specifications"></a> [tag\_specifications](#input\_tag\_specifications) | (Optional) The tags to apply to the resources during launch. | `list(any)` | `[]` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | (Optional) A set of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancing. | `list(string)` | `[]` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | (Optional) A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default`. | `list(string)` | <pre>[<br>  "Default"<br>]</pre> | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Configuration block for autoscaling delete time | `map(string)` | `{}` | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | (Optional) Whether to update Default Version each update. Conflicts with `default_version`. | `string` | `null` | no |
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
| <a name="output_fingerprint"></a> [fingerprint](#output\_fingerprint) | The MD5 public key fingerprint as specified in section 4 of RFC 4716. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the role. |
| <a name="output_id"></a> [id](#output\_id) | The Auto Scaling Group id. |
| <a name="output_key_name"></a> [key\_name](#output\_key\_name) | The key pair name. |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The Amazon Resource Name (ARN) specifying the log group. Any `:*` suffix added by the API, denoting all CloudWatch Log Streams under the CloudWatch Log Group, is removed for greater compatibility with other AWS services that do not accept the suffix. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | The name of the log group. |
| <a name="output_private_key_pem"></a> [private\_key\_pem](#output\_private\_key\_pem) | The private key data in PEM format. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group. |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the security group |
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

### Makefile
The makefile contain in this repo is optimised for linux paths and the main purpose is to execute testing for now.
* Create all tests:
`$ make tests`
* Clean all tests:
`$ make clean`

#### BOLDLink-SIG 2022
