# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- fix: Troubleshoot why ssm is not installed on the instances and fix
- feat: Showcase usage of external security group (`var.security_group_ids`)
- feat: Showcase usage of `private_dns_name_options` in examples
- feat: add support for traffic source
- feat: target_tracking_configuration
- feat: Include installation of awslogs on ubuntu instances in the script
- feat: add cloud-init script for creating windows OS SSM user when enabled.
- feat: Allow the input of a custom awslogs.json configuration file on cwldata.sh installation`
- fix: Failed instance status checks for t2 instances
- feat: Add notification support through sns for asg events in the examples
- feat: Add windows support - requires adding new userdata templates.
- feat: Ability for userdata packages to be installed in different OS flavours.
- feat: Dashboards integration for Cloudwatch.
- feat: Add updated features from tf resource page.
- feat: Make the cwa json file a template of it’s own.
- Feat: Allow to insert additional scripts at the stack level.
- feat: Add more options to secrets manager where pem key is store (e.g tags, retention e.t.c).
- feat: Remove/upgrade usage of deprecated hashicorp/template provider
- fix: CKV_AWS_356 "Ensure no IAM policies documents allow “*” as a statement’s resource for restrictable actions"
- fix: CKV2_AWS_57 "Ensure Secrets Manager secrets should have automatic rotation enabled"
- fix: CKV_AWS_341 "Ensure Launch template should not have a metadata response hop limit greater than 1"
- fix: CKV_TF_1 "Ensure Terraform module sources use a commit hash"

##  [2.1.0] - 2024-01-03
- feat: removed `elastic_gpu_specifications` support as it will no longer be supported by AWS. See [here](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-graphics.html#elastic-gpus-basics)
- feat: removed `elastic_inference_accelerator` support as it will no longer be supported by AWS for new customers. See [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-inference.html)
- showcased the usage of `max_instance_lifetime` in complete example
- showcased the usage of `protect_from_scale_in` in complete example

##  [2.0.7] - 2023-12-28
- showcased the usage of accelerators specification for autoscaling group

##  [2.0.6] - 2023-12-27
- showcased the usage of external placement group, schedule start and end, cpu_options, enclave options and hibernation options
- showcased the usage of termination_policies, suspended_processes, capacity_rebalance

##  [2.0.5] - 2023-12-22
- fixed and showcased the usage of spot instance_market_options

##  [2.0.4] - 2023-12-20
- fix: fix and showcased the usage of warm pool

##  [2.0.3] - 2023-12-14
- fix: showcased the usage of instance requirements

##  [2.0.2] - 2023-12-08
- fix: showcased the usage of custom metrics block

##  [2.0.1] - 2023-11-10
- feat: Added example for external launch template
- feat: Showcased usage of mixed instances in examples
- fix: Added missing external launch template name
- fix: Mixed instances block to allow provision of external launch template
- fix: security group to create on condition
- fix: SG ID in outputs as a result of change in security group resource condition
- fix: Modified condition for picking security groups in `network_interfaces` block and `vpc_security_group_ids` arg


##  [2.0.0] - 2023-09-05
### Changes
- feat: Added ssm support and removed key pair creation for different linux distros
- feat: Add Operating System flexibility in script (i.e download/install packages depending on OS flavor) for linux instances.
- feat: Restructured the script to update first and install necessary packages
- fix: Remove profile from lifecycle changes

## [1.2.2] - 2023-08-14
- fix: VPC version used in supporting resources. This is to fix pre-commit errors for deprecated outputs

## [1.2.1] - 2022-10-18
### Changes
- fix: CKV_AWS_79: Ensure Instance Metadata Service Version 1 is not enabled.
- fix: CKV_AWS_111 #Ensure IAM policies does not allow write access without constraints.
- fix: CKV_AWS_109 #Ensure IAM policies does not allow permissions management / resource exposure without constraints.
- fix: Multiple VPCs are created for the examples, create only one as a support resource and use by all examples.
- feat: Add updated files from template repository
- feat: Tag inheritance for created resources.

## [1.2.0] - 2022-06-30
### Changes
- fix: Userdata partial success (some packages not installing) specifically cloudwatch agent
- feat: Added required permissions for agent to send logs and metrics to cloudwatch
- feat: Added IAM instance profile feature for LC

## [1.1.1] - 2022-06-10
### Changes
- Fix: network interfaces being created in existing resources but throwing an error in resource initial creation

## [1.1.0] - 2022-05-25
### Added
- Added the `.github/workflow` folder
- Added `CHANGELOG.md`
- Added `CODEOWNERS`
- Added `versions.tf`, required for pre-commit checks
- Added `Makefile` for examples automation
- Added `.gitignore` file

### Features
- Feature: Ability to add additional SG rules

### Changes/Fixes
- Re-factored examples (`minimum` and `complete`). Further minimised the `minimal` example.
- Modified `.pre-commit-config.yaml` file

## [1.0.0] - 2022-04-07
- Initial commit


[Unreleased]: https://github.com/boldlink/terraform-aws-autoscaling/compare/2.1.0...HEAD

[2.1.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/2.1.0
[2.0.7]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/2.0.7
[2.0.6]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/2.0.6
[2.0.5]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/2.0.5
[2.0.4]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/2.0.4
[2.0.3]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/2.0.3
[2.0.2]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/2.0.2
[2.0.1]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/2.0.1
[2.0.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/2.0.0
[1.2.2]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.2.2
[1.2.1]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.2.1
[1.2.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.2.0
[1.1.1]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.1.1
[1.1.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.1.0
[1.0.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.0.0
