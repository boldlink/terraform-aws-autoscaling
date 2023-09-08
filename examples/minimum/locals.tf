locals {
  subnet_id = [
    for i in data.aws_subnet.private : i.id
  ]
  vpc_id = data.aws_vpc.supporting.id
  tags   = merge({ "Name" = var.name }, var.tags)
}
