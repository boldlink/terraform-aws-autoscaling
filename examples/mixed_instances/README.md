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

# Terraform module example of configuration for mixed instances

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.30.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mixed_instances"></a> [mixed\_instances](#module\_mixed\_instances) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.supporting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture"></a> [architecture](#input\_architecture) | The architecture of the instance to be launched | `string` | `"x86_64"` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Specify whether to create launch template | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the launch template | `string` | `"Complete launch template example"` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group. | `number` | `1` | no |
| <a name="input_install_ssm_agent"></a> [install\_ssm\_agent](#input\_install\_ssm\_agent) | Whether to install ssm agent | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specify the instance type | `string` | `"t3.medium"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the Auto Scaling Group. | `number` | `2` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the Auto Scaling Group. | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the stack | `string` | `"mixed-instances-example"` | no |
| <a name="input_supporting_resources_name"></a> [supporting\_resources\_name](#input\_supporting\_resources\_name) | Name of the supporting resources stack | `string` | `"terraform-aws-autoscaling"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Name of the supporting resources stack | `map(string)` | <pre>{<br>  "Department": "DevOps",<br>  "Environment": "examples",<br>  "InstanceScheduler": true,<br>  "LayerId": "cExample",<br>  "LayerName": "cExample",<br>  "Owner": "Boldlink",<br>  "Project": "Examples",<br>  "user::CostCenter": "terraform-registry"<br>}</pre> | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | Whether to update Default Version each update. Conflicts with `default_version`. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_outputs"></a> [outputs](#output\_outputs) | Output for various resources in this module |
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

#### BOLDLink-SIG 2023
