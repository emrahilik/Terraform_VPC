data "aws_availability_zones" "available" {}
locals {
  default_tags = {
    Environment = terraform.workspace
    Name        = "${var.identifier}-${terraform.workspace}"
  }

  tags = merge(local.default_tags, var.tags)

  ### Created Subnets from for_each loop, so we can reference them easily
  private_subnets     = values(aws_subnet.private_subnets)
  route_table_list    = concat([aws_route_table.public.id], aws_route_table.data_subnets.*.id, aws_route_table.private.*.id)
  public_subnets      = values(aws_subnet.public_subnets)
  data_subnets        = values(aws_subnet.data_subnets)

  ### AZ count used for multi nat gw setups
  multi_nat = local.az_count 
  az_count  = length(var.vpc_settings["public_subnets"]) > length(data.aws_availability_zones.available.names) ? length(data.aws_availability_zones.available.names) : length(var.vpc_settings["public_subnets"])
}

resource "aws_vpc" "vpc" {
  enable_dns_hostnames = var.vpc_settings["dns_hostnames"]
  enable_dns_support   = var.vpc_settings["dns_support"]
  instance_tenancy     = var.vpc_settings["tenancy"]
  cidr_block           = var.vpc_settings["cidr"]
  tags                 = local.tags
}

resource "aws_subnet" "public_subnets" {
  for_each = toset(var.vpc_settings["public_subnets"])

  map_public_ip_on_launch = false
  availability_zone = element(
    data.aws_availability_zones.available.names,
    index(var.vpc_settings["public_subnets"], each.key) % length(data.aws_availability_zones.available.names),
  )
  cidr_block = each.key
  vpc_id     = aws_vpc.vpc.id

  tags = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-public-${index(var.vpc_settings["public_subnets"], each.key)}" })
}

resource "aws_subnet" "private_subnets" {
  for_each = toset(var.vpc_settings["private_subnets"])

  map_public_ip_on_launch = false
  availability_zone = element(
    data.aws_availability_zones.available.names,
    index(var.vpc_settings["private_subnets"], each.key) % length(data.aws_availability_zones.available.names),
  )
  cidr_block = each.key
  vpc_id     = aws_vpc.vpc.id

  tags = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-private-${index(var.vpc_settings["private_subnets"], each.key)}" })
}

resource "aws_subnet" "data_subnets" {
  for_each = toset(var.vpc_settings["data_subnets"])

  map_public_ip_on_launch = false
  availability_zone = element(
    data.aws_availability_zones.available.names,
    index(var.vpc_settings["data_subnets"], each.key) % length(data.aws_availability_zones.available.names),
  )
  cidr_block = each.key
  vpc_id     = aws_vpc.vpc.id

  tags = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-data-${index(var.vpc_settings["data_subnets"], each.key)}" })
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags
}

resource "aws_eip" "nat_gw" {
  count = local.multi_nat
  tags  = local.tags
  vpc   = true

  depends_on = [aws_subnet.private_subnets, aws_subnet.data_subnets]
}

resource "aws_nat_gateway" "nat_gw" {
  count         = local.multi_nat
  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = local.public_subnets[count.index].id
  tags          = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-nat-gw-${count.index}" })

  depends_on = [aws_subnet.private_subnets, aws_subnet.data_subnets, aws_subnet.public_subnets]
}

### Route Table definition

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-public" })
}

resource "aws_route_table" "private" {
  count  = length(var.vpc_settings["private_subnets"])
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-private-${count.index}" })
}

resource "aws_route_table" "data_subnets" {
  count  = length(var.vpc_settings["data_subnets"])
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-data-${count.index}" })
}

### Default Route definition per layer

resource "aws_route" "internet_gateway_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public.id
  depends_on             = [aws_route_table.public]
}

resource "aws_route" "private_nat_gateway_route" {
  count                  = length(var.vpc_settings["private_subnets"])
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index % local.multi_nat].id
  route_table_id         = aws_route_table.private[count.index].id
  depends_on             = [aws_route_table.private]
}

resource "aws_route" "data_nat_gateway_route" {
  count                  = length(var.vpc_settings["data_subnets"])
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index % local.multi_nat].id
  route_table_id         = aws_route_table.data_subnets[count.index].id
  depends_on             = [aws_route_table.data_subnets]
}

### route table association

resource "aws_route_table_association" "private_subnets" {
  count          = length(var.vpc_settings["private_subnets"])
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = local.private_subnets[count.index].id
}

resource "aws_route_table_association" "data_subnets" {
  count          = length(var.vpc_settings["data_subnets"])
  route_table_id = aws_route_table.data_subnets[count.index].id
  subnet_id      = local.data_subnets[count.index].id
}

resource "aws_route_table_association" "public_subnet" {
  count          = length(var.vpc_settings["public_subnets"])
  route_table_id = aws_route_table.public.id
  subnet_id      = local.public_subnets[count.index].id
}

### VPC Endpoints definition

resource "aws_vpc_endpoint" "s3" {
  route_table_ids = local.route_table_list
  service_name    = "com.amazonaws.${var.region}.s3"
  vpc_id          = aws_vpc.vpc.id
  tags            = local.tags

  depends_on = [aws_subnet.private_subnets]
}


resource "aws_security_group" "endpoint_sg" {
  description = "endpoint sg security group"
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.identifier}-${terraform.workspace}"

  ingress {
    cidr_blocks = [var.vpc_settings["cidr"]]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  egress {
    cidr_blocks = [var.vpc_settings["cidr"]]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = local.tags
}

### VPC flow logs

resource "aws_flow_log" "logs" {
  count                = var.flow_log_settings["enable_flow_log"] ? 1 : 0
  iam_role_arn         = var.iam_role_arn
  log_destination      = var.log_destination
  traffic_type         = var.flow_log_settings["traffic_type"]
  vpc_id               = aws_vpc.vpc.id
} 
