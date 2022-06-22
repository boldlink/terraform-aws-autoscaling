# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Add: More options in the complete example
- Feature: Ability for userdata packages to be installed in different OS flavours
- Feature: Dashboards integration for Cloudwatch
- Feature: Tag inheritance for created resources
- Feature: Expand the complete example further
- Feature: Add updated features from tf resource page

## [1.2.0] - 2022-06-22
### Changes
- Fix: Userdata partial success (some packages not installing) specifically cloudwatch agent
- Added required permissions for agent to send logs and metrics to cloudwatch
- Added IAM instance profile feature for LC

[1.2.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.2.0

## [1.1.1] - 2022-06-10
### Changes
- Fix: network interfaces being created in existing resources but throwing an error in resource initial creation

[1.1.1]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.1.1

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

[1.1.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.1.0

## [1.0.0] - 2022-04-07
- Initial commit

[1.0.0]: https://github.com/boldlink/terraform-aws-autoscaling/releases/tag/1.0.0
