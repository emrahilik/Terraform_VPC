locals {
  default_tags = {
    Environment = terraform.workspace
    Name        = "${var.identifier}-${terraform.workspace}"
  }
  tags = merge(local.default_tags, var.tags)
}

resource "aws_iam_policy" "policy" {
  name = "${var.identifier}-${terraform.workspace}"
  policy = jsonencode(var.policy)
}