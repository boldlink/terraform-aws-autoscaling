locals {
  subnet_az = [
    for az in data.aws_subnet.private : az.availability_zone
  ]

  subnet_id = [
    for i in data.aws_subnet.private : i.id
  ]

  private_subnets = local.subnet_id[0]
  azs             = local.subnet_az[0]
  vpc_id          = data.aws_vpc.supporting.id
  vpc_cidr        = data.aws_vpc.supporting.cidr_block
  tags            = merge({ "Name" = var.name }, var.tags)
  account_id      = data.aws_caller_identity.current.account_id
  partition       = data.aws_partition.current.partition
  dns_suffix      = data.aws_partition.current.dns_suffix

  kms_policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "key-policy-1",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow Autoscaling service-linked role use of the customer managed key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:${local.partition}:iam::${local.account_id}:role/aws-service-role/autoscaling.${local.dns_suffix}/AWSServiceRoleForAutoScaling"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow EKS Nodes to Use the Key",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
    }
  )
}
