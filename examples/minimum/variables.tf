variable "name" {
  type        = string
  description = "Name of the stack"
  default     = "minimal-autoscaling-example"
}

variable "architecture" {
  type        = string
  description = "The architecture of the instance to be launched"
  default     = "amd64"
}

variable "description" {
  type        = string
  description = "The description of the launch template"
  default     = "minimal launch template example"
}

variable "supporting_resources_name" {
  type        = string
  description = "Name of the supporting resources stack"
  default     = "terraform-aws-autoscaling"
}

variable "instance_type" {
  type        = string
  description = "Specify the instance type"
  default     = "t2.medium"
}

variable "create_launch_template" {
  type        = bool
  description = "Specify whether to create launch template"
  default     = true
}

variable "security_group_egress" {
  type        = any
  description = "Security Group egress"
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the created resources"
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
