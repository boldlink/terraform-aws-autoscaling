# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- fix: CKV_AWS_79 #Ensure Instance Metadata Service Version 1 is not enabled. Included in examples.
- fix: CKV_AWS_111 #Ensure IAM policies does not allow write access without constraints.
- fix: CKV_AWS_109 #Ensure IAM policies does not allow permissions management / resource exposure without constraints.
- fix: Multiple VPCs are created for the examples, create only one as a support resource and use by all examples.
- fix: Failed instance status checks for t2 instances
- fix: Remove profile from lifecycle changes
- feat: Add notification support through sns for asg events in the examples
- feat: Add windows support - requires adding new userdata templates.
- feat: Add options in the complete example.
- feat: Ability for userdata packages to be installed in different OS flavours.
- feat: Dashboards integration for Cloudwatch.
- feat: Tag inheritance for created resources.
- feat: Expand the complete example further.
- feat: Add updated features from tf resource page.
- feat: Make the cwa json file a template of it’s own.
- Feat: Allow to insert additional scripts at the stack level.
- feat: Add example for external Launch Template
- feat: Add more options to secrets manager where pem key is store (e.g tags, retention e.t.c).
- feat: Remove/upgrade usage of deprecated hashicorp/template provider

## [1.2.1] - 2022-10-14
### Changes
- fix: CKV_AWS_79: Ensure Instance Metadata Service Version 1 is not enabled.
- feat: Add updated files from template repository

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


[Unreleased]: https://github.com/boldlink/terraform-aws-autoscaling/compare/1.2.0...HEAD
[1.2.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.2.0
[1.1.1]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.1.1
[1.1.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.1.0
[1.0.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.0.0
