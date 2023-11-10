variable "name" {
  type        = string
  description = "Name of the stack"
  default     = "mixed-instances-example"
}

variable "supporting_resources_name" {
  type        = string
  description = "Name of the supporting resources stack"
  default     = "terraform-aws-autoscaling"
}

variable "update_default_version" {
  type        = bool
  description = "Whether to update Default Version each update. Conflicts with `default_version`."
  default     = true
}

variable "create_launch_template" {
  type        = bool
  description = "Specify whether to create launch template"
  default     = true
}

variable "min_size" {
  type        = number
  description = "The minimum size of the Auto Scaling Group."
  default     = 0
}

variable "max_size" {
  type        = number
  description = "The maximum size of the Auto Scaling Group."
  default     = 2
}

variable "desired_capacity" {
  type        = number
  description = "The number of Amazon EC2 instances that should be running in the group."
  default     = 1
}

variable "install_cloudwatch_agent" {
  type        = bool
  description = "Specify whether to have cloudwatch agent installed in created instances"
  default     = true
}

variable "architecture" {
  type        = string
  description = "The architecture of the instance to be launched"
  default     = "x86_64"
}

variable "description" {
  type        = string
  description = "The description of the launch template"
  default     = "Complete launch template example"
}

variable "instance_type" {
  type        = string
  description = "Specify the instance type"
  default     = "t3.medium"
}

variable "install_ssm_agent" {
  type        = bool
  description = "Whether to install ssm agent"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Name of the supporting resources stack"
  default = {
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
    Department         = "DevOps"
    InstanceScheduler  = true
    Project            = "Examples"
    Owner              = "Boldlink"
    LayerName          = "cExample"
    LayerId            = "cExample"
  }
}
