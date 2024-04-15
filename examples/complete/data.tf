data "aws_region" "current" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-*-${var.architecture}-gp2"]
  }
}

data "aws_vpc" "supporting" {
  filter {
    name   = "tag:Name"
    values = [var.supporting_resources_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${var.supporting_resources_name}*.pri.*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "additional_role_policy_document" {
  version = "2012-10-17"

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:${local.partition}:s3:::*"]
    effect    = "Allow"
  }
}
