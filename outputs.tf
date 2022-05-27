##################################
### Log Group
##################################
output "log_group_name" {
  value       = join("", aws_cloudwatch_log_group.main.*.name)
  description = "The name of the log group."
}

output "log_group_arn" {
  value       = join("", aws_cloudwatch_log_group.main.*.arn)
  description = "The Amazon Resource Name (ARN) specifying the log group. Any `:*` suffix added by the API, denoting all CloudWatch Log Streams under the CloudWatch Log Group, is removed for greater compatibility with other AWS services that do not accept the suffix."
}

##################################
### Key Pair
##################################
output "key_name" {
  value       = join("", aws_key_pair.main.*.key_name)
  description = "The key pair name."
}

output "fingerprint" {
  value       = join("", aws_key_pair.main.*.fingerprint)
  description = " The MD5 public key fingerprint as specified in section 4 of RFC 4716."
}

##################################
### Auto Scaling group
##################################
output "id" {
  value       = aws_autoscaling_group.main.id
  description = "The Auto Scaling Group id."
}

output "as_name" {
  value       = aws_autoscaling_group.main.name
  description = "The name of the Auto Scaling Group"
}

output "arn" {
  value       = aws_autoscaling_group.main.arn
  description = "The ARN for this Auto Scaling Group"
}

output "private_key_pem" {
  value       = join("", tls_private_key.main.*.private_key_pem)
  description = "The private key data in PEM format."
}

##################################
#### SG
##################################
output "security_group_id" {
  value       = aws_security_group.main.id
  description = "ID of the security group."
}

output "security_group_name" {
  value       = aws_security_group.main.name
  description = "The name of the security group"
}

##################################
### IAM Role
##################################
output "iam_role_arn" {
  value       = aws_iam_role.main.arn
  description = "Amazon Resource Name (ARN) specifying the role."
}

output "iam_role_name" {
  value       = aws_iam_role.main.name
  description = "Name of the role."
}

##################################
### Launch template
##################################

output "template_name" {
  value       = aws_launch_template.main[0].name
  description = "The name of the launch template"
}

output "template_arn" {
  value       = aws_launch_template.main[0].arn
  description = "Amazon Resource Name (ARN) of the launch template."
}

output "template_id" {
  value       = aws_launch_template.main[0].id
  description = "The ID of the launch template."
}

output "template_latest_version" {
  value       = aws_launch_template.main[0].latest_version
  description = "The latest version of the launch template."
}

output "template_tags_all" {
  value       = aws_launch_template.main[0].tags_all
  description = "A map of tags assigned to the resource"
}
