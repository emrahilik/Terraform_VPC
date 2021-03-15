resource "aws_network_acl" "public_layer" {
  count = length(var.vpc_settings["public_subnets"])

  subnet_ids = [local.public_subnets[count.index].id]
  vpc_id     = aws_vpc.vpc.id
  tags       = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-public-nacl" })
}

resource "aws_network_acl" "data_layer" {
  count = length(var.vpc_settings["data_subnets"])

  subnet_ids = [local.data_subnets[count.index].id]
  vpc_id     = aws_vpc.vpc.id
  tags       = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-data-nacl" })
}

resource "aws_network_acl" "application_layer" {
  count = length(var.vpc_settings["private_subnets"])

  subnet_ids = [local.private_subnets[count.index].id]
  vpc_id     = aws_vpc.vpc.id
  tags       = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-application-nacl" })
}

### This allow all traffic from private subnets
resource "aws_network_acl_rule" "ingress-for-ec2-from-private-subnets" {
  count = length(var.vpc_settings["data_subnets"])

  network_acl_id = aws_network_acl.data_layer[count.index].id
  rule_action    = "allow"
  rule_number    = 100
  cidr_block     = var.vpc_settings.private_subnets[count.index]
  from_port      = 0
  protocol       = -1
  to_port        = 0
  egress         = false
}

### This allow all egress traffic
resource "aws_network_acl_rule" "egress-all-data" {
  count = length(var.vpc_settings["data_subnets"])

  network_acl_id = aws_network_acl.data_layer[count.index].id
  rule_action    = "allow"
  rule_number    = 100
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  protocol       = -1
  to_port        = 0
  egress         = true
}


resource "aws_network_acl_rule" "ingress-all-tcp-from-public" {
  count = length(var.vpc_settings["private_subnets"])

  network_acl_id = aws_network_acl.application_layer[count.index].id
  rule_action    = "allow"
  rule_number    = 100
  cidr_block     = var.vpc_settings.public_subnets[count.index]
  from_port      = 0
  protocol       = "tcp"
  to_port        = 65535
  egress         = false
}


### This allow all egress traffic
resource "aws_network_acl_rule" "egress-all-app" {
  count = length(var.vpc_settings["private_subnets"])

  network_acl_id = aws_network_acl.application_layer[count.index].id
  rule_action    = "allow"
  rule_number    = 100
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  protocol       = -1
  to_port        = 0
  egress         = true
}


### This allow all traffic in public subnets
resource "aws_network_acl_rule" "ingress-all-public" {
  count = length(var.vpc_settings["public_subnets"])

  network_acl_id = aws_network_acl.public_layer[count.index].id
  rule_action    = "allow"
  rule_number    = 100
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  protocol       = -1
  to_port        = 0
  egress         = false
}

### This allow all egress traffic from public subnets
resource "aws_network_acl_rule" "egress-all-public" {
  count = length(var.vpc_settings["public_subnets"])

  network_acl_id = aws_network_acl.public_layer[count.index].id
  rule_action    = "allow"
  rule_number    = 100
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  protocol       = -1
  to_port        = 0
  egress         = true
} 
