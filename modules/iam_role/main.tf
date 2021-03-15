locals {
  default_tags = {
    Environment = terraform.workspace
    Name        = "${var.identifier}-${terraform.workspace}"
  }
  tags = merge(local.default_tags, var.tags)
}


resource "aws_iam_role" "role" {
  force_detach_policies = true
  name                  = "${var.identifier}-${terraform.workspace}"
  description           = var.description

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "${var.aws_service_principal}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "attach" {
  count = length(var.iam_policies_to_attach)

  policy_arn = element(var.iam_policies_to_attach, count.index)
  role       = aws_iam_role.role.name
}
