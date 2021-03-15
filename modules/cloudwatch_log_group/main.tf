locals {
  default_tags = {
    Environment = "${terraform.workspace}"
    Name        = "${var.identifier}-${terraform.workspace}"
  }
  tags = merge(local.default_tags, var.tags)
}

resource "aws_cloudwatch_log_group" "group" {
  retention_in_days = var.retention_in_days
  name_prefix       = "${var.identifier}-${terraform.workspace}-"
  kms_key_id        = var.kms_key_arn

  tags = local.tags
}
